From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2] netlink: align attributes on 64-bits
Date: Tue, 18 Dec 2012 11:18:23 +0100
Message-ID: <50D042EF.7000109@6wind.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F1@saturn3.aculab.com> <50CF57DC.5050804@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F2@saturn3.aculab.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, tgraf@suug.ch, netdev@vger.kernel.org,
	davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:48413 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab2LRKqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:46:24 -0500
Received: by mail-we0-f169.google.com with SMTP id t49so215440wey.14
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 02:46:21 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70F2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/12/2012 10:19, David Laight a =E9crit :
>> Le 17/12/2012 18:06, David Laight a =E9crit :
>>>>    int nla_put(struct sk_buff *skb, int attrtype, int attrlen, con=
st void *data)
>>>>    {
>>>> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
>>>> +	int align =3D IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8=
) ? 0 : 4;
>>>
>>> I've just realised where you are adding this!
>>> You only want to add pad if the attribute is a single 64bit item,
>>> not whenever the destination is misaligned.
>> As said in the commit log, I want to align all attributes. An attrib=
ute can be
>> like this:
>>
>> struct foo {
>> 	__u32 bar1;
>> 	__u32 bar2;
>> 	__u64 bar3;
>> }
>>
>> nla_put() don't know what is contained in the attribute.
>
> Put there is no need to 8-byte align something whose size isn't a
> multiple of 8 bytes.
Even if you cast the structure in a buffer and read bar3 (without any m=
emcpy=20
before)?

>
>>> ...
>>>> +	if (align) {
>>>> +		/* Goal is to add an attribute with size 4. We know that
>>>> +		 * NLA_HDRLEN is 4, hence payload is 0.
>>>> +		 */
>>>> +		__nla_reserve(skb, 0, 0);
>>>
>>> One of those zeros should be 'align - 4', then the comment
>>> can be more descriptive.
>
>> I thought if you were to research why we use 0, you would know that =
the first 0
>> is the type and the second is the payload size...
>
> I can tell that one is the type and the other the size, you've
> implied that the 'type+size' actually total 4 bytes.
> I don't need to find out which is which!
> Now you've told me I'd have written:
> 	_nla_reserve(skb, 0, align - NLA_HDRLEN);
>
> The compiler could well have tracked the value - so know it is 4.
> OTOH you might want to generate the size of 'align' without
> using a conditional.
Yes, it is the goal ;-)
