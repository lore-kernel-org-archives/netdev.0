From: Milan Kocian <milon@wq.cz>
Subject: [patch 1/1] networking: fix sending netlink message when replace route
Date: Fri, 20 Apr 2007 16:07:42 +0200
Message-ID: <20070420140742.GA30839@wq.cz>
References: <461D26CB.3010508@trash.net> <1176400428.24446.40.camel@nt.wq.cz> <4623029A.2090906@trash.net> <20070416.171016.43503207.davem@davemloft.net> <4624C46D.1030609@trash.net> <1176900487.8348.36.camel@nt.wq.cz> <462625E4.8030802@trash.net> <1176982238.5032.22.camel@nt.wq.cz> <46275CA3.1070503@trash.net> <20070419144245.2a0a0905.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:43848 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2993013AbXDTOIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 10:08:05 -0400
Content-Disposition: inline
In-Reply-To: <20070419144245.2a0a0905.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milan Kocian <milon@wq.cz>

When you replace route via ip r r command the netlink multicast message
is not send. This patch corrects it. NL message is sent with
NLM_F_REPLACE flag. [Bug 8320]
---

--- a/net/ipv4/fib_hash.c	2007-04-18 12:50:11.000000000 +0200
+++ b/net/ipv4/fib_hash.c	2007-04-19 10:21:04.267136960 +0200
@@ -457,6 +457,8 @@
 			fib_release_info(fi_drop);
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(-1);
+			rtmsg_fib(RTM_NEWROUTE, key, fa, cfg->fc_dst_len, tb->tb_id,
+				  &cfg->fc_nlinfo, NLM_F_REPLACE);
 			return 0;
 		}
 
@@ -524,7 +526,7 @@
 	rt_cache_flush(-1);
 
 	rtmsg_fib(RTM_NEWROUTE, key, new_fa, cfg->fc_dst_len, tb->tb_id,
-		  &cfg->fc_nlinfo);
+		  &cfg->fc_nlinfo, 0);
 	return 0;
 
 out_free_new_fa:
@@ -590,7 +592,7 @@
 
 		fa = fa_to_delete;
 		rtmsg_fib(RTM_DELROUTE, key, fa, cfg->fc_dst_len,
-			  tb->tb_id, &cfg->fc_nlinfo);
+			  tb->tb_id, &cfg->fc_nlinfo, 0);
 
 		kill_fn = 0;
 		write_lock_bh(&fib_hash_lock);
--- a/net/ipv4/fib_trie.c	2007-04-18 12:50:11.000000000 +0200
+++ b/net/ipv4/fib_trie.c	2007-04-19 11:41:14.537864656 +0200
@@ -1205,6 +1205,8 @@
 			fib_release_info(fi_drop);
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(-1);
+			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
+				  &cfg->fc_nlinfo, NLM_F_REPLACE);
 			goto succeeded;
 		}
 		/* Error if we find a perfect match which
@@ -1256,7 +1258,7 @@
 
 	rt_cache_flush(-1);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
-		  &cfg->fc_nlinfo);
+		  &cfg->fc_nlinfo, 0);
 succeeded:
 	return 0;
 
@@ -1599,7 +1601,7 @@
 
 	fa = fa_to_delete;
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
-		  &cfg->fc_nlinfo);
+		  &cfg->fc_nlinfo, 0);
 
 	l = fib_find_node(t, key);
 	li = find_leaf_info(l, plen);
--- a/net/ipv4/fib_semantics.c	2007-04-18 12:50:11.000000000 +0200
+++ b/net/ipv4/fib_semantics.c	2007-04-19 10:22:06.852622520 +0200
@@ -301,7 +301,8 @@
 }
 
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
-	       int dst_len, u32 tb_id, struct nl_info *info)
+	       int dst_len, u32 tb_id, struct nl_info *info,
+	       unsigned int nlm_flags)
 {
 	struct sk_buff *skb;
 	u32 seq = info->nlh ? info->nlh->nlmsg_seq : 0;
@@ -313,7 +314,7 @@
 
 	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
 			    fa->fa_type, fa->fa_scope, key, dst_len,
-			    fa->fa_tos, fa->fa_info, 0);
+			    fa->fa_tos, fa->fa_info, nlm_flags);
 	/* failure implies BUG in fib_nlmsg_size() */
 	BUG_ON(err < 0);
 
--- a/net/ipv4/fib_lookup.h	2007-04-18 12:50:11.000000000 +0200
+++ b/net/ipv4/fib_lookup.h	2007-04-19 10:23:11.637773680 +0200
@@ -30,7 +30,8 @@
 			 int dst_len, u8 tos, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
-		      int dst_len, u32 tb_id, struct nl_info *info);
+		      int dst_len, u32 tb_id, struct nl_info *info,
+		      unsigned int nlm_flags);
 extern struct fib_alias *fib_find_alias(struct list_head *fah,
 					u8 tos, u32 prio);
 extern int fib_detect_death(struct fib_info *fi, int order,

Signed-off-by: Milan Kocian <milon@wq.cz>

