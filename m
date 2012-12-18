From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2] netlink: align attributes on 64-bits
Date: Tue, 18 Dec 2012 23:07:26 +0100
Message-ID: <50D0E91E.3050702@6wind.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <20121218125735.GG27746@casper.infradead.org> <50D09897.8030508@6wind.com> <20121218170853.GH27746@casper.infradead.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	davem@davemloft.net, David.Laight@ACULAB.COM
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:60058 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397Ab2LRWHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 17:07:31 -0500
Received: by mail-wg0-f53.google.com with SMTP id ei8so585710wgb.32
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 14:07:29 -0800 (PST)
In-Reply-To: <20121218170853.GH27746@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/12/2012 18:08, Thomas Graf a =E9crit :
> On 12/18/12 at 05:23pm, Nicolas Dichtel wrote:
>> Le 18/12/2012 13:57, Thomas Graf a =E9crit :
>>> -static inline int nla_padlen(int payload)
>>> -{
>>> -	return nla_total_size(payload) - nla_attr_size(payload);
>>> +	if (!IS_ALIGNED(len, NLA_ATTR_ALIGN))
>>> +		len =3D ALIGN(len + NLA_HDRLEN, NLA_ATTR_ALIGN);
>> Two comments:
>> 1/ should it be ALIGN(len, NLA_ATTR_ALIGN)? If we want to add a __u6=
4:
>>     =3D> nla_attr_size(sizeof(__u64)) =3D 12
>>     =3D> NLA_ALIGN(nla_attr_size(sizeof(__u64))) =3D> 12 (=3D len)
>>     =3D> ALIGN(len + NLA_HDRLEN, NLA_ATTR_ALIGN) =3D 0 but it should=
 be 4
>
> We can't add 1-3 bytes of padding, therefore we need to add
> NLA_HDRLEN to len before aligning it to enforce a minimal
> padding. We can't hit it right now because 4 byte alignment
> of the previous attribute is a given but if we ever change
> the alignment it could become an issue and the above should
> be bullet proof.
>
> Your example would come out like this:
>    nla_attr_size(8) =3D 12
>    ALIGN(12 + 4, 8) =3D 16
Got it, right.

>
>> 2/ Suppose that the attribute is:
>>
>>    struct foo {
>>    	__u64 bar1;
>>    	__u32 bar2;
>>    }
>>    =3D> sizeof(struct foo) =3D 12 (=3D payload)
>>    =3D> nla_attr_size(payload) =3D 16
>>    =3D> NLA_ALIGN(nla_attr_size(payload)) =3D 16 (=3D len)
>>    =3D> IS_ALIGNED(len, NLA_ATTR_ALIGN) =3D true
>>    =3D> extra room is not reserved
>>    But it's not guaranteed that bar1 is aligned on 8 bytes, only on =
4 bytes.
>
> That's correct, that's why I have added the additional
> NLA_ATTR_ALIGN of room in nlmsg_new(). It will account
> for the one time padding that is needed before we add
> the very first attribute.
>
> If all attributes after that have a size aligned to 8
> bytes no padding is needed. Padding will only be needed
> again if a struct is missized in which case we reserve
> room with the above. Correct?
Seems good ;-)

>
>>> +	offset =3D (size_t) skb_tail_pointer(skb);
>>> +	if (!IS_ALIGNED(offset + NLA_HDRLEN, NLA_ATTR_ALIGN)) {
>> With the previous struct foo, this test may be true even if we don't
>> have reserved extra room. This test depends on previous attribute.
>> I think the exact size of the netlink message depends on the order
>> of attributes, not only on the attribute itself.
>> What about taking the assumption that the start will never be
>> aligned and always allocating extra room: ALIGN(NLA_ALIGNTO,
>> NLA_ATTR_ALIGN) (=3D 4)?
>
> See my explanation above. I think this works. The order does not
> matter, the sum of all padding required will always be the same.
I will do more test.

>
>>> +static bool nla_insufficient_space(struct sk_buff *skb, int attrle=
n)
>>> +{
>>> +	size_t needed =3D nla_pre_padlen(skb) + nla_total_size(attrlen);
>> If nla_total_size() was right, nla_pre_padlen(skb) should already be
>> included. Am I wrong?
>
> No, nla_pre_padlen() contains the number of bytes needed to align
> skb_tail_pointer() to an alignment of 8. If that is > 0 but the
> attribute to follow is already aligned.
>
> The tricky part here is that accounting for padding in
> nla_total_size() only works for the sum of all attributes.
> It does not account for the specific padding required for the
> previous attribute.
>
> Therefore the above check. The above could be changed to
> nla_attr_size() theoretically as we don't need space for the
> final padding eventually but we checked for space before so I
> kept it that way.
>
> I realize it's slightly confusign and needs better documentation
> and please double check my thinking :-)
Ok, you convince me ;-)
