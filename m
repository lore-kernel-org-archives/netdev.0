From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 06 Jan 2011 11:22:42 +0100
Message-ID: <1294309362.3074.11.camel@edumazet-laptop>
References: <20110106093312.GA1564@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110106093312.GA1564@verge.net.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 06 janvier 2011 =C3=A0 18:33 +0900, Simon Horman a =C3=A9crit =
:
> Hi,
>=20
> Back in October I reported that I noticed a problem whereby flow cont=
rol
> breaks down when openvswitch is configured to mirror a port[1].
>=20
> I have (finally) looked into this further and the problem appears to =
relate
> to cloning of skbs, as Jesse Gross originally suspected.
>=20
> More specifically, in do_execute_actions[2] the first n-1 times that =
an skb
> needs to be transmitted it is cloned first and the final time the ori=
ginal
> skb is used.
>=20
> In the case that there is only one action, which is the normal case, =
then
> the original skb will be used. But in the case of mirroring the cloni=
ng
> comes into effect. And in my case the cloned skb seems to go to the (=
slow)
> eth1 interface while the original skb goes to the (fast) dummy0 inter=
face
> that I set up to be a mirror. The result is that dummy0 "paces" the f=
low,
> and its a cracking pace at that.
>=20
> As an experiment I hacked do_execute_actions() to use the original sk=
b
> for the first action instead of the last one.  In my case the result =
was
> that eth1 "paces" the flow, and things work reasonably nicely.
>=20
> Well, sort of. Things work well for non-GSO skbs but extremely poorly=
 for
> GSO skbs where only 3 (yes 3, not 3%) end up at the remote host runni=
ng
> netserv. I'm unsure why, but I digress.
>=20
> It seems to me that my hack illustrates the point that the flow ends =
up
> being "paced" by one interface. However I think that what would be
> desirable is that the flow is "paced" by the slowest link. Unfortunat=
ely
> I'm unsure how to achieve that.
>=20

Hi Simon !

"pacing" is done because skb is attached to a socket, and a socket has =
a
limited (but configurable) sndbuf. sk->sk_wmem_alloc is the current sum
of all truesize skbs in flight.

When you enter something that :

1) Get a clone of the skb, queue the clone to device X
2) queue the original skb to device Y

Then :	Socket sndbuf is not affected at all by device X queue.
	This is speed on device Y that matters.

You want to get servo control on both X and Y

You could try to

1) Get a clone of skb
   Attach it to socket too (so that socket get a feedback of final
orphaning for the clone) with skb_set_owner_w()
   queue the clone to device X

Unfortunatly, stacked skb->destructor() makes this possible only for
known destructor (aka sock_wfree())

> One idea that I had was to skb_get() the original skb each time it is
> cloned - that is easy enough. But unfortunately it seems to me that
> approach would require some sort of callback mechanism in kfree_skb()=
 so
> that the cloned skbs can kfree_skb() the original skb.
>=20
> Ideas would be greatly appreciated.
>=20
> [1] http://openvswitch.org/pipermail/dev_openvswitch.org/2010-October=
/003806.html
> [2] http://openvswitch.org/cgi-bin/gitweb.cgi?p=3Dopenvswitch;a=3Dblo=
b;f=3Ddatapath/actions.c;h=3D5e16143ca402f7da0ee8fc18ee5eb16c3b7598e6;h=
b=3DHEAD
> --


