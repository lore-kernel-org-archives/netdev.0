From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH V3 net-next] TLP: Don't reschedule PTO when there's one
 outstanding TLP retransmission
Date: Fri, 28 Jul 2017 18:48:24 -0400
Message-ID: <CADVnQy=Dw__BrTHwoUrn0Wxu8=Xb7NqZ9bAuEeM8SrNhzd_2SA@mail.gmail.com>
References: <1501157337-10900-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        weiyongjun1@huawei.com, Weilong Chen <chenweilong@huawei.com>,
        wangkefeng.wang@huawei.com
To: Mao Wenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35365 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752849AbdG1Ws4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 18:48:56 -0400
Received: by mail-oi0-f51.google.com with SMTP id e124so184579409oig.2
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 15:48:55 -0700 (PDT)
In-Reply-To: <1501157337-10900-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 8:08 AM, Mao Wenan <maowenan@huawei.com> wrote:
> If there is one TLP probe went out(TLP use the write_queue_tail
> packet as TLP probe, we assume this first TLP probe named A), and
> this TLP probe was not acked by receive side.
>
> Then the transmit side sent the next two packetes out(named B,C),
> but unfortunately these two packets are also not acked by receive side.
>
> And then there is one data packet with ack_seq A arrive at transmit
> side, in tcp_ack() will call tcp_schedule_loss_probe() to rearm PTO,
> the handler tcp_send_loss_probe() is to check
> if(tp->tlp_high_seq) then go to rearm_timer(because there is one
> outstanding TLP named A), so the new TLP probe can't be sent out and
> it needs to rearm the RTO timer(timeout is relative to the transmit
> time of the write queue head).
>
> After that, there is another data packet with ack_seq A is received,
> if the tlp_time_stamp is greater than rto_time_stamp, it will reset
> the TLP timeout, which is before previous RTO timeout, so PTO is
> rearm and previous RTO is cleared. Because there is no
> retransmission packet was sent or no TLP sack receive,
> tp->tlp_high_seq can't be reset to zero and the next TLP probe also
> can't be sent out, so there is no way(or very long time)
> to retransmit the lost packet.
>
> This fix is to check(tp->tlp_high_seq) in tcp_schedule_loss_probe()
> when TLP PTO is after RTO, It is not needed to reschedule PTO when
> there is one outstanding TLP retransmission, so if the TLP A is lost
> RTO can retransmit lost packet, then tp->tlp_high_seq will be set to
> 0, and TLP will go to the normal work process.
>
> v1->v2
>         refine some words of code and patch comments.
> v2->v3
>         delete senseless "{" and "}" in if clause.
>
> Signed-off-by: Mao Wenan <maowenan@huawei.com>

Thanks for posting this patch with a detailed problem description, as
well as a trace in the thread for v1 of the patch. This was very
helpful!

Thinking about the problem you describe, and looking at the trace,
AFAICT I don't think this is the patch we want.

We can still have this problem of improperly/repeatedly rescheduling a
PTO even when the TLPs are new data. When the TLPs are new data
tp->tlp_high_seq is not set, and so the patch above will not help.

I think the broader problem is hinted at in this part of your commit
description:

> After that, there is another data packet with ack_seq A is received,
> if the tlp_time_stamp is greater than rto_time_stamp, it will reset
> the TLP timeout

The broader problem here is that an incoming data packet (with no new
ACK/SACK info) affected the TLP for our outbound data. That is a
problem because such incoming data can cause us to delay the TLP when
there is no reason to.

I think this is basically the same as the TLP issue from the "TCP fast
retransmit issues" thread on netdev from July 26. Our TCP team at
Google has a proposed fix for this more general issue that we have
tested and reviewed. I will post a quick summary of the proposed patch
in the "TCP fast retransmit issues" thread. Once the patch has
undergone a little more testing we will send it to the list, hopefully
next week.

Thanks!
neal
