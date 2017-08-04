From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 3/3] tcp: fix xmit timer to only be reset if data ACKed/SACKed
Date: Fri, 4 Aug 2017 11:54:32 -0400
Message-ID: <CADVnQykoadLALP4iOzm16F=XQW41q8m_GnzKsGOgrkg6jso15g@mail.gmail.com>
References: <20170801025814.31206-1-ncardwell@google.com> <20170801025814.31206-4-ncardwell@google.com>
 <F95AC9340317A84688A5F0DF0246F3F20293523A@DGGEMI512-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:37440 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752132AbdHDPzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 11:55:04 -0400
Received: by mail-qk0-f171.google.com with SMTP id z18so11215964qka.4
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 08:55:04 -0700 (PDT)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F20293523A@DGGEMI512-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 4, 2017 at 3:12 AM, maowenan <maowenan@huawei.com> wrote:
> > > --- a/net/ipv4/tcp_output.c
> > > +++ b/net/ipv4/tcp_output.c
> > > @@ -2380,21 +2380,12 @@ bool tcp_schedule_loss_probe(struct sock *sk)
> > >     u32 rtt = usecs_to_jiffies(tp->srtt_us >> 3);
> > >     u32 timeout, rto_delta_us;
> > >
> > > -   /* No consecutive loss probes. */
> > > -   if (WARN_ON(icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)) {
> > > -           tcp_rearm_rto(sk);
> > > -           return false;
> > > -   }
> [Mao Wenan] I'm sorry I can't get why you delete this and below "if" branch?

We deleted those two "if" branches in tcp_schedule_loss_probe()
because they were assuming that TLP probes would only be scheduled in
a context where an RTO had already been scheduled. With the old
implementation that was true: on every ACK (tcp_ack()) or send of new
data (tcp_event_new_data_sent()) we would first schedule an RTO (by
calling tcp_rearm_rto()) and then schedule a TLP (by calling
tcp_schedule_loss_probe()). So the checks were the right ones for the
old implementation.

With the new implementation, we do not first rearm the RTO on every
incoming ACK. That means when we get to tcp_schedule_loss_probe() we
may find either an RTO or TLP is pending.

Hope that helps clear that up.

cheers,
neal
