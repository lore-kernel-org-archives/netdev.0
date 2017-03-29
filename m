From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/8] netfilter: nf_ct_ext: fix possible panic after nf_ct_extend_unregister
Date: Wed, 29 Mar 2017 14:14:08 +0200
Message-ID: <1490789650-7294-7-git-send-email-pablo@netfilter.org>
References: <1490789650-7294-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43800 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756098AbdC2MPe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 08:15:34 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9E7F4EBAC9
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7D6E1DA391
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8E002DA8FF
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:15:26 +0200 (CEST)
In-Reply-To: <1490789650-7294-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

If one cpu is doing nf_ct_extend_unregister while another cpu is doing
__nf_ct_ext_add_length, then we may hit BUG_ON(t == NULL). Moreover,
there's no synchronize_rcu invocation after set nf_ct_ext_types[id] to
NULL, so it's possible that we may access invalid pointer.

But actually, most of the ct extends are built-in, so the problem listed
above will not happen. However, there are two exceptions: NF_CT_EXT_NAT
and NF_CT_EXT_SYNPROXY.

For _EXT_NAT, the panic will not happen, since adding the nat extend and
unregistering the nat extend are located in the same file(nf_nat_core.c),
this means that after the nat module is removed, we cannot add the nat
extend too.

For _EXT_SYNPROXY, synproxy extend may be added by init_conntrack, while
synproxy extend unregister will be done by synproxy_core_exit. So after
nf_synproxy_core.ko is removed, we may still try to add the synproxy
extend, then kernel panic may happen.

I know it's very hard to reproduce this issue, but I can play a tricky
game to make it happen very easily :)

Step 1. Enable SYNPROXY for tcp dport 1234 at FORWARD hook:
  # iptables -I FORWARD -p tcp --dport 1234 -j SYNPROXY
Step 2. Queue the syn packet to the userspace at raw table OUTPUT hook.
        Also note, in the userspace we only add a 20s' delay, then
        reinject the syn packet to the kernel:
  # iptables -t raw -I OUTPUT -p tcp --syn -j NFQUEUE --queue-num 1
Step 3. Using "nc 2.2.2.2 1234" to connect the server.
Step 4. Now remove the nf_synproxy_core.ko quickly:
  # iptables -F FORWARD
  # rmmod ipt_SYNPROXY
  # rmmod nf_synproxy_core
Step 5. After 20s' delay, the syn packet is reinjected to the kernel.

Now you will see the panic like this:
  kernel BUG at net/netfilter/nf_conntrack_extend.c:91!
  Call Trace:
   ? __nf_ct_ext_add_length+0x53/0x3c0 [nf_conntrack]
   init_conntrack+0x12b/0x600 [nf_conntrack]
   nf_conntrack_in+0x4cc/0x580 [nf_conntrack]
   ipv4_conntrack_local+0x48/0x50 [nf_conntrack_ipv4]
   nf_reinject+0x104/0x270
   nfqnl_recv_verdict+0x3e1/0x5f9 [nfnetlink_queue]
   ? nfqnl_recv_verdict+0x5/0x5f9 [nfnetlink_queue]
   ? nla_parse+0xa0/0x100
   nfnetlink_rcv_msg+0x175/0x6a9 [nfnetlink]
   [...]

One possible solution is to make NF_CT_EXT_SYNPROXY extend built-in, i.e.
introduce nf_conntrack_synproxy.c and only do ct extend register and
unregister in it, similar to nf_conntrack_timeout.c.

But having such a obscure restriction of nf_ct_extend_unregister is not a
good idea, so we should invoke synchronize_rcu after set nf_ct_ext_types
to NULL, and check the NULL pointer when do __nf_ct_ext_add_length. Then
it will be easier if we add new ct extend in the future.

Last, we use kfree_rcu to free nf_ct_ext, so rcu_barrier() is unnecessary
anymore, remove it too.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_extend.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 02bcf00c2492..008299b7f78f 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -53,7 +53,11 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id,
 
 	rcu_read_lock();
 	t = rcu_dereference(nf_ct_ext_types[id]);
-	BUG_ON(t == NULL);
+	if (!t) {
+		rcu_read_unlock();
+		return NULL;
+	}
+
 	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
 	len = off + t->len + var_alloc_len;
 	alloc_size = t->alloc_size + var_alloc_len;
@@ -88,7 +92,10 @@ void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
 
 	rcu_read_lock();
 	t = rcu_dereference(nf_ct_ext_types[id]);
-	BUG_ON(t == NULL);
+	if (!t) {
+		rcu_read_unlock();
+		return NULL;
+	}
 
 	newoff = ALIGN(old->len, t->align);
 	newlen = newoff + t->len + var_alloc_len;
@@ -175,6 +182,6 @@ void nf_ct_extend_unregister(struct nf_ct_ext_type *type)
 	RCU_INIT_POINTER(nf_ct_ext_types[type->id], NULL);
 	update_alloc_size(type);
 	mutex_unlock(&nf_ct_ext_type_mutex);
-	rcu_barrier(); /* Wait for completion of call_rcu()'s */
+	synchronize_rcu();
 }
 EXPORT_SYMBOL_GPL(nf_ct_extend_unregister);
-- 
2.1.4
