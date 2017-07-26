From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] TLP: Don't reschedule PTO when there's one
 outstanding TLP retransmission.
Date: Wed, 26 Jul 2017 09:45:06 -0700
Message-ID: <CAK6E8=ciCn1MFkoPXmBV3k34QxzhwK-yLC5_2hd=bb12dG2jRA@mail.gmail.com>
References: <1500971735-21852-1-git-send-email-maowenan@huawei.com>
 <CADVnQykr0YTB7YD=9n04bA8WFBQWku4qsPUZpqgKK6YGmd9xBA@mail.gmail.com> <F95AC9340317A84688A5F0DF0246F3F202929B17@DGGEMI512-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Neal Cardwell <ncardwell@google.com>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Chenweilong <chenweilong@huawei.com>,
        Nandita Dukkipati <nanditad@google.com>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:33044 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdGZQpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 12:45:49 -0400
Received: by mail-wr0-f170.google.com with SMTP id v105so103722354wrb.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 09:45:48 -0700 (PDT)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F202929B17@DGGEMI512-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 7:12 PM, maowenan <maowenan@huawei.com> wrote:
>
>
>
> > -----Original Message-----
> > From: Neal Cardwell [mailto:ncardwell@google.com]
> > Sent: Tuesday, July 25, 2017 9:30 PM
> > To: maowenan
> > Cc: Netdev; David Miller; weiyongjun (A); Chenweilong; Yuchung Cheng;
> > Nandita Dukkipati
> > Subject: Re: [PATCH net-next] TLP: Don't reschedule PTO when there's one
> > outstanding TLP retransmission.
> >
> > On Tue, Jul 25, 2017 at 4:35 AM, Mao Wenan <maowenan@huawei.com>
> > wrote:
> > > If there is one TLP probe went out(TLP use the write_queue_tail packet
> > > as TLP probe, we assume this first TLP probe named A), and this TLP
> > > probe was not acked by receive side.
> > >
> > > Then the transmit side sent the next two packetes out(named B,C), but
> > > unfortunately these two packets are also not acked by receive side.
> > >
> > > And then there is one data packet with ack_seq A arrive, in tcp_ack()
> > > will call tcp_schedule_loss_probe() to rearm PTO, the handler
> > > tcp_send_loss_probe() pass if(tp->tlp_high_seq)(because there is one
> > > outstanding TLP named A,tp->tlp_high_seq is not zero), so the new TLP
> > > probe can't be went out and need to rearm the RTO timer(timeout is
> > > relative to the transmit time of the write queue head).
> > >
> > > After this, another data packet with ack_seq A is received, if the
> > > tlp_time_stamp is after rto_time_stamp, it will reset the TLP timeout
> > > with delta value, which is before previous RTO timeout, so PTO is
> > > rearm and previous RTO is cleared. This TLP probe also can't be sent
> > > out because of tp->tlp_high_seq != 0, so there is no way(or need very
> > > long time)to retransmit the packet because of TLP A is lost.
> > >
> > > This fix is not to pass the if(tp->tlp_high_seq) in
> > > tcp_schedule_loss_probe() when TLP PTO is after RTO, It is no need to
> > > reschedule PTO when there is one outstanding TLP retransmission, so if
> > > the TLP A is lost then RTO can retransmit that packet, and
> > > tp->tlp_high_seq will be set to 0. After this TLP will go to the normal work
> > process.
> > >
> > > Signed-off-by: Mao Wenan <maowenan@huawei.com>
> >
> > Thanks for posting this. This is a pretty involved scenario. To help
> > document/test precisely what the behavior is before and after your patch,
> > would you be able to post a packetdrill ( https://github.com/google/packetdrill )
> > test case for this scenario?
> >
> > Can I ask if you saw this scenario in an actual trace, or noticed this by
> > inspection?
> [Mao Wenan] It is my actual product scenario, from some debug trace info
> I found that PTO is always rescheduled before RTO, this is PTO is trigged
> by receiving one tcp_ack packets. After this patch, the product works well and
> there is no previous issue happen. The packet can retransmit with RTO if TLP probe
> is lost.
> I will say sorry that my local test can't reproduce because i can't build successfully the same
> complex scenario, I don't have mature test case to reproduce now but I will do my best to try
> in local test environment.
tcpdump output of an example trace also helps. Feel free to remove IP
address, ports, or payload information. We only need the timing and
TCP header info.


> Thank you.
> >
> > thanks,
> > neal
