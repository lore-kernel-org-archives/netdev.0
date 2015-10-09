From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: turn NF_HOOK into an inline function
Date: Fri, 09 Oct 2015 14:45:20 +0200
Message-ID: <7665226.mEs2QJDTOT@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent change to the dst_output handling caused a new warning
when the call to NF_HOOK() is the only used of a local variable
passed as 'dev', and CONFIG_NETFILTER is disabled:

net/ipv6/ip6_output.c: In function 'ip6_output':
net/ipv6/ip6_output.c:135:21: warning: unused variable 'dev' [-Wunused-variable]

The reason for this is that the NF_HOOK macro in this case does
not reference the variable at all. To avoid that warning now
and in the future, this changes the macro into an equivalent
inline function, which tells the compiler that the variable is
passed correctly but still unused.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: ede2059dbaf9 ("dst: Pass net into dst->output")

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index edb3dc32f1da..1ff5c3f82820 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -347,8 +347,23 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 }
 
 #else /* !CONFIG_NETFILTER */
-#define NF_HOOK(pf, hook, net, sk, skb, indev, outdev, okfn) (okfn)(net, sk, skb)
-#define NF_HOOK_COND(pf, hook, net, sk, skb, indev, outdev, okfn, cond) (okfn)(net, sk, skb)
+static inline int
+NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
+	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
+	     int (*okfn)(struct net *, struct sock *, struct sk_buff *),
+	     bool cond)
+{
+	return okfn(net, sk, skb);
+}
+
+static inline int
+NF_HOOK(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk, struct sk_buff *skb,
+	struct net_device *in, struct net_device *out,
+	int (*okfn)(struct net *, struct sock *, struct sk_buff *))
+{
+	return okfn(net, sk, skb);
+}
+
 static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 			  struct sock *sk, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
