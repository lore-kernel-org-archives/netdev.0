From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2] netlink: align attributes on 64-bits
Date: Mon, 17 Dec 2012 18:35:24 +0100
Message-ID: <50CF57DC.5050804@6wind.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F1@saturn3.aculab.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, tgraf@suug.ch, netdev@vger.kernel.org,
	davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37300 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107Ab2LQRf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 12:35:29 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so3392011eek.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 09:35:27 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70F1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/12/2012 18:06, David Laight a =E9crit :
>>   int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const =
void *data)
>>   {
>> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
>> +	int align =3D IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8) =
? 0 : 4;
>
> I've just realised where you are adding this!
> You only want to add pad if the attribute is a single 64bit item,
> not whenever the destination is misaligned.
As said in the commit log, I want to align all attributes. An attribute=
 can be=20
like this:

struct foo {
	__u32 bar1;
	__u32 bar2;
	__u64 bar3;
}

nla_put() don't know what is contained in the attribute.

>
> Eg what happens if you add a 4-byte item after an 8 byte one.
>
> Are there are attributes that consist of a pair of 4 byte values?
>
> ...
>> +	if (align) {
>> +		/* Goal is to add an attribute with size 4. We know that
>> +		 * NLA_HDRLEN is 4, hence payload is 0.
>> +		 */
>> +		__nla_reserve(skb, 0, 0);
>
> One of those zeros should be 'align - 4', then the comment
> can be more descriptive.
I thought if you were to research why we use 0, you would know that the=
 first 0=20
is the type and the second is the payload size...
