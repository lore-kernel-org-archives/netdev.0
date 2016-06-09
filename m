From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Fix crash when IPv6 is disabled at boot time
Date: Thu,  9 Jun 2016 10:21:00 -0700
Message-ID: <1465492860-19246-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34970 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbcFIRVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 13:21:10 -0400
Received: by mail-pa0-f42.google.com with SMTP id hl6so15045706pac.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 10:21:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Kellermann reported a kernel crash with 4.5.0 when IPv6 is
disabled at boot using the kernel option ipv6.disable=1. Using
current net-next with the boot option:

$ ip link add red type vrf table 1001

Generates:
[12210.919584] BUG: unable to handle kernel NULL pointer dereference at 0000000000000748
[12210.921341] IP: [<ffffffff814b30e3>] fib6_get_table+0x2c/0x5a
[12210.922537] PGD b79e3067 PUD bb32b067 PMD 0
[12210.923479] Oops: 0000 [#1] SMP
[12210.924001] Modules linked in: ipvlan 8021q garp mrp stp llc
[12210.925130] CPU: 3 PID: 1177 Comm: ip Not tainted 4.7.0-rc1+ #235
[12210.926168] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[12210.928065] task: ffff8800b9ac4640 ti: ffff8800bacac000 task.ti: ffff8800bacac000
[12210.929328] RIP: 0010:[<ffffffff814b30e3>]  [<ffffffff814b30e3>] fib6_get_table+0x2c/0x5a
[12210.930697] RSP: 0018:ffff8800bacaf888  EFLAGS: 00010202
[12210.931563] RAX: 0000000000000748 RBX: ffffffff81a9e280 RCX: ffff8800b9ac4e28
[12210.932688] RDX: 00000000000000e9 RSI: 0000000000000002 RDI: 0000000000000286
[12210.933820] RBP: ffff8800bacaf898 R08: ffff8800b9ac4df0 R09: 000000000052001b
[12210.934941] R10: 00000000657c0000 R11: 000000000000c649 R12: 00000000000003e9
[12210.936032] R13: 00000000000003e9 R14: ffff8800bace7800 R15: ffff8800bb3ec000
[12210.937103] FS:  00007faa1766c700(0000) GS:ffff88013ac00000(0000) knlGS:0000000000000000
[12210.938321] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[12210.939166] CR2: 0000000000000748 CR3: 00000000b79d6000 CR4: 00000000000406e0
[12210.940278] Stack:
[12210.940603]  ffff8800bb3ec000 ffffffff81a9e280 ffff8800bacaf8c8 ffffffff814b3135
[12210.941818]  ffff8800bb3ec000 ffffffff81a9e280 ffffffff81a9e280 ffff8800bace7800
[12210.943040]  ffff8800bacaf8f0 ffffffff81397c88 ffff8800bb3ec000 ffffffff81a9e280
[12210.944288] Call Trace:
[12210.944688]  [<ffffffff814b3135>] fib6_new_table+0x24/0x8a
[12210.945516]  [<ffffffff81397c88>] vrf_dev_init+0xd4/0x162
[12210.946328]  [<ffffffff814091e1>] register_netdevice+0x100/0x396
[12210.947209]  [<ffffffff8139823d>] vrf_newlink+0x40/0xb3
[12210.948001]  [<ffffffff814187f0>] rtnl_newlink+0x5d3/0x6d5
...

The problem above is due to the fact that the fib hash table is not
allocated when IPv6 is disabled at boot.

As for the VRF driver it should not do any IPv6 initializations if IPv6
is disabled, so it needs to know if IPv6 is disabled at boot. The disable
parameter is private to the IPv6 module, so provide an accessor for
modules to determine if IPv6 was disabled at boot time.

Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 7 +++++++
 include/linux/ipv6.h | 7 +++++++
 net/ipv6/af_inet6.c  | 6 ++++++
 3 files changed, 20 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b82e3527924e..b4d746943bc5 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -407,6 +407,10 @@ static int vrf_rt6_create(struct net_device *dev)
 	struct rt6_info *rt6, *rt6_local;
 	int rc = -ENOMEM;
 
+	/* IPv6 can be CONFIG enabled and then disabled runtime */
+	if (!ipv6_mod_enabled())
+		return 0;
+
 	rt6i_table = fib6_new_table(net, vrf->tb_id);
 	if (!rt6i_table)
 		goto out;
@@ -919,6 +923,9 @@ static int vrf_fib_rule(const struct net_device *dev, __u8 family, bool add_it)
 	struct sk_buff *skb;
 	int err;
 
+	if (family == AF_INET6 && !ipv6_mod_enabled())
+		return 0;
+
 	skb = nlmsg_new(vrf_fib_rule_nl_size(), GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5c91b0b055d4..c6dbcd84a2c7 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -283,6 +283,8 @@ struct tcp6_timewait_sock {
 };
 
 #if IS_ENABLED(CONFIG_IPV6)
+bool ipv6_mod_enabled(void);
+
 static inline struct ipv6_pinfo *inet6_sk(const struct sock *__sk)
 {
 	return sk_fullsock(__sk) ? inet_sk(__sk)->pinet6 : NULL;
@@ -326,6 +328,11 @@ static inline int inet_v6_ipv6only(const struct sock *sk)
 #define ipv6_only_sock(sk)	0
 #define ipv6_sk_rxinfo(sk)	0
 
+static inline bool ipv6_mod_enabled(void)
+{
+	return false;
+}
+
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
 	return NULL;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index bfa86f040c16..2076c21107d0 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -92,6 +92,12 @@ MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on all interfaces");
 module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444);
 MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfiguration on all interfaces");
 
+bool ipv6_mod_enabled(void)
+{
+	return disable_ipv6_mod == 0;
+}
+EXPORT_SYMBOL_GPL(ipv6_mod_enabled);
+
 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
 	const int offset = sk->sk_prot->obj_size - sizeof(struct ipv6_pinfo);
-- 
2.1.4
