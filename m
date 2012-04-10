From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big
 network copies (page allocation failure)
Date: Tue, 10 Apr 2012 08:11:03 +0200
Message-ID: <1334038263.2907.1.camel@edumazet-glaptop>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:58488 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958Ab2DJGLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 02:11:09 -0400
In-Reply-To: <20120410051127.GA32048@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 22:11 -0700, Marc MERLIN wrote:
> On Tue, Apr 10, 2012 at 05:56:20AM +0200, Eric Dumazet wrote:
> > > What wireless device are we dealing with again?
> > 
> > Problem seems related to tailroom needed by mac80211
> > (IEEE80211_ENCRYPT_TAILROOM = 18 bytes)
> > 
> > So we must reallocate skb->head, thats impressive nobody cares.
> > 
> > [ 3007.249687] ieee80211_skb_resize(skb=ffff8802329846e8) cloned=1 head_need=0 tail_need=18 skb->len=1494 ksize=4096 tailroom=0 headroom=2282
> > [ 3007.249693] ieee80211_skb_resize(skb=ffff8802329846e8) cloned=0 head_need=0 tail_need=0 skb->len=1526 ksize=8192 tailroom=64 headroom=2250
> > 
> > Ouch... skb_tailroom() seems wrong ... it seems pskb_expand_head() is really suboptimal.
> > 
> > It appears tcp_sendmsg() tries to fill skb completely, with no available tailroom :
> > 
> >                         if (skb_tailroom(skb) > 0) {
> >                                 /* We have some space in skb head. Superb! */
> >                                 if (copy > skb_tailroom(skb))
> >                                         copy = skb_tailroom(skb);
> >                                 err = skb_add_data_nocache(sk, skb, from, copy);
> >                                 if (err)
> >                                         goto do_fault;
> >                         } else {
> > 
> > Shouldnt we take into account dev->needed_tailroom ?
> > 
> > I'll submit a pskb_expand_head() fix asap.
> 
> Thanks for finding this.
> 
> To answer an earlier question, I tried the non wireless case too.
> 
> The problem is harder to reproduce over e1000e though, I just got two short
> hangs where my mouse cursor was hung for 5-10 seconds, but nothing in
> syslog/dmesg this time.
> 
> I'm pretty sure this older log below did happen on e1000e with wireless disabled
> though (but it had a taint 'O'):
> 
> If that helps, my earlier message had the traces below.
> 
> I can report back when you have a patch you'd like me to try out.

Hi Marc

Please try following patch, as it solved the problem for me (no more
order-1 allocations in tx path)

Thanks !

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3337027..70a3f8d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -481,6 +481,7 @@ struct sk_buff {
 	union {
 		__u32		mark;
 		__u32		dropcount;
+		__u32		avail_size;
 	};
 
 	sk_buff_data_t		transport_header;
@@ -1366,6 +1367,18 @@ static inline int skb_tailroom(const struct sk_buff *skb)
 }
 
 /**
+ *	skb_availroom - bytes at buffer end
+ *	@skb: buffer to check
+ *
+ *	Return the number of bytes of free space at the tail of an sk_buff
+ *	allocated by sk_stream_alloc()
+ */
+static inline int skb_availroom(const struct sk_buff *skb)
+{
+	return skb_is_nonlinear(skb) ? 0 : skb->avail_size - skb->len;
+}
+
+/**
  *	skb_reserve - adjust headroom
  *	@skb: buffer to alter
  *	@len: bytes to move
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index baf8d28..1887454 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -952,9 +952,11 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		goto adjust_others;
 	}
 
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	data = kmalloc(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
+		       gfp_mask);
 	if (!data)
 		goto nodata;
+	size = ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void.
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5d54ed3..87f497f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -701,11 +701,12 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
 	if (skb) {
 		if (sk_wmem_schedule(sk, skb->truesize)) {
+			skb_reserve(skb, sk->sk_prot->max_header);
 			/*
 			 * Make sure that we have exactly size bytes
 			 * available to the caller, no more, no less.
 			 */
-			skb_reserve(skb, skb_tailroom(skb) - size);
+			skb->avail_size = size;		
 			return skb;
 		}
 		__kfree_skb(skb);
@@ -995,10 +996,9 @@ new_segment:
 				copy = seglen;
 
 			/* Where to copy to? */
-			if (skb_tailroom(skb) > 0) {
+			if (skb_availroom(skb) > 0) {
 				/* We have some space in skb head. Superb! */
-				if (copy > skb_tailroom(skb))
-					copy = skb_tailroom(skb);
+				copy = min_t(int, copy, skb_availroom(skb));
 				err = skb_add_data_nocache(sk, skb, from, copy);
 				if (err)
 					goto do_fault;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 364784a..376b2cf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2060,7 +2060,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 		/* Punt if not enough space exists in the first SKB for
 		 * the data in the second
 		 */
-		if (skb->len > skb_tailroom(to))
+		if (skb->len > skb_availroom(to))
 			break;
 
 		if (after(TCP_SKB_CB(skb)->end_seq, tcp_wnd_end(tp)))
