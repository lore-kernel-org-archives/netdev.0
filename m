From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Wed, 11 Feb 2004 16:32:23 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402111534310.2809-100000@l>
References: <1076505110.2267.207.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1076505110.2267.207.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On 11 Feb 2004, jamal wrote:

> > 	Yes, I tried it on empty system, just ip route get -> NUD_NONE.
>
> It doesnt seem to show up at all in the neigh cache display although
> you are correct that it does go to NUD_NONE given the transition
> when you attempt a ping right after.
>
> is NUD_NONE never displayed by ip n ls?

	I now see that the trick is ip n l nud none

> > 	I did it during my initial tests and now I tested it
> > again, looks as expected.
>
> I am not %100 sure if such an entry should be route cached if the nh
> is not resolvable. What are your thoughts on this?

	It looks bad to call route_slow for every one request,
I have to think more about it.

> > 	Yes, target can exist in the cache in NUD_FAILED without
> > timer. But it is possible if we send probe to receive answer.
>
> NUD_FAILED is dead meat waiting to be garbage collected.

	But can be outdated.

> I think if any cache entry is NUD_VALID you should respond immediately.

	No, we should delay the broadcasts if such delay is
configured. For unicasts we respond immediately.

> anything else you should enqueue request and initiate a discovery to
> target.

	By checking ->probes we queue !VALID entries only
when switching from FAILED to INCOMPLETE. For example:

- we have 3 brd probes configured to send

- request comes

- we send 1st brd probe for target and enqueue this incoming request
and all requests coming before we send the 2nd probe

- we send 2nd probe (still no answer for the 1st)

- at this point we know that target is really dead and we do not
need to queue more incoming requests (even brd ones) until target
responds (the queue has limit)

- this cycle repeats on each 3 seconds which means that for 1
second we queue requests and for 2 seconds we just drop

> Ok, I looked at this and i am wondering if all logic you have is needed.
> I apologize in advance because i feel i missed something you said
> earlier, but what is wrong with just saying along the following lines:
>
>  if (skb->stamp.tv_sec == 0 ||
>     skb->pkt_type == PACKET_HOST ||
>     in_dev->arp_parms->proxy_delay == 0) {
>          if ((in_dev->arp_parms->proxy_validate) &&
>               n && !neigh_is_valid(n)) {
>                               /* probably issue arp to tip here */
>                               goto q_it;
>
> 	}
> 	arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
>  } else {
> q_it:
>          if (fwd_proxy)
>               neigh_event_send(n, NULL);
>          pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
>          in_dev_put(in_dev);
>          return 0;
>  }
>  goto out;

	There is possible loop in this example (as DaveM warned)
when ((tv_sec=0 or delay=0) and !valid) but it can be fixed (then
you will have code in similar size :)). The problem is that I
wanted to avoid creating new flag if there is no need to support
the old behavior in the real life. Also, we have choice to apply
delay according to the proxy type (DNAT/fwd/pneigh) and the
probes sent.

	Also, you do not call neigh_event_send when
request with tv_sec!=0 comes. This is bad in cases where the
requestor sends only ARP requests without IP traffic, you
risk target to switch to STALE state for long time and we will
start to provide outdated information. We have to treat the
ARP requests as IP traffic and to update the target's state.

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
