From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v2] skbuff: align sk_buff::cb to 64 bit
Date: Mon, 01 Feb 2010 19:37:45 +0100
Message-ID: <4B671F79.8090808@openwrt.org>
References: <4B637F85.8080809@openwrt.org> <1264835220.2919.10.camel@edumazet-laptop> <4B671CEB.5080505@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:44923 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755274Ab0BAShv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 13:37:51 -0500
In-Reply-To: <4B671CEB.5080505@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-02-01 7:26 PM, David Daney wrote:
> Eric Dumazet wrote:
>> Le samedi 30 janvier 2010 =C3=A0 01:38 +0100, Felix Fietkau a =C3=A9=
crit :
>>> The alignment requirement for 64-bit load/store instructions on ARM=
 is
>>> implementation defined. Some CPUs (such as Marvell Feroceon) do not
>>> generate an exception, if such an instruction is executed with an
>>> address that is not 64 bit aligned. In such a case, the Feroceon
>>> corrupts adjacent memory, which showed up
>>> in my tests as a crash in the rx path of ath9k that only occured wi=
th
>>> CONFIG_XFRM set. This crash happened, because the first field of th=
e
>>> mac80211 rx status info in the cb is an u64, and changing it corrup=
ted
>>> the skb->sp field.
>>>
>>> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>>> Cc: stable@kernel.org
>>> ---
>>> --- a/include/linux/skbuff.h
>>> +++ b/include/linux/skbuff.h
>>> @@ -329,7 +329,7 @@ struct sk_buff {
>>>  	 * want to keep them across layers you have to do a skb_clone()
>>>  	 * first. This is owned by whoever has the skb queued ATM.
>>>  	 */
>>> -	char			cb[48];
>>> +	char			cb[48] __aligned(8);
>>>   	unsigned int		len,
>>>  				data_len;
>>>
>>> --
>>=20
>> Without a detailed analysis of holes added on x86_32 and/or x86_64, =
I
>> guess this patch is not acceptable as is.
>>=20
>> You certainly can find a better way to do this, without adding holes=
 in
>> sk_buff structure. Size matters a lot :)
>>=20
>=20
> Can't we just move cb[] up so that it comes after an even number of=20
> pointers under all configs?
>=20
> Then perhaps add __aligned(8) to the entire structure instead of just=
=20
> this field.
Makes sense, I'll send a patch for that.

> Alternatively, could you fix the driver so that it adds the necessary=
=20
> alignment to its use of the cb[] array?
>=20
> How common it it to have sizeof(void *) =3D=3D 4 *and* require 8-byte=
=20
> alignment on other things?  cb[] is fairly large, can you afford to b=
urn=20
> 4 bytes for alignment purposes in your driver?
No, I can't afford to burn a single byte on this, in some places
mac80211 uses all of the cb[] area up to the last byte.

- Felix
