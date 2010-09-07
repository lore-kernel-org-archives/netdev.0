From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Tue, 7 Sep 2010 09:16:14 +0000
Message-ID: <20100907091614.GA8245@ff.dom.local>
References: <1283835729.2585.499.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57122 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118Ab0IGJQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 05:16:20 -0400
Received: by bwz11 with SMTP id 11so3907769bwz.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 02:16:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283835729.2585.499.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-07 07:02, Eric Dumazet wrote:
> Le lundi 06 septembre 2010 =C3  19:20 -0700, David Miller a =C3=A9cri=
t :
>=20
>> Eric, this goes on top of your patch and demonstrates the idea.
>>
>> Please review if you have a chance:
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 2d1bc76..aeb56af 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -327,6 +327,32 @@ static void skb_clone_fraglist(struct sk_buff *=
skb)
>>  		skb_get(list);
>>  }
>> =20
>> +static struct sk_buff *skb_copy_fraglist(struct sk_buff *parent,
>> +					 gfp_t gfp_mask)
>> +{
>> +	struct sk_buff *first_skb =3D NULL;
>> +	struct sk_buff *prev_skb =3D NULL;
>> +	struct sk_buff *skb;
>> +
>> +	skb_walk_frags(parent, skb) {
>> +		struct sk_buff *nskb =3D pskb_copy(skb, gfp_mask);
>> +
>> +		if (!nskb)
>> +			goto fail;
>> +		if (!first_skb)
>> +			first_skb =3D skb;
>> +		else
>> +			prev_skb->next =3D skb;
>> +		prev_skb =3D skb;
>> +	}
>> +
>> +	return first_skb;
>> +
>> +fail:
>> +	skb_drop_list(&first_skb);
>> +	return NULL;
>> +}
>> +
>>  static void skb_release_data(struct sk_buff *skb)
>>  {
>>  	if (!skb->cloned ||
>> @@ -812,17 +838,22 @@ int pskb_expand_head(struct sk_buff *skb, int =
nhead, int ntail,
>>  		fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=3D delta;
>>  	}
>> =20
>> -	if (fastpath) {
>> -		kfree(skb->head);
>> -	} else {
>> +	if (!fastpath) {
>> +		if (skb_has_frag_list(skb)) {
>> +			struct sk_buff *new_list;
>> +
>> +			new_list =3D skb_copy_fraglist(skb, gfp_mask);
>> +			if (!new_list)
>> +				goto free_data;
>> +			skb_shinfo(skb)->frag_list =3D new_list;
>=20
> Here, skb_shinfo(skb) still points to old shinfo, you should not touc=
h
> it. An other user might need it :)

Even if there were no users this is written to the area freed with
kfree(skb->head) a few lines later, isn't it?

>=20
>> +		}
>>  		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
>>  			get_page(skb_shinfo(skb)->frags[i].page);
>> =20
>> -		if (skb_has_frag_list(skb))
>> -			skb_clone_fraglist(skb);
>> -
>> -		skb_release_data(skb);
>>  	}
>=20
> I believe you cannot remove skb_release_data() call, we really need t=
o
> perform the atomic operation, and test the result on it, or a double
> free could happen.
>=20
>> +
>> +	kfree(skb->head);
>> +
>>  	off =3D (data + nhead) - skb->head;
>> =20
>>  	skb->head     =3D data;
>> @@ -848,6 +879,8 @@ int pskb_expand_head(struct sk_buff *skb, int nh=
ead, int ntail,
>>  	atomic_set(&skb_shinfo(skb)->dataref, 1);
>>  	return 0;
>> =20
>> +free_data:
>> +	kfree(data);
>=20
> is it a leftover ?
>=20
>>  nodata:
>>  	return -ENOMEM;
>>  }
>=20
> I understand what you want to do, but problem is we need to perform a
> CAS2 operation : atomically changes two values (dataref and frag_list=
)

Alas I can't understand why do you think these clone and atomic tests
in skb_release_data() don't protect skb_shinfo(skb)->frag_list enough.

Jarek P.
