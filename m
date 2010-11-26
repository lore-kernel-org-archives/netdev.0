From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netfilter:  fix  race in conntrack between dump_table and
 destroy
Date: Fri, 26 Nov 2010 13:51:01 -0800
Message-ID: <20101126135101.4e4b97cc@nehalam>
References: <20101124222716.437c5547@nehalam>
	<1290666873.2798.89.camel@edumazet-laptop>
	<20101124230004.1dc28e5a@nehalam>
	<1290669214.2798.109.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290669214.2798.109.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netlink interface to dump the connection tracking table has a race
when entries are deleted at the same time. A customer reported a crash 
and the backtrace showed thatctnetlink_dump_table was running while a 
conntrack entry wasbeing destroyed.
(see https://bugzilla.vyatta.com/show_bug.cgi?id=6402).

According to RCU documentation, when using hlist_nulls the reader
must handle the case of seeing a deleted entry and not proceed
further down the linked list.  The old code would continue
which caused the scan to walk into the free list. 

This patch uses locking (rather than RCU) for this operation which
is guaranteed safe, and no longer requires getting reference while
doing dump operation.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/netfilter/nf_conntrack_netlink.c	2010-11-25 21:49:11.401158365 -0800
+++ b/net/netfilter/nf_conntrack_netlink.c	2010-11-25 22:18:08.164421697 -0800
@@ -642,25 +642,23 @@ ctnetlink_dump_table(struct sk_buff *skb
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
 
-	rcu_read_lock();
+	spin_lock_bh(&nf_conntrack_lock);
 	last = (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < net->ct.htable_size; cb->args[0]++) {
 restart:
-		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[cb->args[0]],
+		hlist_nulls_for_each_entry(h, n, &net->ct.hash[cb->args[0]],
 					 hnnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
 			ct = nf_ct_tuplehash_to_ctrack(h);
-			if (!atomic_inc_not_zero(&ct->ct_general.use))
-				continue;
 			/* Dump entries of a given L3 protocol number.
 			 * If it is not specified, ie. l3proto == 0,
 			 * then dump everything. */
 			if (l3proto && nf_ct_l3num(ct) != l3proto)
-				goto releasect;
+				continue;
 			if (cb->args[1]) {
 				if (ct != last)
-					goto releasect;
+					continue;
 				cb->args[1] = 0;
 			}
 			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
@@ -678,8 +676,6 @@ restart:
 				if (acct)
 					memset(acct, 0, sizeof(struct nf_conn_counter[IP_CT_DIR_MAX]));
 			}
-releasect:
-		nf_ct_put(ct);
 		}
 		if (cb->args[1]) {
 			cb->args[1] = 0;
@@ -687,7 +683,7 @@ releasect:
 		}
 	}
 out:
-	rcu_read_unlock();
+	spin_unlock_bh(&nf_conntrack_lock);
 	if (last)
 		nf_ct_put(last);
 
