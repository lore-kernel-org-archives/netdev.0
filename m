From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: gre: fix a possible skb leak
Date: Mon, 24 Jun 2013 16:03:59 +0200
Message-ID: <20130624140359.GA28057@redhat.com>
References: <1372080360.3301.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783Ab3FXOEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 10:04:22 -0400
Content-Disposition: inline
In-Reply-To: <1372080360.3301.61.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 06:26:00AM -0700, Eric Dumazet wrote:
>From: Eric Dumazet <edumazet@google.com>
>
>commit 68c331631143 ("v4 GRE: Add TCP segmentation offload for GRE")
>added a possible skb leak, because it frees only the head of segment
>list, in case a skb_linearize() call fails.
>
>This patch adds a kfree_skb_list() helper to fix the bug.
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>
>Cc: Pravin B Shelar <pshelar@nicira.com>
>Cc: Daniel Borkmann <dborkman@redhat.com>
>
>---
>include/linux/skbuff.h |    1 +
> net/core/skbuff.c      |   20 ++++++++++++--------
> net/ipv4/gre.c         |    2 +-
> 3 files changed, 14 insertions(+), 9 deletions(-)
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>index 9c676eae..dec1748 100644
>--- a/include/linux/skbuff.h
>+++ b/include/linux/skbuff.h
>@@ -627,6 +627,7 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
> }
>
> extern void kfree_skb(struct sk_buff *skb);
>+extern void kfree_skb_list(struct sk_buff *segs);
> extern void skb_tx_error(struct sk_buff *skb);
> extern void consume_skb(struct sk_buff *skb);
> extern void	       __kfree_skb(struct sk_buff *skb);
>diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>index cfd777b..1c1738c 100644
>--- a/net/core/skbuff.c
>+++ b/net/core/skbuff.c
>@@ -483,15 +483,8 @@ EXPORT_SYMBOL(skb_add_rx_frag);
>
> static void skb_drop_list(struct sk_buff **listp)
> {
>-	struct sk_buff *list = *listp;
>-
>+	kfree_skb_list(*listp);
> 	*listp = NULL;
>-
>-	do {
>-		struct sk_buff *this = list;
>-		list = list->next;
>-		kfree_skb(this);
>-	} while (list);
> }
>
> static inline void skb_drop_fraglist(struct sk_buff *skb)
>@@ -651,6 +644,17 @@ void kfree_skb(struct sk_buff *skb)
> }
> EXPORT_SYMBOL(kfree_skb);
>
>+void kfree_skb_list(struct sk_buff *segs)
>+{
>+	while (segs) {
>+		struct sk_buff *next = segs->next;
>+
>+		kfree_skb(segs);
>+		segs = next;
>+	}
>+}
>+EXPORT_SYMBOL(kfree_skb_list);
>+
> /**
>  *	skb_tx_error - report an sk_buff xmit error
>  *	@skb: buffer that triggered an error
>diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
>index b2e805a..7856d16 100644
>--- a/net/ipv4/gre.c
>+++ b/net/ipv4/gre.c
>@@ -178,7 +178,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>
> 				err = __skb_linearize(skb);
> 				if (err) {
>-					kfree_skb(segs);
>+					kfree_skb_list(segs);
> 					segs = ERR_PTR(err);
> 					goto out;
> 				}
>

Maybe we can also use it here (build-tested only):

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4850dc1..5776819 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2924,10 +2924,7 @@ perform_csum_check:
  	return segs;
  
  err:
-	while ((skb = segs)) {
-		segs = skb->next;
-		kfree_skb(skb);
-	}
+	kfree_skb_list(segs);
  	return ERR_PTR(err);
  }
  EXPORT_SYMBOL_GPL(skb_segment);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4bcabf3..27ba045 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -575,11 +575,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
  			return 0;
  		}
  
-		while (frag) {
-			skb = frag->next;
-			kfree_skb(frag);
-			frag = skb;
-		}
+		kfree_skb_list(frag);
  		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
  		return err;
  
