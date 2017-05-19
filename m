From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] netfilter: don't setup nat info for confirmed ct
Date: Fri, 19 May 2017 10:33:44 +0200
Message-ID: <1495182833-2272-4-git-send-email-pablo@netfilter.org>
References: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43958 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753545AbdESIeU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 04:34:20 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E53781DA08A
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CC773FF6FE
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7DF6FFF6FE
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:09 +0200 (CEST)
In-Reply-To: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

We cannot setup nat info if the ct has been confirmed already, else,
different cpu may race to handle the same ct. In extreme situation,
we may hit the "BUG_ON(nf_nat_initialized(ct, maniptype))" in the
nf_nat_setup_info.

Also running the following commands will easily hit NF_CT_ASSERT in
nf_conntrack_alter_reply:
  # nft flush ruleset
  # ping -c 2 -W 1 1.1.1.111 &
  # nft add table t
  # nft add chain t c {type nat hook postrouting priority 0 \;}
  # nft add rule t c snat to 4.5.6.7
  WARNING: CPU: 1 PID: 10065 at net/netfilter/nf_conntrack_core.c:1472
  nf_conntrack_alter_reply+0x9a/0x1a0 [nf_conntrack]
  [...]
  Call Trace:
   nf_nat_setup_info+0xad/0x840 [nf_nat]
   ? deactivate_slab+0x65d/0x6c0
   nft_nat_eval+0xcd/0x100 [nft_nat]
   nft_do_chain+0xff/0x5d0 [nf_tables]
   ? mark_held_locks+0x6f/0xa0
   ? __local_bh_enable_ip+0x70/0xa0
   ? trace_hardirqs_on_caller+0x11f/0x190
   ? ipt_do_table+0x310/0x610
   ? trace_hardirqs_on+0xd/0x10
   ? __local_bh_enable_ip+0x70/0xa0
   ? ipt_do_table+0x32b/0x610
   ? __lock_acquire+0x2ac/0x1580
   ? ipt_do_table+0x32b/0x610
   nft_nat_do_chain+0x65/0x80 [nft_chain_nat_ipv4]
   nf_nat_ipv4_fn+0x1ae/0x240 [nf_nat_ipv4]
   nf_nat_ipv4_out+0x4a/0xf0 [nf_nat_ipv4]
   nft_nat_ipv4_out+0x15/0x20 [nft_chain_nat_ipv4]
   nf_hook_slow+0x2c/0xf0
   ip_output+0x154/0x270

So for the confirmed ct, just ignore it and return NF_ACCEPT.

Fixes: 9a08ecfe74d7 ("netfilter: don't attach a nat extension by default")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index b48d6b5aae8a..ef0be325a0c6 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -409,6 +409,10 @@ nf_nat_setup_info(struct nf_conn *ct,
 {
 	struct nf_conntrack_tuple curr_tuple, new_tuple;
 
+	/* Can't setup nat info for confirmed ct. */
+	if (nf_ct_is_confirmed(ct))
+		return NF_ACCEPT;
+
 	NF_CT_ASSERT(maniptype == NF_NAT_MANIP_SRC ||
 		     maniptype == NF_NAT_MANIP_DST);
 	BUG_ON(nf_nat_initialized(ct, maniptype));
-- 
2.1.4
