From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Fri, 07 Jul 2006 21:58:31 +0200
Message-ID: <44AEBCE7.2030203@trash.net>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44AE15C3.8050900@trash.net> <44AEA462.1080505@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040403030903040509060705"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>, Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54239 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932218AbWGGT6e
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 15:58:34 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <44AEA462.1080505@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040403030903040509060705
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>>> I took on Ben's challenge to increase the number of possible routing
>>> tables, these are the resulting patches.
> 
> 
> I am seeing problems..though they could be with the way I'm using the tool
> or pehaps I patched the kernel incorrectly.
> 
> I applied the 3 patches to 2.6.17..all patches applied without problem,
> but with a few lines of fuzz.  I get the same behaviour with and
> without the new 'ip' patches applied.
> 
> If I do an 'ip ru show', then I see lots of tables, though not all it
> seems. (I have not tried beyond 205 yet).  But, if I do an
> 'ip route show table XX', then I see nothing or incorrect values.

My patches introduced a bug when dumping tables which could lead to
incorrect routes beeing dumped. A second bug (that already existed)
makes the kernel fail when dumping more rules than fit in a skb.
I think I've already seen the patch to address the second problem
a short time ago sent by someone else. Anyway, this patch should
fix both.


--------------040403030903040509060705
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3c49e6b..6e1aaa4 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -357,6 +357,7 @@ int inet_dump_fib(struct sk_buff *skb, s
 	unsigned int e = 0, s_e;
 	struct fib_table *tb;
 	struct hlist_node *node;
+	int dumped = 0;
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
 	    ((struct rtmsg*)NLMSG_DATA(cb->nlh))->rtm_flags&RTM_F_CLONED)
@@ -365,16 +366,17 @@ int inet_dump_fib(struct sk_buff *skb, s
 	s_h = cb->args[0];
 	s_e = cb->args[1];
 
-	for (h = s_h; h < FIB_TABLE_HASHSZ; h++) {
+	for (h = s_h; h < FIB_TABLE_HASHSZ; h++, s_e = 0) {
 		e = 0;
 		hlist_for_each_entry(tb, node, &fib_table_hash[h], tb_hlist) {
 			if (e < s_e)
 				goto next;
-			if (e > s_e)
-				memset(&cb->args[1], 0, sizeof(cb->args) -
+			if (dumped)
+				memset(&cb->args[2], 0, sizeof(cb->args) -
 				                 2 * sizeof(cb->args[0]));
 			if (tb->tb_dump(tb, skb, cb) < 0) 
 				goto out;
+			dumped = 1;
 next:
 			e++;
 		}
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index a41ab4b..6f33f12 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -459,13 +459,13 @@ int inet_dump_rules(struct sk_buff *skb,
 
 	rcu_read_lock();
 	hlist_for_each_entry(r, node, &fib_rules, hlist) {
-
 		if (idx < s_idx)
-			continue;
+			goto next;
 		if (inet_fill_rule(skb, r, NETLINK_CB(cb->skb).pid,
 				   cb->nlh->nlmsg_seq,
 				   RTM_NEWRULE, NLM_F_MULTI) < 0)
 			break;
+next:
 		idx++;
 	}
 	rcu_read_unlock();

--------------040403030903040509060705--
