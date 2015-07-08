From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] netfilter: arptables: use percpu jumpstack
Date: Wed,  8 Jul 2015 11:48:16 +0200
Message-ID: <1436348900-13130-4-git-send-email-pablo@netfilter.org>
References: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

commit 482cfc318559 ("netfilter: xtables: avoid percpu ruleset duplication")

Unlike ip and ip6tables, arp tables were never converted to use the percpu
jump stack.

It still uses the rule blob to store return address, which isn't safe
anymore since we now share this blob among all processors.

Because there is no TEE support for arptables, we don't need to cope
with reentrancy, so we can use loocal variable to hold stack offset.

Fixes: 482cfc318559 ("netfilter: xtables: avoid percpu ruleset duplication")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 95c9b6e..92305a1 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -254,9 +254,10 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	unsigned int verdict = NF_DROP;
 	const struct arphdr *arp;
-	struct arpt_entry *e, *back;
+	struct arpt_entry *e, **jumpstack;
 	const char *indev, *outdev;
 	const void *table_base;
+	unsigned int cpu, stackidx = 0;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
 	unsigned int addend;
@@ -270,15 +271,16 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
 	private = table->private;
+	cpu     = smp_processor_id();
 	/*
 	 * Ensure we load private-> members after we've fetched the base
 	 * pointer.
 	 */
 	smp_read_barrier_depends();
 	table_base = private->entries;
+	jumpstack  = (struct arpt_entry **)private->jumpstack[cpu];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
-	back = get_entry(table_base, private->underflow[hook]);
 
 	acpar.in      = state->in;
 	acpar.out     = state->out;
@@ -312,18 +314,23 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 					verdict = (unsigned int)(-v) - 1;
 					break;
 				}
-				e = back;
-				back = get_entry(table_base, back->comefrom);
+				if (stackidx == 0) {
+					e = get_entry(table_base,
+						      private->underflow[hook]);
+				} else {
+					e = jumpstack[--stackidx];
+					e = arpt_next_entry(e);
+				}
 				continue;
 			}
 			if (table_base + v
 			    != arpt_next_entry(e)) {
-				/* Save old back ptr in next entry */
-				struct arpt_entry *next = arpt_next_entry(e);
-				next->comefrom = (void *)back - table_base;
 
-				/* set back pointer to next entry */
-				back = next;
+				if (stackidx >= private->stacksize) {
+					verdict = NF_DROP;
+					break;
+				}
+				jumpstack[stackidx++] = e;
 			}
 
 			e = get_entry(table_base, v);
-- 
1.7.10.4

