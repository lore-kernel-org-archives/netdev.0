From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH RFC] Clean up sk_buff walkers
Date: Wed, 4 Apr 2007 18:03:04 +0200
Message-ID: <200704041803.04776.jdelvare@suse.de>
References: <200703200819.50363.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:60001 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992979AbXDDQDD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 12:03:03 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 4CC5D1226A
	for <netdev@vger.kernel.org>; Wed,  4 Apr 2007 18:03:02 +0200 (CEST)
In-Reply-To: <200703200819.50363.jdelvare@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Mardi 20 Mars 2007 08:19, Jean Delvare a =E9crit=A0:
> I noticed recently that, in skb_checksum(), "offset" and "start" are
> essentially the same thing and have the same value throughout the
> function, despite being computed differently. Using a single variable
> allows some cleanups and makes the skb_checksum() function smaller,
> more readable, and presumably marginally faster.
>
> We appear to have many other "sk_buff walker" functions built on the
> exact same model, so the cleanup applies to them, too. Here is a list
> of the functions I found to be affected:
>
> net/appletalk/ddp.c:atalk_sum_skb()
> net/core/datagram.c:skb_copy_datagram_iovec()
> net/core/datagram.c:skb_copy_and_csum_datagram()
> net/core/skbuff.c:skb_copy_bits()
> net/core/skbuff.c:skb_store_bits()
> net/core/skbuff.c:skb_checksum()
> net/core/skbuff.c:skb_copy_and_csum_bit()
> net/core/user_dma.c:dma_skb_copy_datagram_iovec()
> net/xfrm/xfrm_algo.c:skb_icv_walk()
> net/xfrm/xfrm_algo.c:skb_to_sgvec()
>
> OTOH, I admit I'm a bit surprised, the cleanup is rather obvious so
> I'm really wondering if I am missing something. Can anyone please
> comment on this?

Hmm, no comment? The cleanup seems worth the effort, both for source
code readability and binary size.

> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> ---
>  net/appletalk/ddp.c  |   25 +++++--------
>  net/core/datagram.c  |   50 ++++++++----------------
>  net/core/skbuff.c    |  100 +++++++++++++++++-----------------------=
---------
>  net/core/user_dma.c  |   25 +++++--------
>  net/xfrm/xfrm_algo.c |   44 ++++++++--------------
>  5 files changed, 86 insertions(+), 158 deletions(-)
>
> --- linux-2.6.21-rc4.orig/net/core/skbuff.c	2007-03-19
> 09:23:49.000000000 +0100 +++
> linux-2.6.21-rc4/net/core/skbuff.c	2007-03-20 07:12:45.000000000
> +0100 @@ -1081,13 +1081,13 @@ pull_pages:
>  int skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
> int len) {
>  	int i, copy;
> -	int start =3D skb_headlen(skb);
> +	int end =3D skb_headlen(skb);
>
>  	if (offset > (int)skb->len - len)
>  		goto fault;
>
>  	/* Copy header. */
> -	if ((copy =3D start - offset) > 0) {
> +	if ((copy =3D end - offset) > 0) {
>  		if (copy > len)
>  			copy =3D len;
>  		memcpy(to, skb->data + offset, copy);
> @@ -1098,11 +1098,9 @@ int skb_copy_bits(const struct sk_buff *
>  	}
>
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			u8 *vaddr;
>
> @@ -1111,8 +1109,8 @@ int skb_copy_bits(const struct sk_buff *
>
>  			vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
>  			memcpy(to,
> -			       vaddr + skb_shinfo(skb)->frags[i].page_offset+
> -			       offset - start, copy);
> +			       vaddr + skb_shinfo(skb)->frags[i].page_offset,
> +			       copy);
>  			kunmap_skb_frag(vaddr);
>
>  			if ((len -=3D copy) =3D=3D 0)
> @@ -1120,30 +1118,25 @@ int skb_copy_bits(const struct sk_buff *
>  			offset +=3D copy;
>  			to     +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				if (copy > len)
>  					copy =3D len;
> -				if (skb_copy_bits(list, offset - start,
> -						  to, copy))
> +				if (skb_copy_bits(list, 0, to, copy))
>  					goto fault;
>  				if ((len -=3D copy) =3D=3D 0)
>  					return 0;
>  				offset +=3D copy;
>  				to     +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	if (!len)
> @@ -1168,12 +1161,12 @@ fault:
>  int skb_store_bits(const struct sk_buff *skb, int offset, void
> *from, int len) {
>  	int i, copy;
> -	int start =3D skb_headlen(skb);
> +	int end =3D skb_headlen(skb);
>
>  	if (offset > (int)skb->len - len)
>  		goto fault;
>
> -	if ((copy =3D start - offset) > 0) {
> +	if ((copy =3D end - offset) > 0) {
>  		if (copy > len)
>  			copy =3D len;
>  		memcpy(skb->data + offset, from, copy);
> @@ -1185,11 +1178,9 @@ int skb_store_bits(const struct sk_buff
>
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + frag->size;
> +		end =3D offset + frag->size;
>  		if ((copy =3D end - offset) > 0) {
>  			u8 *vaddr;
>
> @@ -1197,8 +1188,7 @@ int skb_store_bits(const struct sk_buff
>  				copy =3D len;
>
>  			vaddr =3D kmap_skb_frag(frag);
> -			memcpy(vaddr + frag->page_offset + offset - start,
> -			       from, copy);
> +			memcpy(vaddr + frag->page_offset, from, copy);
>  			kunmap_skb_frag(vaddr);
>
>  			if ((len -=3D copy) =3D=3D 0)
> @@ -1206,30 +1196,25 @@ int skb_store_bits(const struct sk_buff
>  			offset +=3D copy;
>  			from +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				if (copy > len)
>  					copy =3D len;
> -				if (skb_store_bits(list, offset - start,
> -						   from, copy))
> +				if (skb_store_bits(list, 0, from, copy))
>  					goto fault;
>  				if ((len -=3D copy) =3D=3D 0)
>  					return 0;
>  				offset +=3D copy;
>  				from +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	if (!len)
> @@ -1246,8 +1231,8 @@ EXPORT_SYMBOL(skb_store_bits);
>  __wsum skb_checksum(const struct sk_buff *skb, int offset,
>  			  int len, __wsum csum)
>  {
> -	int start =3D skb_headlen(skb);
> -	int i, copy =3D start - offset;
> +	int end =3D skb_headlen(skb);
> +	int i, copy =3D end - offset;
>  	int pos =3D 0;
>
>  	/* Checksum header. */
> @@ -1262,11 +1247,9 @@ __wsum skb_checksum(const struct sk_buff
>  	}
>
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			__wsum csum2;
>  			u8 *vaddr;
> @@ -1275,8 +1258,8 @@ __wsum skb_checksum(const struct sk_buff
>  			if (copy > len)
>  				copy =3D len;
>  			vaddr =3D kmap_skb_frag(frag);
> -			csum2 =3D csum_partial(vaddr + frag->page_offset +
> -					     offset - start, copy, 0);
> +			csum2 =3D csum_partial(vaddr + frag->page_offset,
> +					     copy, 0);
>  			kunmap_skb_frag(vaddr);
>  			csum =3D csum_block_add(csum, csum2, pos);
>  			if (!(len -=3D copy))
> @@ -1284,31 +1267,26 @@ __wsum skb_checksum(const struct sk_buff
>  			offset +=3D copy;
>  			pos    +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				__wsum csum2;
>  				if (copy > len)
>  					copy =3D len;
> -				csum2 =3D skb_checksum(list, offset - start,
> -						     copy, 0);
> +				csum2 =3D skb_checksum(list, 0, copy, 0);
>  				csum =3D csum_block_add(csum, csum2, pos);
>  				if ((len -=3D copy) =3D=3D 0)
>  					return csum;
>  				offset +=3D copy;
>  				pos    +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	BUG_ON(len);
> @@ -1321,8 +1299,8 @@ __wsum skb_checksum(const struct sk_buff
>  __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
>  				    u8 *to, int len, __wsum csum)
>  {
> -	int start =3D skb_headlen(skb);
> -	int i, copy =3D start - offset;
> +	int end =3D skb_headlen(skb);
> +	int i, copy =3D end - offset;
>  	int pos =3D 0;
>
>  	/* Copy header. */
> @@ -1339,11 +1317,9 @@ __wsum skb_copy_and_csum_bits(const stru
>  	}
>
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			__wsum csum2;
>  			u8 *vaddr;
> @@ -1353,9 +1329,8 @@ __wsum skb_copy_and_csum_bits(const stru
>  				copy =3D len;
>  			vaddr =3D kmap_skb_frag(frag);
>  			csum2 =3D csum_partial_copy_nocheck(vaddr +
> -							  frag->page_offset +
> -							  offset - start, to,
> -							  copy, 0);
> +							  frag->page_offset,
> +							  to, copy, 0);
>  			kunmap_skb_frag(vaddr);
>  			csum =3D csum_block_add(csum, csum2, pos);
>  			if (!(len -=3D copy))
> @@ -1364,7 +1339,6 @@ __wsum skb_copy_and_csum_bits(const stru
>  			to     +=3D copy;
>  			pos    +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
> @@ -1372,16 +1346,13 @@ __wsum skb_copy_and_csum_bits(const stru
>
>  		for (; list; list =3D list->next) {
>  			__wsum csum2;
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				if (copy > len)
>  					copy =3D len;
> -				csum2 =3D skb_copy_and_csum_bits(list,
> -							       offset - start,
> +				csum2 =3D skb_copy_and_csum_bits(list, 0,
>  							       to, copy, 0);
>  				csum =3D csum_block_add(csum, csum2, pos);
>  				if ((len -=3D copy) =3D=3D 0)
> @@ -1390,7 +1361,6 @@ __wsum skb_copy_and_csum_bits(const stru
>  				to     +=3D copy;
>  				pos    +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	BUG_ON(len);
> --- linux-2.6.21-rc4.orig/net/core/datagram.c	2007-02-21
> 08:36:31.000000000 +0100 +++
> linux-2.6.21-rc4/net/core/datagram.c	2007-03-19 21:13:04.000000000
> +0100 @@ -247,8 +247,8 @@ EXPORT_SYMBOL(skb_kill_datagram);
>  int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
>  			    struct iovec *to, int len)
>  {
> -	int start =3D skb_headlen(skb);
> -	int i, copy =3D start - offset;
> +	int end =3D skb_headlen(skb);
> +	int i, copy =3D end - offset;
>
>  	/* Copy header. */
>  	if (copy > 0) {
> @@ -263,11 +263,9 @@ int skb_copy_datagram_iovec(const struct
>
>  	/* Copy paged appendix. Hmm... why does this look so complicated?
> */ for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			int err;
>  			u8  *vaddr;
> @@ -277,8 +275,8 @@ int skb_copy_datagram_iovec(const struct
>  			if (copy > len)
>  				copy =3D len;
>  			vaddr =3D kmap(page);
> -			err =3D memcpy_toiovec(to, vaddr + frag->page_offset +
> -					     offset - start, copy);
> +			err =3D memcpy_toiovec(to, vaddr + frag->page_offset,
> +					     copy);
>  			kunmap(page);
>  			if (err)
>  				goto fault;
> @@ -286,30 +284,24 @@ int skb_copy_datagram_iovec(const struct
>  				return 0;
>  			offset +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				if (copy > len)
>  					copy =3D len;
> -				if (skb_copy_datagram_iovec(list,
> -							    offset - start,
> -							    to, copy))
> +				if (skb_copy_datagram_iovec(list, 0, to, copy))
>  					goto fault;
>  				if ((len -=3D copy) =3D=3D 0)
>  					return 0;
>  				offset +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	if (!len)
> @@ -323,9 +315,9 @@ static int skb_copy_and_csum_datagram(co
>  				      u8 __user *to, int len,
>  				      __wsum *csump)
>  {
> -	int start =3D skb_headlen(skb);
> +	int end =3D skb_headlen(skb);
>  	int pos =3D 0;
> -	int i, copy =3D start - offset;
> +	int i, copy =3D end - offset;
>
>  	/* Copy header. */
>  	if (copy > 0) {
> @@ -344,11 +336,9 @@ static int skb_copy_and_csum_datagram(co
>  	}
>
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			__wsum csum2;
>  			int err =3D 0;
> @@ -360,8 +350,7 @@ static int skb_copy_and_csum_datagram(co
>  				copy =3D len;
>  			vaddr =3D kmap(page);
>  			csum2 =3D csum_and_copy_to_user(vaddr +
> -							frag->page_offset +
> -							offset - start,
> +							frag->page_offset,
>  						      to, copy, 0, &err);
>  			kunmap(page);
>  			if (err)
> @@ -373,24 +362,20 @@ static int skb_copy_and_csum_datagram(co
>  			to +=3D copy;
>  			pos +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list=3Dlist->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				__wsum csum2 =3D 0;
>  				if (copy > len)
>  					copy =3D len;
> -				if (skb_copy_and_csum_datagram(list,
> -							       offset - start,
> +				if (skb_copy_and_csum_datagram(list, 0,
>  							       to, copy,
>  							       &csum2))
>  					goto fault;
> @@ -401,7 +386,6 @@ static int skb_copy_and_csum_datagram(co
>  				to +=3D copy;
>  				pos +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	if (!len)
> --- linux-2.6.21-rc4.orig/net/core/user_dma.c	2007-02-21
> 08:36:31.000000000 +0100 +++
> linux-2.6.21-rc4/net/core/user_dma.c	2007-03-20 07:16:27.000000000
> +0100 @@ -49,8 +49,8 @@ int dma_skb_copy_datagram_iovec(struct d
>  			struct sk_buff *skb, int offset, struct iovec *to,
>  			size_t len, struct dma_pinned_list *pinned_list)
>  {
> -	int start =3D skb_headlen(skb);
> -	int i, copy =3D start - offset;
> +	int end =3D skb_headlen(skb);
> +	int i, copy =3D end - offset;
>  	dma_cookie_t cookie =3D 0;
>
>  	/* Copy header. */
> @@ -69,11 +69,9 @@ int dma_skb_copy_datagram_iovec(struct d
>
>  	/* Copy paged appendix. Hmm... why does this look so complicated?
> */ for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		copy =3D end - offset;
>  		if ((copy =3D end - offset) > 0) {
>  			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> @@ -82,8 +80,8 @@ int dma_skb_copy_datagram_iovec(struct d
>  			if (copy > len)
>  				copy =3D len;
>
> -			cookie =3D dma_memcpy_pg_to_iovec(chan, to, pinned_list, page,
> -					frag->page_offset + offset - start, copy);
> +			cookie =3D dma_memcpy_pg_to_iovec(chan, to, pinned_list,
> +					page, frag->page_offset, copy);
>  			if (cookie < 0)
>  				goto fault;
>  			len -=3D copy;
> @@ -91,25 +89,21 @@ int dma_skb_copy_datagram_iovec(struct d
>  				goto end;
>  			offset +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			copy =3D end - offset;
>  			if (copy > 0) {
>  				if (copy > len)
>  					copy =3D len;
>  				cookie =3D dma_skb_copy_datagram_iovec(chan, list,
> -						offset - start, to, copy,
> -						pinned_list);
> +						0, to, copy, pinned_list);
>  				if (cookie < 0)
>  					goto fault;
>  				len -=3D copy;
> @@ -117,7 +111,6 @@ int dma_skb_copy_datagram_iovec(struct d
>  					goto end;
>  				offset +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>
> --- linux-2.6.21-rc4.orig/net/xfrm/xfrm_algo.c	2007-03-19
> 21:34:08.000000000 +0100 +++
> linux-2.6.21-rc4/net/xfrm/xfrm_algo.c	2007-03-19 21:41:59.000000000
> +0100 @@ -532,8 +532,8 @@ EXPORT_SYMBOL_GPL(xfrm_count_enc_support
> int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *desc,
> int offset, int len, icv_update_fn_t icv_update)
>  {
> -	int start =3D skb_headlen(skb);
> -	int i, copy =3D start - offset;
> +	int end =3D skb_headlen(skb);
> +	int i, copy =3D end - offset;
>  	int err;
>  	struct scatterlist sg;
>
> @@ -556,11 +556,9 @@ int skb_icv_walk(const struct sk_buff *s
>  	}
>
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
>
> @@ -568,7 +566,7 @@ int skb_icv_walk(const struct sk_buff *s
>  				copy =3D len;
>
>  			sg.page =3D frag->page;
> -			sg.offset =3D frag->page_offset + offset-start;
> +			sg.offset =3D frag->page_offset;
>  			sg.length =3D copy;
>
>  			err =3D icv_update(desc, &sg, copy);
> @@ -579,22 +577,19 @@ int skb_icv_walk(const struct sk_buff *s
>  				return 0;
>  			offset +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				if (copy > len)
>  					copy =3D len;
> -				err =3D skb_icv_walk(list, desc, offset-start,
> +				err =3D skb_icv_walk(list, desc, 0,
>  						   copy, icv_update);
>  				if (unlikely(err))
>  					return err;
> @@ -602,7 +597,6 @@ int skb_icv_walk(const struct sk_buff *s
>  					return 0;
>  				offset +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	BUG_ON(len);
> @@ -617,8 +611,8 @@ EXPORT_SYMBOL_GPL(skb_icv_walk);
>  int
>  skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int
> offset, int len) {
> -	int start =3D skb_headlen(skb);
> -	int i, copy =3D start - offset;
> +	int end =3D skb_headlen(skb);
> +	int i, copy =3D end - offset;
>  	int elt =3D 0;
>
>  	if (copy > 0) {
> @@ -634,45 +628,39 @@ skb_to_sgvec(struct sk_buff *skb, struct
>  	}
>
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
>
>  			if (copy > len)
>  				copy =3D len;
>  			sg[elt].page =3D frag->page;
> -			sg[elt].offset =3D frag->page_offset+offset-start;
> +			sg[elt].offset =3D frag->page_offset;
>  			sg[elt].length =3D copy;
>  			elt++;
>  			if (!(len -=3D copy))
>  				return elt;
>  			offset +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				if (copy > len)
>  					copy =3D len;
> -				elt +=3D skb_to_sgvec(list, sg+elt, offset - start, copy);
> +				elt +=3D skb_to_sgvec(list, sg+elt, 0, copy);
>  				if ((len -=3D copy) =3D=3D 0)
>  					return elt;
>  				offset +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}
>  	BUG_ON(len);
> --- linux-2.6.21-rc4.orig/net/appletalk/ddp.c	2007-02-21
> 08:36:30.000000000 +0100 +++
> linux-2.6.21-rc4/net/appletalk/ddp.c	2007-03-19 21:40:07.000000000
> +0100 @@ -937,11 +937,11 @@ static unsigned long atalk_sum_partial(c
> static unsigned long atalk_sum_skb(const struct sk_buff *skb, int
> offset, int len, unsigned long sum)
>  {
> -	int start =3D skb_headlen(skb);
> +	int end =3D skb_headlen(skb);
>  	int i, copy;
>
>  	/* checksum stuff in header space */
> -	if ( (copy =3D start - offset) > 0) {
> +	if ((copy =3D end - offset) > 0) {
>  		if (copy > len)
>  			copy =3D len;
>  		sum =3D atalk_sum_partial(skb->data + offset, copy, sum);
> @@ -953,11 +953,9 @@ static unsigned long atalk_sum_skb(const
>
>  	/* checksum stuff in frags */
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		int end;
> +		BUG_TRAP(len >=3D 0);
>
> -		BUG_TRAP(start <=3D offset + len);
> -
> -		end =3D start + skb_shinfo(skb)->frags[i].size;
> +		end =3D offset + skb_shinfo(skb)->frags[i].size;
>  		if ((copy =3D end - offset) > 0) {
>  			u8 *vaddr;
>  			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> @@ -965,36 +963,31 @@ static unsigned long atalk_sum_skb(const
>  			if (copy > len)
>  				copy =3D len;
>  			vaddr =3D kmap_skb_frag(frag);
> -			sum =3D atalk_sum_partial(vaddr + frag->page_offset +
> -						  offset - start, copy, sum);
> +			sum =3D atalk_sum_partial(vaddr + frag->page_offset,
> +						copy, sum);
>  			kunmap_skb_frag(vaddr);
>
>  			if (!(len -=3D copy))
>  				return sum;
>  			offset +=3D copy;
>  		}
> -		start =3D end;
>  	}
>
>  	if (skb_shinfo(skb)->frag_list) {
>  		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
>
>  		for (; list; list =3D list->next) {
> -			int end;
> -
> -			BUG_TRAP(start <=3D offset + len);
> +			BUG_TRAP(len >=3D 0);
>
> -			end =3D start + list->len;
> +			end =3D offset + list->len;
>  			if ((copy =3D end - offset) > 0) {
>  				if (copy > len)
>  					copy =3D len;
> -				sum =3D atalk_sum_skb(list, offset - start,
> -						    copy, sum);
> +				sum =3D atalk_sum_skb(list, 0, copy, sum);
>  				if ((len -=3D copy) =3D=3D 0)
>  					return sum;
>  				offset +=3D copy;
>  			}
> -			start =3D end;
>  		}
>  	}

--=20
Jean Delvare
Suse L3
