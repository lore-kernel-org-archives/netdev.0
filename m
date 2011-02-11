From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] network: Allow af_packet to transmit +4 bytes for
 VLAN packets.
Date: Fri, 11 Feb 2011 09:38:26 -0800
Message-ID: <4D557412.7000209@candelatech.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>	 <1297375149-18458-2-git-send-email-greearb@candelatech.com> <1297407446.2493.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49174 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756811Ab1BKRid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 12:38:33 -0500
In-Reply-To: <1297407446.2493.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2011 10:57 PM, Eric Dumazet wrote:
> Le jeudi 10 f=C3=A9vrier 2011 =C3=A0 13:59 -0800, greearb@candelatech=
=2Ecom a
> =C3=A9crit :
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows user-space to send a '1500' MTU VLAN packet on a
>> 1500 MTU ethernet frame.  The extra 4 bytes of a VLAN header is
>> not usually charged against the MTU when other parts of the
>> network stack is transmitting vlans...
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 91cb1d7... ef7f378... M	net/packet/af_packet.c
>>   net/packet/af_packet.c |   31 +++++++++++++++++++++++++++++--
>>   1 files changed, 29 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 91cb1d7..ef7f378 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -466,7 +466,7 @@ retry:
>>   	 */
>>
>>   	err =3D -EMSGSIZE;
>> -	if (len>  dev->mtu + dev->hard_header_len)
>> +	if (len>  dev->mtu + dev->hard_header_len + VLAN_HLEN)
>>   		goto out_unlock;
>>
>>   	if (!skb) {
>> @@ -497,6 +497,19 @@ retry:
>>   		goto retry;
>>   	}
>>
>> +	if (len>  (dev->mtu + dev->hard_header_len)) {
>> +		/* Earlier code assumed this would be a VLAN pkt,
>> +		 * double-check this now that we have the actual
>> +		 * packet in hand.
>> +		 */
>> +		struct ethhdr *ehdr;
>> +		skb_reset_mac_header(skb);
>> +		ehdr =3D eth_hdr(skb);
>> +		if (ehdr->h_proto !=3D htons(ETH_P_8021Q)) {
>> +			err =3D -EMSGSIZE;
>> +			goto out_unlock;
>
> This would leak skb.
>
>> +		}
>> +	}
>>
>>   	skb->protocol =3D proto;
>>   	skb->dev =3D dev;

Can you double-check that?  Seems to me that in that method the out_unl=
ock
falls through to the out_free case.  The other method is the opposite, =
funny
enough...

Thanks,
Ben

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

