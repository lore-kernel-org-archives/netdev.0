From: Milan =?ISO-8859-1?Q?Koci=E1n?= <milon@wq.cz>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
	send netlink message
Date: Wed, 18 Apr 2007 14:48:07 +0200
Message-ID: <1176900487.8348.36.camel@nt.wq.cz>
References: <461D26CB.3010508@trash.net>
	 <1176400428.24446.40.camel@nt.wq.cz>	<4623029A.2090906@trash.net>
	 <20070416.171016.43503207.davem@davemloft.net> <4624C46D.1030609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:39906 "EHLO rd.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422971AbXDRMsV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 08:48:21 -0400
In-Reply-To: <4624C46D.1030609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-04-17 at 14:58 +0200, Patrick McHardy wrote:
> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Mon, 16 Apr 2007 06:59:06 +0200
> >=20
> >=20
> >>RTM_DELROUTE + RTM_NEWROUTE seem to be safer, although you're corre=
ct
> >>that it might cause userspace to perform some action upon receiving
> >>the DELROUTE message since the update is non-atomic. So I really do=
n't
> >>know, I'm in favour of having notifications for replacements, but I
> >>fear we might break something.
> >=20
> >=20
> > We can cry foul about a broken application if an application follow=
ing
> > the API correctly would interpret the new messages correctly.
> >=20
> > I think it doesn't make sense to do a delete then a newroute for
> > the atomicity issues, and therefore the replace makes the most
> > sense as long as existing correct uses of the API would not
> > explode on this.
>
> They shouldn't, worst case is that they ignore NLM_F_REPLACE and trea=
t
> it as a completely new route, which is at least half way correct and
> not really worse than today.
>=20
> Milan, could you cook up another patch which uses NLM_F_REPLACE?
>=20

I can try it. Output is in patch below. Review carefully. I don't know
if it's best approach. It's tested and working without problem
(probably :-))

--- net/ipv4.old/fib_hash.c	2007-04-18 12:50:11.000000000 +0200
+++ net/ipv4/fib_hash.c	2007-04-18 12:39:49.081369320 +0200
@@ -443,7 +443,6 @@
 		if (cfg->fc_nlflags & NLM_F_REPLACE) {
 			struct fib_info *fi_drop;
 			u8 state;
-
 			write_lock_bh(&fib_hash_lock);
 			fi_drop =3D fa->fa_info;
 			fa->fa_info =3D fi;
@@ -457,6 +456,8 @@
 			fib_release_info(fi_drop);
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(-1);
+			rtmsg_fib(RTM_NEWROUTE, key, fa, cfg->fc_dst_len, tb->tb_id,
+				  &cfg->fc_nlinfo, NLM_F_REPLACE);
 			return 0;
 		}
=20
@@ -524,7 +525,7 @@
 	rt_cache_flush(-1);
=20
 	rtmsg_fib(RTM_NEWROUTE, key, new_fa, cfg->fc_dst_len, tb->tb_id,
-		  &cfg->fc_nlinfo);
+		  &cfg->fc_nlinfo, 0);
 	return 0;
=20
 out_free_new_fa:
@@ -590,7 +591,7 @@
=20
 		fa =3D fa_to_delete;
 		rtmsg_fib(RTM_DELROUTE, key, fa, cfg->fc_dst_len,
-			  tb->tb_id, &cfg->fc_nlinfo);
+			  tb->tb_id, &cfg->fc_nlinfo, 0);
=20
 		kill_fn =3D 0;
 		write_lock_bh(&fib_hash_lock);
--- net/ipv4.old/fib_trie.c	2007-04-18 12:50:11.000000000 +0200
+++ net/ipv4/fib_trie.c	2007-04-18 12:42:29.423993536 +0200
@@ -1205,6 +1205,9 @@
 			fib_release_info(fi_drop);
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(-1);
+			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
+				  &cfg->fc_nlinfo, NLM_F_REPLACE);
+
 			goto succeeded;
 		}
 		/* Error if we find a perfect match which
@@ -1256,7 +1259,7 @@
=20
 	rt_cache_flush(-1);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
-		  &cfg->fc_nlinfo);
+		  &cfg->fc_nlinfo, 0);
 succeeded:
 	return 0;
=20
@@ -1599,7 +1602,7 @@
=20
 	fa =3D fa_to_delete;
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
-		  &cfg->fc_nlinfo);
+		  &cfg->fc_nlinfo, 0);
=20
 	l =3D fib_find_node(t, key);
 	li =3D find_leaf_info(l, plen);
--- net/ipv4.old/fib_semantics.c	2007-04-18 12:50:11.000000000 +0200
+++ net/ipv4/fib_semantics.c	2007-04-18 12:40:54.807377448 +0200
@@ -301,7 +301,7 @@
 }
=20
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
-	       int dst_len, u32 tb_id, struct nl_info *info)
+	       int dst_len, u32 tb_id, struct nl_info *info, unsigned int
nlm_flags)
 {
 	struct sk_buff *skb;
 	u32 seq =3D info->nlh ? info->nlh->nlmsg_seq : 0;
@@ -313,7 +313,7 @@
=20
 	err =3D fib_dump_info(skb, info->pid, seq, event, tb_id,
 			    fa->fa_type, fa->fa_scope, key, dst_len,
-			    fa->fa_tos, fa->fa_info, 0);
+			    fa->fa_tos, fa->fa_info, nlm_flags);
 	/* failure implies BUG in fib_nlmsg_size() */
 	BUG_ON(err < 0);
=20
--- net/ipv4.old/fib_lookup.h	2007-04-18 12:50:11.000000000 +0200
+++ net/ipv4/fib_lookup.h	2007-04-18 12:43:42.377902856 +0200
@@ -30,7 +30,7 @@
 			 int dst_len, u8 tos, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
-		      int dst_len, u32 tb_id, struct nl_info *info);
+		      int dst_len, u32 tb_id, struct nl_info *info, unsigned int
nlm_flags);
 extern struct fib_alias *fib_find_alias(struct list_head *fah,
 					u8 tos, u32 prio);
 extern int fib_detect_death(struct fib_info *fi, int order,


--=20
Milan Koci=E1n <milon@wq.cz>

