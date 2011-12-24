From: pablo@netfilter.org
Subject: [PATCH 2/2] netfilter: ctnetlink: fix scheduling while atomic if helper is autoloaded
Date: Sat, 24 Dec 2011 19:52:48 +0100
Message-ID: <1324752768-5853-3-git-send-email-pablo@netfilter.org>
References: <1324752768-5853-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324752768-5853-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes one scheduling while atomic error:

[  385.565186] ctnetlink v0.93: registering with nfnetlink.
[  385.565349] BUG: scheduling while atomic: lt-expect_creat/16163/0x00000200

It can be triggered with utils/expect_create included in
libnetfilter_conntrack if the FTP helper is not loaded.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 3d7ea7a..b697777 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1358,12 +1358,15 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 						    nf_ct_protonum(ct));
 		if (helper == NULL) {
 			rcu_read_unlock();
+			spin_unlock_bh(&nf_conntrack_lock);
 #ifdef CONFIG_MODULES
 			if (request_module("nfct-helper-%s", helpname) < 0) {
+				spin_lock_bh(&nf_conntrack_lock);
 				err = -EOPNOTSUPP;
 				goto err1;
 			}
 
+			spin_lock_bh(&nf_conntrack_lock);
 			rcu_read_lock();
 			helper = __nf_conntrack_helper_find(helpname,
 							    nf_ct_l3num(ct),
-- 
1.7.2.5

