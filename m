From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 1/6] skbuff: support per-page destructors in
 copy_ubufs
Date: Thu, 10 May 2012 21:42:46 +0300
Message-ID: <20120510184246.GE14647@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
 <1336671977.14220.26.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760751Ab2EJSmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 14:42:47 -0400
Content-Disposition: inline
In-Reply-To: <1336671977.14220.26.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 10, 2012 at 06:46:17PM +0100, Ian Campbell wrote:
> On Mon, 2012-05-07 at 14:54 +0100, Michael S. Tsirkin wrote:
> 
> >  	/* skb frags point to kernel buffers */
> >  	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
> > +		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
> 
> This needs to be ....->frags[i - 1]

Good catch.
  	for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
		skb_frag_t *f = &skb_shinfo(skb)->frags[i];

would be a bit clearer though.

> otherwise you put every new frag one too high and don't do anything to
> frag 0, which leaves the old destructor pointer in place and leads to a
> double free.
> 
> I think skb_frag_set_destructor and skb_copy_frag_destructor need to
> clear and propagate respectively (or maybe just clear in both cases) the
> destructor_arg field since it is otherwise not initialised when we set
> SKBTX_DEV_ZEROCOPY and that can trigger wrong behaviour in this
> function.
> 
> Ian.

Agree, let's just clear it.



> > +		if (unlikely((!uarg && !f->page.destructor)))
> > +			continue;
> >  		__skb_fill_page_desc(skb, i-1, head, 0,
> >  				     skb_shinfo(skb)->frags[i - 1].size);
> >  		head = (struct page *)head->private;
> 

So the below on top then. I pushed these on
top of my zerocopy branch - can you confirm pls?

---

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 930a50e..e52bc8d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1270,8 +1270,10 @@ static inline void skb_frag_set_destructor(struct sk_buff *skb, int i,
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 	frag->page.destructor = destroy;
-	if (destroy)
+	if (destroy) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+		skb_shinfo(skb)->destructor_arg = NULL;
+	}
 }
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b7fc47e..453f621 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -753,12 +753,11 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		uarg->callback(uarg);
 
 	/* skb frags point to kernel buffers */
-	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
+	for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
 		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
 		if (unlikely((!uarg && !f->page.destructor)))
 			continue;
-		__skb_fill_page_desc(skb, i-1, head, 0,
-				     skb_shinfo(skb)->frags[i - 1].size);
+		__skb_fill_page_desc(skb, i, head, 0, f->size);
 		head = (struct page *)head->private;
 	}
 
