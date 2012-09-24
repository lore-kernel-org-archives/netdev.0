From: pablo@netfilter.org
Subject: [PATCH 02/16] netfilter: nf_nat: fix oops when unloading protocol modules
Date: Mon, 24 Sep 2012 21:19:14 +0200
Message-ID: <1348514369-3272-3-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58076 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757871Ab2IXTU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:20:56 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

When unloading a protocol module nf_ct_iterate_cleanup() is used to
remove all conntracks using the protocol from the bysource hash and
clean their NAT sections. Since the conntrack isn't actually killed,
the NAT callback is invoked twice, once for each direction, which
causes an oops when trying to delete it from the bysource hash for
the second time.

The same oops can also happen when removing both an L3 and L4 protocol
since the cleanup function doesn't check whether the conntrack has
already been cleaned up.

Pid: 4052, comm: modprobe Not tainted 3.6.0-rc3-test-nat-unload-fix+ #32 Red Hat KVM
RIP: 0010:[<ffffffffa002c303>]  [<ffffffffa002c303>] nf_nat_proto_clean+0x73/0xd0 [nf_nat]
RSP: 0018:ffff88007808fe18  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8800728550c0 RCX: ffff8800756288b0
RDX: dead000000200200 RSI: ffff88007808fe88 RDI: ffffffffa002f208
RBP: ffff88007808fe28 R08: ffff88007808e000 R09: 0000000000000000
R10: dead000000200200 R11: dead000000100100 R12: ffffffff81c6dc00
R13: ffff8800787582b8 R14: ffff880078758278 R15: ffff88007808fe88
FS:  00007f515985d700(0000) GS:ffff88007cd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f515986a000 CR3: 000000007867a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 4052, threadinfo ffff88007808e000, task ffff8800756288b0)
Stack:
 ffff88007808fe68 ffffffffa002c290 ffff88007808fe78 ffffffff815614e3
 ffffffff00000000 00000aeb00000246 ffff88007808fe68 ffffffff81c6dc00
 ffff88007808fe88 ffffffffa00358a0 0000000000000000 000000000040f5b0
Call Trace:
 [<ffffffffa002c290>] ? nf_nat_net_exit+0x50/0x50 [nf_nat]
 [<ffffffff815614e3>] nf_ct_iterate_cleanup+0xc3/0x170
 [<ffffffffa002c55a>] nf_nat_l3proto_unregister+0x8a/0x100 [nf_nat]
 [<ffffffff812a0303>] ? compat_prepare_timeout+0x13/0xb0
 [<ffffffffa0035848>] nf_nat_l3proto_ipv4_exit+0x10/0x23 [nf_nat_ipv4]
 ...

To fix this,

- check whether the conntrack has already been cleaned up in
  nf_nat_proto_clean

- change nf_ct_iterate_cleanup() to only invoke the callback function
  once for each conntrack (IP_CT_DIR_ORIGINAL).

The second change doesn't affect other callers since when conntracks are
actually killed, both directions are removed from the hash immediately
and the callback is already only invoked once. If it is not killed, the
second callback invocation will always return the same decision not to
kill it.

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |    2 ++
 net/netfilter/nf_nat_core.c       |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index dcb2791..0f241be 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1224,6 +1224,8 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	spin_lock_bh(&nf_conntrack_lock);
 	for (; *bucket < net->ct.htable_size; (*bucket)++) {
 		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
+			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
+				continue;
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			if (iter(ct, data))
 				goto found;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 1816ad3..65cf694 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -481,6 +481,8 @@ static int nf_nat_proto_clean(struct nf_conn *i, void *data)
 
 	if (!nat)
 		return 0;
+	if (!(i->status & IPS_SRC_NAT_DONE))
+		return 0;
 	if ((clean->l3proto && nf_ct_l3num(i) != clean->l3proto) ||
 	    (clean->l4proto && nf_ct_protonum(i) != clean->l4proto))
 		return 0;
-- 
1.7.10.4
