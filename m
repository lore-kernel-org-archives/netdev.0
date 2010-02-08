From: Patrick McHardy <kaber@trash.net>
Subject: ipv6: fib: fix crash when changing large fib while dumping it
Date: Mon, 08 Feb 2010 16:19:03 +0100
Message-ID: <4B702B67.4000900@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060504040709060202010303"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36787 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834Ab0BHPTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 10:19:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060504040709060202010303
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Please review carefully, I'm not too familiar with this code.


--------------060504040709060202010303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 73286941c499e3e3ccaea194aea9b280a1485c17
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Feb 8 16:11:55 2010 +0100

    ipv6: fib: fix crash when changing large fib while dumping it
    
    When the fib size exceeds what can be dumped in a single skb, the
    dump is suspended and resumed once the last skb has been received
    by userspace. When the fib is changed while the dump is suspended,
    the walker might contain stale pointers, causing a crash when the
    dump is resumed.
    
    BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
    IP: [<ffffffffa01bce04>] fib6_walk_continue+0xbb/0x124 [ipv6]
    PGD 5347a067 PUD 65c7067 PMD 0
    Oops: 0000 [#1] PREEMPT SMP
    ...
    RIP: 0010:[<ffffffffa01bce04>]
    [<ffffffffa01bce04>] fib6_walk_continue+0xbb/0x124 [ipv6]
    ...
    Call Trace:
     [<ffffffff8104aca3>] ? mutex_spin_on_owner+0x59/0x71
     [<ffffffffa01bd105>] inet6_dump_fib+0x11b/0x1b9 [ipv6]
     [<ffffffff81371af4>] netlink_dump+0x5b/0x19e
     [<ffffffff8134f288>] ? consume_skb+0x28/0x2a
     [<ffffffff81373b69>] netlink_recvmsg+0x1ab/0x2c6
     [<ffffffff81372781>] ? netlink_unicast+0xfa/0x151
     [<ffffffff813483e0>] __sock_recvmsg+0x6d/0x79
     [<ffffffff81348a53>] sock_recvmsg+0xca/0xe3
     [<ffffffff81066d4b>] ? autoremove_wake_function+0x0/0x38
     [<ffffffff811ed1f8>] ? radix_tree_lookup_slot+0xe/0x10
     [<ffffffff810b3ed7>] ? find_get_page+0x90/0xa5
     [<ffffffff810b5dc5>] ? filemap_fault+0x201/0x34f
     [<ffffffff810ef152>] ? fget_light+0x2f/0xac
     [<ffffffff813519e7>] ? verify_iovec+0x4f/0x94
     [<ffffffff81349a65>] sys_recvmsg+0x14d/0x223
    
    Store the serial number when beginning to walk the fib and reload
    pointers when continuing to walk after a change occured. Similar
    to other dumping functions, this might cause unrelated entries to
    be missed when entries are deleted.
    
    Tested-by: Ben Greear <greearb@candelatech.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 2578081..8f279dd 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -129,6 +129,8 @@ struct fib6_walker_t {
 	struct rt6_info *leaf;
 	unsigned char state;
 	unsigned char prune;
+	unsigned int skip;
+	unsigned int count;
 	int (*func)(struct fib6_walker_t *);
 	void *args;
 };
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0e93ca5..f45aded 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -319,12 +319,26 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 	w->root = &table->tb6_root;
 
 	if (cb->args[4] == 0) {
+		w->count = 0;
+		w->skip = 0;
+
 		read_lock_bh(&table->tb6_lock);
 		res = fib6_walk(w);
 		read_unlock_bh(&table->tb6_lock);
-		if (res > 0)
+		if (res > 0) {
 			cb->args[4] = 1;
+			cb->args[5] = w->root->fn_sernum;
+		}
 	} else {
+		if (cb->args[5] != w->root->fn_sernum) {
+			/* Begin at the root if the tree changed */
+			cb->args[5] = w->root->fn_sernum;
+			w->state = FWS_INIT;
+			w->node = w->root;
+			w->skip = w->count;
+		} else
+			w->skip = 0;
+
 		read_lock_bh(&table->tb6_lock);
 		res = fib6_walk_continue(w);
 		read_unlock_bh(&table->tb6_lock);
@@ -1250,9 +1264,18 @@ static int fib6_walk_continue(struct fib6_walker_t *w)
 			w->leaf = fn->leaf;
 		case FWS_C:
 			if (w->leaf && fn->fn_flags&RTN_RTINFO) {
-				int err = w->func(w);
+				int err;
+
+				if (w->count < w->skip) {
+					w->count++;
+					continue;
+				}
+
+				err = w->func(w);
 				if (err)
 					return err;
+
+				w->count++;
 				continue;
 			}
 			w->state = FWS_U;
@@ -1346,6 +1369,8 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 	c.w.root = root;
 	c.w.func = fib6_clean_node;
 	c.w.prune = prune;
+	c.w.count = 0;
+	c.w.skip = 0;
 	c.func = func;
 	c.arg = arg;
 	c.net = net;

--------------060504040709060202010303--
