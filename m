From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] [net-next] udp: provide udp{4,6}_lib_lookup for nf_socket_ipv{4,6}
Date: Tue,  8 Nov 2016 14:28:18 +0100
Message-ID: <20161108132914.1495283-1-arnd@arndb.de>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
the udp6_lib_lookup and udp4_lib_lookup functions are only
provided when it is actually possible to call them.

However, moving the callers now caused a link error:

net/built-in.o: In function `nf_sk_lookup_slow_v6':
(.text+0x131a39): undefined reference to `udp6_lib_lookup'
net/ipv4/netfilter/nf_socket_ipv4.o: In function `nf_sk_lookup_slow_v4':
nf_socket_ipv4.c:(.text.nf_sk_lookup_slow_v4+0x114): undefined reference to `udp4_lib_lookup'

This extends the #ifdef so we also provide the functions when
CONFIG_NF_SOCKET_IPV4 or CONFIG_NF_SOCKET_IPV6, respectively
are set.

Fixes: 8db4c5be88f6 ("netfilter: move socket lookup infrastructure to nf_socket_ipv{4,6}.c")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
The build failure came from the netfilter tree but is now
present in net-next, so if the solution is correct, this
patch can be applied there.
---
 net/ipv4/udp.c | 3 ++-
 net/ipv6/udp.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 097b70628631..c827e4ea509e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -580,7 +580,8 @@ EXPORT_SYMBOL_GPL(udp4_lib_lookup_skb);
  * Does increment socket refcount.
  */
 #if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
-    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
+    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY) || \
+    IS_ENABLED(CONFIG_NF_SOCKET_IPV4)
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif)
 {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5313818b7485..86a8cacd333b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -302,7 +302,8 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup_skb);
  * Does increment socket refcount.
  */
 #if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
-    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
+    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY) || \
+    IS_ENABLED(CONFIG_NF_SOCKET_IPV6)
 struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport, int dif)
 {
-- 
2.9.0
