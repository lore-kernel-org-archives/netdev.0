From: Guy Yur <guyyur@gmail.com>
Subject: Re: [RFC][PATCH] Failed neighbors attached to routes are not released
Date: Tue, 23 Aug 2011 00:17:51 +0300
Message-ID: <CAC67Hz-2ZjmLXVqXdma++7tSqyjeV0jw=WQzG1pCyLBD_nv-9w@mail.gmail.com>
References: <CAC67Hz-MpmPGX4c+DTCgXkfnKdinNCrc7xc9Q03=35t=LLnW+g@mail.gmail.com>
	<1314031455.2307.113.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAC67Hz8TZ43B5FHEtzwr-u1j6Z0hj1GPEA_hi0g6z0QLDUp4oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36333 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637Ab1HVVRx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 17:17:53 -0400
Received: by fxh19 with SMTP id 19so3530939fxh.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 14:17:51 -0700 (PDT)
In-Reply-To: <CAC67Hz8TZ43B5FHEtzwr-u1j6Z0hj1GPEA_hi0g6z0QLDUp4oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2011 at 10:49 PM, Guy Yur <guyyur@gmail.com> wrote:
> On Mon, Aug 22, 2011 at 7:44 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le vendredi 19 ao=C3=BBt 2011 =C3=A0 21:53 +0300, Guy Yur a =C3=A9cr=
it :
>>> Hi,
>>>
>>> The issue I am seeing is with a neighbor used as a gateway in a rou=
te,
>>> when the neighbor gets nud FAILED it will not be removed from the
>>> neighbor cache.
>>> The reference count for the neighbor remains > 1
>>> when neigh_periodic_work() is called.
>>>
>>> Issue noticed with IPv6 neighbors on Arch Linux with kernel 3.0.3
>>> kernel config includes CONFIG_IPV6_ROUTER_PREF
>>>
>>> The problem affects routing when the neighbor loses connectivity an=
d returns.
>>>
>>> Scenario: Using a default route and a static route through differen=
t interfaces.
>>> When the neighbor gateway of the static route goes down the traffic
>>> will move to the default gateway as expected.
>>> Once the static route neighbor comes back up it is not asked for
>>> neighbor solicitation
>>> because the route is marked as FAILED and the traffic will continue=
 to
>>> pass through the default gateway.
>>>
>>> Steps to reproduce the route not being removed:
>>> 1. add an IPv6 address on an interface
>>> 2. add a route to a network through a gateway on the interface's ne=
twork
>>> 3. make sure the gateway address is not reachable
>>> 4. ping6 a host in the route network
>>> 5. "ip -6 nei" will show the gateway neighbor as FAILED and it won'=
t be released
>>>
>>> Steps to reproduce the routing problem:
>>> 1. client and two gateway machines (A and B)
>>> 2. on the client define a static route through A and a default rout=
e through B
>>> 3. disconnect eth on A
>>> 4. ping6 a host in the network that should go through A
>>> =C2=A0 =C2=A0after a while the traffic will move through B which is=
 the default route
>>> 5. reconnect eth on A
>>> 6. ping6 a host in the network again, the traffic will still go thr=
ough B
>>> =C2=A0 =C2=A0"ip -6 nei" on the client will still show A as FAILED
>>>
>>>
>>> Patch to change the nud state to NONE if the reference count > 1
>>> allowing the neighbor to be released in a future pass.
>>
>> I wonder why a 'future pass' is needed at all.
>>
>> Shouldnt we immediately detect link becomes alive and force an immed=
iate
>> flush at this point, before waiting a garbage collect timer ?
>>
>
> I tested removing the neighbor as done in neigh_flush_dev() instead o=
f
> just setting to NUD_NONE,
> it seems that the neighbor shouldn't be removed if it has routes atta=
ched to it.
> If the neighbor is removed the route won't be considered at all.
>
> The problem of the state remaining FAILED does need to be handled.
> Like the case of no neighbor, a FAILED state means find_match() won't
> try to send neighbor solicitation probes.
> The neighbor will remain in a state of NUD_FAILED and the route won't
> be used, only a direct communication with the neighbor will change it=
s
> state.
>
> Do you think it is better to change the state from NUD_FAILED to
> NUD_NONE in neigh_timer_handler() instead?
>
> Updated patch to set the state to NUD_NOARP if the state was valid,
> same as done in neigh_flush_dev().
> Not sure if it is needed or the state can be set to NUD_NONE in all c=
ases.
>

Previous patch with NOARP doesn't work.

New patch to only deal with FAILD state.

when using a neighbor through a route:
1. If no traffic is passed through the neighbor, it will move to STALE
state and remain there as before.
2. If the neighbor is unreachable, it will become FAILED.
    from then it will change periodically to NONE and the reachability
tests will resume.
    If the neighbor becomes reachable again, once the periodic handler
sets it to NONE and the routing code probes it, traffic will resume
through it.

--- linux/net/core/neighbour.c.orig	2011-07-22 05:17:23.000000000 +0300
+++ linux/net/core/neighbour.c	2011-08-22 23:53:21.448424900 +0300
@@ -802,15 +802,18 @@
 			if (time_before(n->used, n->confirmed))
 				n->used =3D n->confirmed;

-			if (atomic_read(&n->refcnt) =3D=3D 1 &&
-			    (state =3D=3D NUD_FAILED ||
-			     time_after(jiffies, n->used + n->parms->gc_staletime))) {
-				*np =3D n->next;
-				n->dead =3D 1;
-				write_unlock(&n->lock);
-				neigh_cleanup_and_release(n);
-				continue;
+			if (state =3D=3D NUD_FAILED ||
+			     time_after(jiffies, n->used + n->parms->gc_staletime)) {
+				if (atomic_read(&n->refcnt) =3D=3D 1) {
+					*np =3D n->next;
+					n->dead =3D 1;
+					write_unlock(&n->lock);
+					neigh_cleanup_and_release(n);
+					continue;
+				} else if (state =3D=3D NUD_FAILED)
+					n->nud_state =3D NUD_NONE;
 			}
 			write_unlock(&n->lock);

 next_elt:
