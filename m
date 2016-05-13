From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 06/13] ipv6: Fix nexthdr for reinjection
Date: Fri, 13 May 2016 09:28:50 +0300
Message-ID: <20160513092850.1868a828@halley>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
	<1462985253-2380625-7-git-send-email-tom@herbertland.com>
	<20160512232304.437eb3bc@halley>
	<CALx6S34BHQnxSBAW4n4k+pf0Zey+XaiLAVvU5k_zVVRz=jAJvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35643 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbcEMG27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 02:28:59 -0400
Received: by mail-wm0-f65.google.com with SMTP id e201so1629601wme.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 23:28:59 -0700 (PDT)
In-Reply-To: <CALx6S34BHQnxSBAW4n4k+pf0Zey+XaiLAVvU5k_zVVRz=jAJvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 12 May 2016 14:45:36 -0700 Tom Herbert <tom@herbertland.com> wrote:
> On Thu, May 12, 2016 at 1:23 PM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
> >> @@ -222,13 +222,14 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
> >>        */
> >>
> >>       rcu_read_lock();
> >> -resubmit:
> >> +
> >>       idev = ip6_dst_idev(skb_dst(skb));
> >>       if (!pskb_pull(skb, skb_transport_offset(skb)))
> >>               goto discard;
> >>       nhoff = IP6CB(skb)->nhoff;
> >>       nexthdr = skb_network_header(skb)[nhoff];
> >>
> >> +resubmit:  
> >
> > This has already been attempted in 0243508edd "ipv6: Fix protocol
> > resubmission" and reverted in 1b0ccfe54a.
> >
> > It looks that in some genuine extension header handling cases of ipv6
> > (not related to encapsulation), the original resubmission code REALLY
> > requires one to re-read IP6CB(skb)->nhoff and refetch the nexthdr.
> >  
> Is there any reason why the EH handlers can't read the nexthdr and return that?

One additional thing:

Seems the

    if (!pskb_pull(skb, skb_transport_offset(skb)))

located at the original resubmit label was also necessary, as the EH
handlers may increment skb->transport_header (both ipv6_destopt_rcv and
ipv6_rthdr_rcv do so).

So if we'd like to read the nexthdr at the EH handlers we should repeat
the "skb pull; read nexthdr from skb_network_header(skb)[new nhoff];
return nexhdr;" prior each positive return from EH handlers.

Thanks
Shmulik
