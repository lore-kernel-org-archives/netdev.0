From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH V4 net 0/2] ipv6: fix flowlabel issue for reset packet
Date: Fri, 18 Aug 2017 13:51:36 -0700
Message-ID: <20170818205136.nsmlmyshaobsyukc@kafai-mba.dhcp.thefacebook.com>
References: <20170810163033.kriwd2pivmuuzfnb@kernel.org>
 <CALx6S35UKD3AyqxM-zKMCANi=TR_e26mRjKYKH7QreckBu2dEg@mail.gmail.com>
 <20170810191314.vo6yl7dgndga4heh@kernel.org>
 <CALx6S34CwcYNtBzEoEMrBP3O54Fsnot=YzeHCNCM0yeuaFUozQ@mail.gmail.com>
 <20170815025224.trjgcp3z6i3cgfy2@kernel.org>
 <CALx6S34f2r-sQi_gNAS9mxTX0JPeOJrhN8q3wzD-14knCB7DUA@mail.gmail.com>
 <20170815224252.6vjkyqsngybl3z3m@kernel.org>
 <CALx6S34C5aT+UX-Rz39iu5FX-U-EAw23ZiBEcGP90HZRj4xf+g@mail.gmail.com>
 <20170817225521.ybb7cclaxs6skdem@kafai-mba.dhcp.thefacebook.com>
 <CALx6S3498iPfNs4Wt5RWjoxZS0nXHT=qvdSgZhZbqxswqJqdZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Shaohua Li <shli@kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35703 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751173AbdHRUvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:51:42 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S3498iPfNs4Wt5RWjoxZS0nXHT=qvdSgZhZbqxswqJqdZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 07:50:03AM -0700, Tom Herbert wrote:
> > We had been using the auto_flowlabels=1 (i.e. essentially enable flowlabel)
> > mainly because we want to take the benefit of dst_negative_advice() when
> > tcp_write_timeout() happens.
> >
> > During our test, our system handles quite well with changing flowlabel.
> > The only exception we have hit is the TCP_RST sent from an inet_timewait_sock.
> >
> Martin,
>
> That is interesting data. Have you determined why the middlebox has a
> problem with flow label change in TW state but not other states?
Tom,

The problem of this middle box is specific to TCP_RST with a different
flowlabel from its previous packets.  Sending TCP_RST from TW state hits
this pain point.

It seems like that middle box specifically drops TCP_RST if it
does not know anything about this flow.  Since the flowlabel of the TCP_RST
(sent in TW state) is always different, it always lands to a different middle
box.  All of these TCP_RST cannot be delivered.

We are resilience to a small number of TCP_RST drop.  However, this guarantee
flowlabel change on TCP_RST and then dropped is too much.

This flowlabel change does not look like intentional either when transitioning
from full sk to tw sk (tw->tw_flowlabel is inheriting the np->flow_label
in tcp_time_wait()).  Currently, the tw_flowlabel is used in tcp_v6_timewait_ack()
but not in tcp_v6_send_reset().  Hence,  shaohua is looking for a solution to solve
them together.

Thanks,
Martin

>
> Tom
>
> > If we keep the flowlabel consistent (or persistent sk_txhash), there
> > is no practical usage for us to turn on flowlabel and the problem also goes
> > away.  We have it off for now.
> >
> >>
> >> > There seems to have other bug in this side. From my understanding, commit
> >> > 265f94ff54d6(net: Recompute sk_txhash on negative routing advice) tries to
> >> > select a different route. But the multipath selection code
> >> > (rt6_multipath_select) doesn't use sk_txhash or skb->hash, it does use
> >> > fl6.flowlabel, but that is the flowlabel user sets. So looks like the commit
> >> > doesn't change anything.
> >> >
> >> The routing functions typically don't use sock of skbuff, but use flow
> >> structs instead. It may be reasonable to add a hash to those.
> > The localhost's mutlipath selection is another existing issue.  AFAICT,
> > it does not take the sk_txhash (or skb->hash) into account and the following
> > dst_negative_advice() will also have no effect in the route selction.
> > It is another issue to be fixed and to be figured out how to pass the
> > sk_txhash down. (1)
> >
> > Shaohua is proposing to record the 20 bits of the sk_txhash in the
> > tw_flowlabel of the 'struct inet_timewait_sock'.  The tw_flowlabel could
> > potentially be used to do the multipath selection once we figured out
> > how to tackle (1).
> >
> > Thanks,
> > Martin
> >
> >
> >>
> >> > What's the 'src port for UDP encap'? I can't find the code setting skb->hash
> >> > to sk_txhash in UDP side.
> >> >
> >> udp_flow_src_port is function call by UDP encaps to set source port.
> >> This is call skb_get_hash. sk_set_txhash is function to set txhash
> >> right now to random value. skb_set_hash_from_sk set skb->hash when
> >> skbuff is owned by socket (skb_set_owner_w).
> >>
> >> Thanks,
> >> Tom
> >>
> >>
> >> > Thanks,
> >> > Shaohua
