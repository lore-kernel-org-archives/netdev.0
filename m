From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3] ipv6: Kill ipv6 dependency of icmpv6_send().
Date: Thu, 25 Apr 2013 14:08:30 -0700
Message-ID: <1366924110-3397-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:35210 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756857Ab3DYVIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 17:08:34 -0400
Received: by mail-da0-f72.google.com with SMTP id x28so2830605dad.3
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 14:08:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds icmp-registration module for ipv6.  It allows
ipv6 protocol to register icmp_sender which is used for sending
ipv6 icmp msgs.  This extra layer allows us to kill ipv6 dependency
for sending icmp packets.

This patch also fixes ip_tunnel compilation problem when ip_tunnel
is statically compiled in kernel but ipv6 is module

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2-v3:
 - Fix sparse warning.
v1-v2:
 - Used cmpxchg() to set icmp handler.
---
 include/linux/icmpv6.h |   18 +++++++++++++++---
 net/ipv6/Makefile      |    2 +-
 net/ipv6/icmp.c        |   35 ++++++++++++++++++++---------------
 net/ipv6/ip6_icmp.c    |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 83 insertions(+), 19 deletions(-)
 create mode 100644 net/ipv6/ip6_icmp.c

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index b4f6c29..630f453 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -11,9 +11,21 @@ static inline struct icmp6hdr *icmp6_hdr(const struct sk_buff *skb)
 
 #include <linux/netdevice.h>
 
-extern void				icmpv6_send(struct sk_buff *skb,
-						    u8 type, u8 code,
-						    __u32 info);
+#if IS_ENABLED(CONFIG_IPV6)
+extern void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info);
+
+typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info);
+extern int inet6_register_icmp_sender(ip6_icmp_send_t *fn);
+extern int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn);
+
+#else
+
+static inline void icmpv6_send(struct sk_buff *skb,
+			       u8 type, u8 code, __u32 info)
+{
+
+}
+#endif
 
 extern int				icmpv6_init(void);
 extern int				icmpv6_err_convert(u8 type, u8 code,
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 309af19..9af088d 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -40,7 +40,7 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
-obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o
+obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 71b900c..2a53a79 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -124,15 +124,6 @@ static __inline__ void icmpv6_xmit_unlock(struct sock *sk)
 }
 
 /*
- * Slightly more convenient version of icmpv6_send.
- */
-void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
-{
-	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos);
-	kfree_skb(skb);
-}
-
-/*
  * Figure out, may we reply to this packet with icmp error.
  *
  * We do not reply, if:
@@ -332,7 +323,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *sk
 	 * anycast.
 	 */
 	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: acast source\n");
+		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: acast source\n");
 		dst_release(dst);
 		return ERR_PTR(-EINVAL);
 	}
@@ -381,7 +372,7 @@ relookup_failed:
 /*
  *	Send an ICMP message in response to a packet in error
  */
-void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
+static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	struct inet6_dev *idev = NULL;
@@ -406,7 +397,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	/*
 	 *	Make sure we respect the rules
 	 *	i.e. RFC 1885 2.4(e)
-	 *	Rule (e.1) is enforced by not using icmpv6_send
+	 *	Rule (e.1) is enforced by not using icmp6_send
 	 *	in any code that processes icmp errors.
 	 */
 	addr_type = ipv6_addr_type(&hdr->daddr);
@@ -444,7 +435,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	and anycast addresses will be checked later.
 	 */
 	if ((addr_type == IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTICAST)) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n");
+		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: addr_any/mcast source\n");
 		return;
 	}
 
@@ -452,7 +443,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	Never answer to a ICMP packet.
 	 */
 	if (is_ineligible(skb)) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: no reply to icmp error\n");
+		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: no reply to icmp error\n");
 		return;
 	}
 
@@ -529,7 +520,14 @@ out_dst_release:
 out:
 	icmpv6_xmit_unlock(sk);
 }
-EXPORT_SYMBOL(icmpv6_send);
+
+/* Slightly more convenient version of icmp6_send.
+ */
+void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
+{
+	icmp6_send(skb, ICMPV6_PARAMPROB, code, pos);
+	kfree_skb(skb);
+}
 
 static void icmpv6_echo_reply(struct sk_buff *skb)
 {
@@ -885,8 +883,14 @@ int __init icmpv6_init(void)
 	err = -EAGAIN;
 	if (inet6_add_protocol(&icmpv6_protocol, IPPROTO_ICMPV6) < 0)
 		goto fail;
+
+	err = inet6_register_icmp_sender(icmp6_send);
+	if (err)
+		goto sender_reg_err;
 	return 0;
 
+sender_reg_err:
+	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);
 fail:
 	pr_err("Failed to register ICMP6 protocol\n");
 	unregister_pernet_subsys(&icmpv6_sk_ops);
@@ -895,6 +899,7 @@ fail:
 
 void icmpv6_cleanup(void)
 {
+	inet6_unregister_icmp_sender(icmp6_send);
 	unregister_pernet_subsys(&icmpv6_sk_ops);
 	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);
 }
diff --git a/net/ipv6/ip6_icmp.c b/net/ipv6/ip6_icmp.c
new file mode 100644
index 0000000..4578e23
--- /dev/null
+++ b/net/ipv6/ip6_icmp.c
@@ -0,0 +1,47 @@
+#include <linux/export.h>
+#include <linux/icmpv6.h>
+#include <linux/mutex.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+
+#include <net/ipv6.h>
+
+#if IS_ENABLED(CONFIG_IPV6)
+
+static ip6_icmp_send_t __rcu *ip6_icmp_send;
+
+int inet6_register_icmp_sender(ip6_icmp_send_t *fn)
+{
+	return (cmpxchg((ip6_icmp_send_t **)&ip6_icmp_send, NULL, fn) == NULL) ?
+	        0 : -EBUSY;
+}
+EXPORT_SYMBOL(inet6_register_icmp_sender);
+
+int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn)
+{
+	int ret;
+
+	ret = (cmpxchg((ip6_icmp_send_t **)&ip6_icmp_send, fn, NULL) == fn) ?
+	      0 : -EINVAL;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(inet6_unregister_icmp_sender);
+
+void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
+{
+	ip6_icmp_send_t *send;
+
+	rcu_read_lock();
+	send = rcu_dereference(ip6_icmp_send);
+
+	if (!send)
+		goto out;
+	send(skb, type, code, info);
+out:
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(icmpv6_send);
+#endif
-- 
1.7.1
