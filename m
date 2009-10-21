From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Wed, 21 Oct 2009 07:14:02 +0200
Message-ID: <4ADE989A.90209@gmail.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <4ADE2A24.6080300@gmail.com> <4ADE2C00.8030900@candelatech.com> <4ADE3253.10302@gmail.com> <4ADE44FC.4030406@candelatech.com> <4ADE7A63.4090404@candelatech.com> <4ADE7C0D.5070208@gmail.com> <4ADE873F.3030903@gmail.com> <4ADE9560.5050500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58449 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbZJUFOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 01:14:03 -0400
In-Reply-To: <4ADE9560.5050500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :
> Eric Dumazet wrote:
>> pktgen should not use "clone XXX" pkts if macvlan is used (or any
>> other driver
>> that ultimatly calls dev_queue_xmit() and queue packet), since skb
>> queue anchor
>> is shared and would be overwritten.
>>   After some thoughts, I believe user is in error :)
> I tried to explain in my original post:  The problem arises when
> when the hard-start-xmit fails with NETDEV_TX_BUSY.  Part of the
> hard-start-xmit logic for virtual devices can call dev_queue_xmit, wh=
ich
> can ultimately
> change the queue mapping and yet may still return NETDEV_TX_BUSY.
>=20
> pktgen would try to resend this skb next loop, and this is where it w=
ould
> blow up.
>=20
> I have a patched macvlan logic and a patched dev queue xmit logic tha=
t
> allows
> me to return NETDEV_TX_BUSY when underlying device fails to transmit.
>=20
> It may be that my hacked macvlan is the only virtual device that coul=
d ever
> return NETDEV_TX_BUSY, and if that is the case, I don't think the bug
> could ever be hit in official kernel code.  My opinion is that the
> current pktgen code makes
> too many assumptions, so unless there is a performance penalty, I sti=
ll
> think it should be cleaned up.  But, I may be too paranoid.

If a virtual device changes skb->queue_map, it must consume skb,
or it breaks caller.

Alternative would be to restore queue_map to its initial value in
your hacked macvlan when it wants to return NETDEV_TX_BUSY status.


We could add a WARN_ON(skb_get_queue_mapping(pkt_dev->skb) !=3D queue_m=
ap);
in pktgen, to catch driver errors but pktgen assumption is right IMHO

@@ -3466,6 +3471,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_de=
v)
 		/* fallthru */
 	case NETDEV_TX_LOCKED:
 	case NETDEV_TX_BUSY:
+		WARN_ON(skb_get_queue_mapping(pkt_dev->skb) !=3D queue_map);
 		/* Retry it next time */
 		atomic_dec(&(pkt_dev->skb->users));
 		pkt_dev->last_ok =3D 0;
