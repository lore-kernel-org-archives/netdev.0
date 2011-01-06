From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 6 Jan 2011 21:44:39 +0900
Message-ID: <20110106124439.GA17004@verge.net.au>
References: <20110106093312.GA1564@verge.net.au>
 <1294309362.3074.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:35642 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab1AFMoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 07:44:44 -0500
Content-Disposition: inline
In-Reply-To: <1294309362.3074.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 06, 2011 at 11:22:42AM +0100, Eric Dumazet wrote:
> Le jeudi 06 janvier 2011 =C3=A0 18:33 +0900, Simon Horman a =C3=A9cri=
t :
> > Hi,
> >=20
> > Back in October I reported that I noticed a problem whereby flow co=
ntrol
> > breaks down when openvswitch is configured to mirror a port[1].
> >=20
> > I have (finally) looked into this further and the problem appears t=
o relate
> > to cloning of skbs, as Jesse Gross originally suspected.
> >=20
> > More specifically, in do_execute_actions[2] the first n-1 times tha=
t an skb
> > needs to be transmitted it is cloned first and the final time the o=
riginal
> > skb is used.
> >=20
> > In the case that there is only one action, which is the normal case=
, then
> > the original skb will be used. But in the case of mirroring the clo=
ning
> > comes into effect. And in my case the cloned skb seems to go to the=
 (slow)
> > eth1 interface while the original skb goes to the (fast) dummy0 int=
erface
> > that I set up to be a mirror. The result is that dummy0 "paces" the=
 flow,
> > and its a cracking pace at that.
> >=20
> > As an experiment I hacked do_execute_actions() to use the original =
skb
> > for the first action instead of the last one.  In my case the resul=
t was
> > that eth1 "paces" the flow, and things work reasonably nicely.
> >=20
> > Well, sort of. Things work well for non-GSO skbs but extremely poor=
ly for
> > GSO skbs where only 3 (yes 3, not 3%) end up at the remote host run=
ning
> > netserv. I'm unsure why, but I digress.
> >=20
> > It seems to me that my hack illustrates the point that the flow end=
s up
> > being "paced" by one interface. However I think that what would be
> > desirable is that the flow is "paced" by the slowest link. Unfortun=
ately
> > I'm unsure how to achieve that.
> >=20
>=20
> Hi Simon !
>=20
> "pacing" is done because skb is attached to a socket, and a socket ha=
s a
> limited (but configurable) sndbuf. sk->sk_wmem_alloc is the current s=
um
> of all truesize skbs in flight.
>=20
> When you enter something that :
>=20
> 1) Get a clone of the skb, queue the clone to device X
> 2) queue the original skb to device Y
>=20
> Then :	Socket sndbuf is not affected at all by device X queue.
> 	This is speed on device Y that matters.
>=20
> You want to get servo control on both X and Y
>=20
> You could try to
>=20
> 1) Get a clone of skb
>    Attach it to socket too (so that socket get a feedback of final
> orphaning for the clone) with skb_set_owner_w()
>    queue the clone to device X
>=20
> Unfortunatly, stacked skb->destructor() makes this possible only for
> known destructor (aka sock_wfree())

Hi Eric !

Thanks for the advice. I had thought about the socket buffer but at som=
e
point it slipped my mind.

In any case the following patch seems to implement the change that I ha=
d in
mind. However my discussions Michael Tsirkin elsewhere in this thread a=
re
beginning to make me think that think that perhaps this change isn't th=
e
best solution.

diff --git a/datapath/actions.c b/datapath/actions.c
index 5e16143..505f13f 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -384,7 +384,12 @@ static int do_execute_actions(struct datapath *dp,=
 struct sk_buff *skb,
=20
 	for (a =3D actions, rem =3D actions_len; rem > 0; a =3D nla_next(a, &=
rem)) {
 		if (prev_port !=3D -1) {
-			do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
+			struct sk_buff *nskb =3D skb_clone(skb, GFP_ATOMIC);
+			if (nskb) {
+				if (skb->sk)
+					skb_set_owner_w(nskb, skb->sk);
+				do_output(dp, nskb, prev_port);
+			}
 			prev_port =3D -1;
 		}

I got a rather nasty panic without the if (skb->sk),
I guess some skbs don't have a socket.
