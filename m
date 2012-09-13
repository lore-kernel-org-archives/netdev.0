From: pablo@netfilter.org
Subject: [PATCH 1/5] netfilter: fix crash during boot if NAT has been compiled built-in
Date: Thu, 13 Sep 2012 13:01:28 +0200
Message-ID: <1347534092-3579-2-git-send-email-pablo@netfilter.org>
References: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

(c7232c9 netfilter: add protocol independent NAT core) introduced a
problem that leads to crashing during boot due to NULL pointer
dereference. It seems that xt_nat calls xt_register_target() before
xt_init():

net/netfilter/x_tables.c:static struct xt_af *xt; is NULL and we crash on
xt_register_target(struct xt_target *target)
{
        u_int8_t af = target->family;
        int ret;

        ret = mutex_lock_interruptible(&xt[af].mutex);
...

Fix this by changing the linking order, to make sure that x_tables
comes before xt_nat.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 98244d4..0baa3f1 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -47,7 +47,6 @@ nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
 		   nf_nat_proto_udp.o nf_nat_proto_tcp.o nf_nat_helper.o
 
 obj-$(CONFIG_NF_NAT) += nf_nat.o
-obj-$(CONFIG_NF_NAT) += xt_nat.o
 
 # NAT protocols (nf_nat)
 obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
@@ -71,6 +70,7 @@ obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
 obj-$(CONFIG_NETFILTER_XT_SET) += xt_set.o
+obj-$(CONFIG_NF_NAT) += xt_nat.o
 
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_AUDIT) += xt_AUDIT.o
-- 
1.7.10.4

