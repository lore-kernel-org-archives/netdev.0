From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] TLP: Don't reschedule PTO when there's one
 outstanding TLP retransmission.
Date: Tue, 25 Jul 2017 09:29:38 -0400
Message-ID: <CADVnQykr0YTB7YD=9n04bA8WFBQWku4qsPUZpqgKK6YGmd9xBA@mail.gmail.com>
References: <1500971735-21852-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, weiyongjun1@huawei.com,
        Weilong Chen <chenweilong@huawei.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Mao Wenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36779 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750980AbdGYNaK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 09:30:10 -0400
Received: by mail-oi0-f50.google.com with SMTP id g131so52810451oic.3
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 06:30:10 -0700 (PDT)
In-Reply-To: <1500971735-21852-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 4:35 AM, Mao Wenan <maowenan@huawei.com> wrote:
> If there is one TLP probe went out(TLP use the write_queue_tail packet
> as TLP probe, we assume this first TLP probe named A), and this TLP
> probe was not acked by receive side.
>
> Then the transmit side sent the next two packetes out(named B,C), but
> unfortunately these two packets are also not acked by receive side.
>
> And then there is one data packet with ack_seq A arrive, in tcp_ack()
> will call tcp_schedule_loss_probe() to rearm PTO, the handler
> tcp_send_loss_probe() pass if(tp->tlp_high_seq)(because there is
> one outstanding TLP named A,tp->tlp_high_seq is not zero),
> so the new TLP probe can't be went out and need to rearm the RTO
> timer(timeout is relative to the transmit time of the write queue head).
>
> After this, another data packet with ack_seq A is received,
> if the tlp_time_stamp is after rto_time_stamp, it will reset the
> TLP timeout with delta value, which is before previous RTO timeout,
> so PTO is rearm and previous RTO is cleared. This TLP probe also can't
> be sent out because of tp->tlp_high_seq != 0, so there is no way(or need
> very long time)to retransmit the packet because of TLP A is lost.
>
> This fix is not to pass the if(tp->tlp_high_seq) in tcp_schedule_loss_probe()
> when TLP PTO is after RTO, It is no need to reschedule PTO when there
> is one outstanding TLP retransmission, so if the TLP A is lost then RTO can
> retransmit that packet, and tp->tlp_high_seq will be set to 0. After this TLP
> will go to the normal work process.
>
> Signed-off-by: Mao Wenan <maowenan@huawei.com>

Thanks for posting this. This is a pretty involved scenario. To help
document/test precisely what the behavior is before and after your
patch, would you be able to post a packetdrill (
https://github.com/google/packetdrill ) test case for this scenario?

Can I ask if you saw this scenario in an actual trace, or noticed this
by inspection?

thanks,
neal
