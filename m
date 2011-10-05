From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 22:17:15 +0200
Message-ID: <1317845835.3457.5.camel@edumazet-laptop>
References: <4E8C89EE.3090600@candelatech.com>
	 <1317844449.3457.3.camel@edumazet-laptop>
	 <4E8CB990.1010406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33944 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934686Ab1JEURV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:17:21 -0400
Received: by bkbzt4 with SMTP id zt4so2562028bkb.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 13:17:20 -0700 (PDT)
In-Reply-To: <4E8CB990.1010406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 octobre 2011 =C3=A0 13:09 -0700, Ben Greear a =C3=A9crit=
 :
> On 10/05/2011 12:54 PM, Eric Dumazet wrote:
> > Le mercredi 05 octobre 2011 =C3=A0 09:46 -0700, Ben Greear a =C3=A9=
crit :
> >> This is on a hacked 3.0.4 kernel...
> >>
> >> I am seeing an issue where an IPv4 mcast receiver will not receive
> >> a 1473 or larger byte mcast message, but will receive a 1472.  The=
 difference
> >> being that 1473 ends up being two packets on the wire.  It works o=
n
> >> 802.1Q VLANs, VETH interfaces and real Ethernet.  It does not work
> >> on a mac-vlan hanging off the VETH.
> >>
> >> I see packets received on the macvlan in tshark, and they appear c=
orrect.  No
> >> obvious errors in the macvlan port stats or netstat -s,
> >> and the 'ss' tool doesn't appear to support UDP sockets at all.
> >>
> >> So, I'm about to go digging into the code, but if anyone has any
> >> suggestions for places to look, please let me know!
> >>
> >
> > Well, problem is defragmentation and macvlan cooperation.
> >
> > Multicast messages are broadcasted on all macvlan ports.
> >
> > But IP defrag will probably deliver a single final frame.
> >
> > We probably need to handle defrag in macvlan before broadcasting to=
 all
> > ports.
>=20
> I see packets get to this code in ip_input.c (line 467 or so),
> and that printk is mine of course.
>=20
> 	if ((dev && strcmp(dev->name, "rddVR10#0") =3D=3D 0) ||
> 	    (dev && strcmp(dev->name, "rddVR10") =3D=3D 0)) {
> 		printk("calling ip_rcv_finish through NF_HOOK, dev: %s, len: %i\n",
> 		       dev->name, skb->len);
> 	}
>=20
> 	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
> 		       ip_rcv_finish);
>=20
> But, the macvlan packets never make it to the ip_rcv_finish method.
>=20
> I do see a big and a little packet entering this code.
>=20
> I have no firewall rules that I'm aware of, though there
> is some conn-track logic (though not associated with the
> mac-vlan interface):

Say you have 10 vlans on your eth0, how many times do you want one
incoming multicast frame being delivered to your application listening
on 0.0.0.0:port ?

10 or 1 ?
