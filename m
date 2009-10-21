From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 22:40:16 -0700
Message-ID: <4ADE9EC0.20505@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <4ADE2A24.6080300@gmail.com> <4ADE2C00.8030900@candelatech.com> <4ADE3253.10302@gmail.com> <4ADE44FC.4030406@candelatech.com> <4ADE7A63.4090404@candelatech.com> <4ADE7C0D.5070208@gmail.com> <4ADE873F.3030903@gmail.com> <4ADE9560.5050500@candelatech.com> <4ADE989A.90209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52817 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbZJUFkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 01:40:17 -0400
In-Reply-To: <4ADE989A.90209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Ben Greear a =E9crit :
>  =20
>> Eric Dumazet wrote:
>>    =20
>>> pktgen should not use "clone XXX" pkts if macvlan is used (or any
>>> other driver
>>> that ultimatly calls dev_queue_xmit() and queue packet), since skb
>>> queue anchor
>>> is shared and would be overwritten.
>>>   After some thoughts, I believe user is in error :)
>>>      =20
>> I tried to explain in my original post:  The problem arises when
>> when the hard-start-xmit fails with NETDEV_TX_BUSY.  Part of the
>> hard-start-xmit logic for virtual devices can call dev_queue_xmit, w=
hich
>> can ultimately
>> change the queue mapping and yet may still return NETDEV_TX_BUSY.
>>
>> pktgen would try to resend this skb next loop, and this is where it =
would
>> blow up.
>>
>> I have a patched macvlan logic and a patched dev queue xmit logic th=
at
>> allows
>> me to return NETDEV_TX_BUSY when underlying device fails to transmit=
=2E
>>
>> It may be that my hacked macvlan is the only virtual device that cou=
ld ever
>> return NETDEV_TX_BUSY, and if that is the case, I don't think the bu=
g
>> could ever be hit in official kernel code.  My opinion is that the
>> current pktgen code makes
>> too many assumptions, so unless there is a performance penalty, I st=
ill
>> think it should be cleaned up.  But, I may be too paranoid.
>>    =20
>
> If a virtual device changes skb->queue_map, it must consume skb,
> or it breaks caller.
>  =20
> Alternative would be to restore queue_map to its initial value in
> your hacked macvlan when it wants to return NETDEV_TX_BUSY status.
>  =20
Yeah, that sounds fine to me, should be easy and cheap.
> We could add a WARN_ON(skb_get_queue_mapping(pkt_dev->skb) !=3D queue=
_map);
> in pktgen, to catch driver errors but pktgen assumption is right IMHO
>
> @@ -3466,6 +3471,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_=
dev)
>  		/* fallthru */
>  	case NETDEV_TX_LOCKED:
>  	case NETDEV_TX_BUSY:
> +		WARN_ON(skb_get_queue_mapping(pkt_dev->skb) !=3D queue_map);
>  		/* Retry it next time */
>  		atomic_dec(&(pkt_dev->skb->users));
>  		pkt_dev->last_ok =3D 0;
>  =20
That looks good too.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>=20
Candela Technologies Inc  http://www.candelatech.com


