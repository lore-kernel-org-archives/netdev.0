From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] netfilter: conntrack race between dump_table and destroy
Date: Wed, 24 Nov 2010 22:27:16 -0800
Message-ID: <20101124222716.437c5547@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A customer reported a crash and the backtrace showed that
ctnetlink_dump_table was running while a conntrack entry was
being destroyed.  It looks like the code for walking the table
with hlist_nulls_for_each_entry_rcu is not correctly handling the
case where it finds a deleted entry.

According to RCU documentation, when using hlist_nulls the reader
must handle the case of seeing a deleted entry and not proceed
further down the linked list.  For lookup the correct behavior would
be to restart the scan, but that would generate duplicate entries.

This patch is the simplest one of three alternatives:
  1) if dead entry detected, skip the rest of the hash chain (see below)
  2) remember skb location at start of hash chain and rescan that chain
  3) switch to using a full lock when scanning rather than RCU.
It all depends on the amount of effort versus consistency of results.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:11:27.661682148 -0800
+++ b/net/netfilter/nf_conntrack_netlink.c	2010-11-24 14:22:28.431980247 -0800
@@ -651,8 +651,12 @@ restart:
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
 			ct = nf_ct_tuplehash_to_ctrack(h);
+
+			/* if entry is being deleted then can not proceed
+			 * past this point. */
 			if (!atomic_inc_not_zero(&ct->ct_general.use))
-				continue;
+				break;
+
 			/* Dump entries of a given L3 protocol number.
 			 * If it is not specified, ie. l3proto == 0,
 			 * then dump everything. */
