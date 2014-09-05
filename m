From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH 1/3] virtio_net: pass well-formed sgs to virtqueue_add_*()
Date: Fri, 05 Sep 2014 12:40:50 +0200
Message-ID: <54099332.7060909@redhat.com>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
	<1409718556-3041-2-git-send-email-rusty__16380.2289790057$1409718628$gmane$org@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Andy Lutomirski <luto@amacapital.net>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>,
 netdev <netdev@vger.kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1409718556-3041-2-git-send-email-rusty__16380.2289790057$1409718628$gmane$org@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Il 03/09/2014 06:29, Rusty Russell ha scritto:
> +	sg_init_table(rq->sg, MAX_SKB_FRAGS + 2);

I think 2 is enough here.  That said...

>  	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
> -
>  	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
>  
>  	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);

... skb_to_sgvec will already make the sg well formed, so the
sg_init_table is _almost_ redundant; it is only there to remove
intermediate end marks.  The block layer takes care to remove
them, but skb_to_sgvec doesn't.

If the following patch can be accepted to net/core/skbuff.c, the
sg_init_table in virtnet_alloc_queues will suffice.

Paolo

-------------------- 8< -------------------
From: Paolo Bonzini <pbonzini@redhat.com>
Subject: [PATCH] net: skb_to_sgvec: do not leave intermediate marks in the sgvec

sg_set_buf/sg_set_page will leave the end mark in place in their
argument, which may be in the middle of a scatterlist.  If we
remove the mark before calling them, we can avoid calls to
sg_init_table before skb_to_sgvec.

However, users of skb_to_sgvec_nomark now need to be careful and
possibly restore the mark.

Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 163b673f9e62..a3108ef1f1c0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3265,6 +3265,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
+		sg_unmark_end(sg);
 		sg_set_buf(sg, skb->data + offset, copy);
 		elt++;
 		if ((len -= copy) == 0)
@@ -3283,6 +3284,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 
 			if (copy > len)
 				copy = len;
+			sg_unmark_end(&sg[elt]);
 			sg_set_page(&sg[elt], skb_frag_page(frag), copy,
 					frag->page_offset+offset-start);
 			elt++;
@@ -3322,7 +3324,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
  * Scenario to use skb_to_sgvec_nomark:
  * 1. sg_init_table
  * 2. skb_to_sgvec_nomark(payload1)
- * 3. skb_to_sgvec_nomark(payload2)
+ * 3. skb_to_sgvec(payload2)
  *
  * This is equivalent to:
  * 1. sg_init_table
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index a2afa89513a0..9ae5756d9e5f 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -227,6 +227,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
 		sg_set_buf(seqhisg, seqhi, seqhi_len);
 	}
+	sg_mark_end(&sg[nfrags + sglists]);
 	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah_output_done, skb);
 
@@ -395,6 +396,7 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		*seqhi = XFRM_SKB_CB(skb)->seq.input.hi;
 		sg_set_buf(seqhisg, seqhi, seqhi_len);
 	}
+	sg_mark_end(&sg[nfrags + sglists]);
 	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah_input_done, skb);
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 72a4930bdc0a..c680d82e43de 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -430,6 +430,8 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
 		sg_set_buf(seqhisg, seqhi, seqhi_len);
 	}
+	sg_mark_end(&sg[nfrags + sglists]);
+
 	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah6_output_done, skb);
 
@@ -608,6 +610,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		*seqhi = XFRM_SKB_CB(skb)->seq.input.hi;
 		sg_set_buf(seqhisg, seqhi, seqhi_len);
 	}
+	sg_mark_end(&sg[nfrags + sglists]);
 
 	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah6_input_done, skb);
