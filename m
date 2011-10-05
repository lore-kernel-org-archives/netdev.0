From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 22:31:33 +0200
Message-ID: <1317846693.3457.11.camel@edumazet-laptop>
References: <4E8C89EE.3090600@candelatech.com>
	 <1317844449.3457.3.camel@edumazet-laptop>
	 <4E8CB990.1010406@candelatech.com>
	 <1317845835.3457.5.camel@edumazet-laptop>
	 <4E8CBBD6.3080500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54430 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757769Ab1JEUbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:31:39 -0400
Received: by wwf22 with SMTP id 22so3137385wwf.1
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 13:31:38 -0700 (PDT)
In-Reply-To: <4E8CBBD6.3080500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 octobre 2011 =C3=A0 13:19 -0700, Ben Greear a =C3=A9crit=
 :
> On 10/05/2011 01:17 PM, Eric Dumazet wrote:
> > Le mercredi 05 octobre 2011 =C3=A0 13:09 -0700, Ben Greear a =C3=A9=
crit :
> >> On 10/05/2011 12:54 PM, Eric Dumazet wrote:
> >>> Le mercredi 05 octobre 2011 =C3=A0 09:46 -0700, Ben Greear a =C3=A9=
crit :
> >>>> This is on a hacked 3.0.4 kernel...
> >>>>
> >>>> I am seeing an issue where an IPv4 mcast receiver will not recei=
ve
> >>>> a 1473 or larger byte mcast message, but will receive a 1472.  T=
he difference
> >>>> being that 1473 ends up being two packets on the wire.  It works=
 on
> >>>> 802.1Q VLANs, VETH interfaces and real Ethernet.  It does not wo=
rk
> >>>> on a mac-vlan hanging off the VETH.
> >>>>
> >>>> I see packets received on the macvlan in tshark, and they appear=
 correct.  No
> >>>> obvious errors in the macvlan port stats or netstat -s,
> >>>> and the 'ss' tool doesn't appear to support UDP sockets at all.
> >>>>
> >>>> So, I'm about to go digging into the code, but if anyone has any
> >>>> suggestions for places to look, please let me know!
> >>>>
> >>>
> >>> Well, problem is defragmentation and macvlan cooperation.
> >>>
> >>> Multicast messages are broadcasted on all macvlan ports.
> >>>
> >>> But IP defrag will probably deliver a single final frame.
> >>>
> >>> We probably need to handle defrag in macvlan before broadcasting =
to all
> >>> ports.
> >>
> >> I see packets get to this code in ip_input.c (line 467 or so),
> >> and that printk is mine of course.
> >>
> >> 	if ((dev&&  strcmp(dev->name, "rddVR10#0") =3D=3D 0) ||
> >> 	    (dev&&  strcmp(dev->name, "rddVR10") =3D=3D 0)) {
> >> 		printk("calling ip_rcv_finish through NF_HOOK, dev: %s, len: %i\=
n",
> >> 		       dev->name, skb->len);
> >> 	}
> >>
> >> 	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
> >> 		       ip_rcv_finish);
> >>
> >> But, the macvlan packets never make it to the ip_rcv_finish method=
=2E
> >>
> >> I do see a big and a little packet entering this code.
> >>
> >> I have no firewall rules that I'm aware of, though there
> >> is some conn-track logic (though not associated with the
> >> mac-vlan interface):
> >
> > Say you have 10 vlans on your eth0, how many times do you want one
> > incoming multicast frame being delivered to your application listen=
ing
> > on 0.0.0.0:port ?
>=20
> How would it work for two Ethernet devices on the same LAN?  I'd
> say that mac-vlans should mimic that case.
>=20
> And in my case, I'm binding hard to a device & IP address,
> so my app should get it once regardless.
>=20

OK, but before frame being delivered to your app, it must be
re-assembled by net/ipv4/inet_fragment.c & net/ipv4/ip_fragment.c
machinery.

This machinery uses :

static int ip4_frag_match(struct inet_frag_queue *q, void *a)
{
        struct ipq *qp;
        struct ip4_create_arg *arg =3D a;

        qp =3D container_of(q, struct ipq, q);
        return  qp->id =3D=3D arg->iph->id &&
                        qp->saddr =3D=3D arg->iph->saddr &&
                        qp->daddr =3D=3D arg->iph->daddr &&
                        qp->protocol =3D=3D arg->iph->protocol &&
                        qp->user =3D=3D arg->user;
}

All frames broadcasted (because of multicast code in macvlan) on vlans
have same saddr/daddr/protocol (and user).

So kernel will discard all redundant copies of frames and deliver one
copy only to upper stack.

Check commit 7736d33f4262d437c5 (packet: Add pre-defragmentation suppor=
t
for ipv4 fanouts) for a possible hint :

We could perform the re-assembly in macvlan code, before doing the
"broadcast the frame on all ports" part.
