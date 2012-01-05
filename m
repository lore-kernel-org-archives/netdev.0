From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Thu, 5 Jan 2012 19:19:24 +0000
Message-ID: <1325791164.29084.8.camel@dagon.hellion.org.uk>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:21814 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235Ab2AETT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:19:26 -0500
In-Reply-To: <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-05 at 17:46 +0000, Eric Dumazet wrote:
> Le jeudi 05 janvier 2012 =E0 17:13 +0000, Ian Campbell a =E9crit :
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index da0c97f..b6de604 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -189,8 +189,7 @@ struct sk_buff *__alloc_skb(unsigned int size, =
gfp_t gfp_mask,
> >  	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
> >  	 * Both skb->head and skb_shared_info are cache line aligned.
> >  	 */
> > -	size =3D SKB_DATA_ALIGN(size);
> > -	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> > +	size =3D SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
> >  	data =3D kmalloc_node_track_caller(size, gfp_mask, node);
> >  	if (!data)
> >  		goto nodata;
>=20
> Unfortunately this makes the frequently use part of skb_shared_info n=
ot
> any more in a single cache line.
>=20
> This will slow down many operations like kfree_skb() of cold skbs (TX
> completion for example)

I've been toying with the following which moves the infrequently used
destructor_arg field to the front. With 32 or 64 byte cache lines this
is then the only field which ends up on a different cache line. With 12=
8
byte cache lines it is all already on the same line.

Does that alleviate your concern? If so I can clean it up and include i=
t
in the series.

Cheers,
Ian.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cbc815c..533c2ea 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -249,6 +249,11 @@ struct ubuf_info {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
+	/* Intermediate layers must ensure that destructor_arg
+	 * remains valid until skb destructor */
+	void *		destructor_arg;
+
+	/* Warning all fields from here until dataref are cleared in __alloc_=
skb() */
 	unsigned char	nr_frags;
 	__u8		tx_flags;
 	unsigned short	gso_size;
@@ -264,9 +269,6 @@ struct skb_shared_info {
 	 */
 	atomic_t	dataref;
=20
-	/* Intermediate layers must ensure that destructor_arg
-	 * remains valid until skb destructor */
-	void *		destructor_arg;
=20
 	/* must be last field, see pskb_expand_head() */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e942a86..592b8a8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -219,7 +219,10 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp=
_t gfp_mask,
=20
 	/* make sure we initialize shinfo sequentially */
 	shinfo =3D skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+
+	memset(&shinfo->nr_frags, 0,
+	       offsetof(struct skb_shared_info, dataref)
+	       - offsetof(struct skb_shared_info, nr_frags));
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
=20
