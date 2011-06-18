From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC 4/5] net:  Support sending frame with specified FCS.
Date: Sat, 18 Jun 2011 07:29:19 -0700
Message-ID: <4DFCB63F.7030301@candelatech.com>
References: <1308355783-22407-1-git-send-email-greearb@candelatech.com>	 <1308355783-22407-5-git-send-email-greearb@candelatech.com> <1308376473.3539.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38686 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab1FRO3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 10:29:21 -0400
In-Reply-To: <1308376473.3539.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2011 10:54 PM, Eric Dumazet wrote:
> Le vendredi 17 juin 2011 =C3=A0 17:09 -0700, greearb@candelatech.com =
a
> =C3=A9crit :
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows user-space to send a packet with the
>> ethernet FCS appended to the end.  Supporting NICs
>> will know to disable their own FCS calculations and
>> send frame as is.
>>
>> This is useful for injecting bad frames on a network
>> for testing.

>> diff --git a/include/asm-generic/socket.h b/include/asm-generic/sock=
et.h
>> index 9a6115e..22193a2 100644
>> --- a/include/asm-generic/socket.h
>> +++ b/include/asm-generic/socket.h
>> @@ -64,4 +64,11 @@
>>   #define SO_DOMAIN		39
>>
>>   #define SO_RXQ_OVFL             40
>> +
>> +/* Instruct lower device to not calculate the frame
>> + * checksum.  Useful for generating Ethernet frames
>> + * with custom checksums.
>> + */
>> +#define SO_NOFCS		41
>> +
>
> Please take a look at :
>
> arch/*/include/asm/socket.h for many arches.

Do I need to update each file, or just make sure the value in
asm-generic/socket.h is unique for all of them?

>> +	if (unlikely(sk->sk_flags&  SOCK_DONT_DO_LL_FCS))
>> +		skb->use_specified_ether_crc =3D 1;
>> +	else
>> +		skb->use_specified_ether_crc =3D 0;
>> +
>
> Manipulating a bit field is very expensive, and having an else branch=
 is
> expensive as well, so please avoid setting crc to zero if its already
> guaranteed to be so.

Ok, I'll double-check that it is zero by default. and fix that.

> Also I cant see where you actually _set_ the fcs value : that might
> trigger a kmemcheck warning later when we read it.

It is the last 4 bytes of the payload passed in from user-space.

>>   	dev_queue_xmit(skb);
>>   	rcu_read_unlock();
>>   	return len;
>> @@ -1134,6 +1143,10 @@ static int packet_snd(struct socket *sock,
>>   	int vnet_hdr_len;
>>   	struct packet_sock *po =3D pkt_sk(sk);
>>   	unsigned short gso_type =3D 0;
>> +	int kludge =3D 0;
>> +
>> +	if (unlikely(sk->sk_flags&  SOCK_DONT_DO_LL_FCS))
>> +		kludge =3D 4; /* We're doing our own Ethernet FCS */
>
> kludge ? You mean fcs_len or something ? ;)

Err, yeah :)

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
