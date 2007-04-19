From: Milan =?ISO-8859-1?Q?Koci=E1n?= <milon@wq.cz>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
	send netlink message
Date: Thu, 19 Apr 2007 13:30:38 +0200
Message-ID: <1176982238.5032.22.camel@nt.wq.cz>
References: <461D26CB.3010508@trash.net>
	 <1176400428.24446.40.camel@nt.wq.cz>	<4623029A.2090906@trash.net>
	 <20070416.171016.43503207.davem@davemloft.net> <4624C46D.1030609@trash.net>
	 <1176900487.8348.36.camel@nt.wq.cz> <462625E4.8030802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-IV4vvZllvhvS6D4fiUCU"
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:51938 "EHLO rd.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030973AbXDSLaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 07:30:52 -0400
In-Reply-To: <462625E4.8030802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-IV4vvZllvhvS6D4fiUCU
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-04-18 at 16:06 +0200, Patrick McHardy wrote:
> Milan Koci=E1n wrote:
> > On Tue, 2007-04-17 at 14:58 +0200, Patrick McHardy wrote:
> >=20
> >>Milan, could you cook up another patch which uses NLM_F_REPLACE?
> >=20
> >=20
> > I can try it. Output is in patch below. Review carefully. I don't know
> > if it's best approach. It's tested and working without problem
> > (probably :-))
>=20
>=20
> Looks good, but your mailer corrupted long lines. Please resend as
> attachment and sign off the patch.
>=20

ok, here is new version. Sign is in patch. Is it correct?


--=20
Milan Koci=E1n <milon@wq.cz>

--=-IV4vvZllvhvS6D4fiUCU
Content-Disposition: attachment; filename=nl.diff
Content-Type: text/x-patch; name=nl.diff; charset=us-ascii
Content-Transfer-Encoding: 7bit

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

--=-IV4vvZllvhvS6D4fiUCU--

