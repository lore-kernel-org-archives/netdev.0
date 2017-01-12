From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net v3] ipv6: sr: fix several BUGs when preemption is enabled
Date: Thu, 12 Jan 2017 21:30:01 +0100
Message-ID: <1484253001-29677-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40871 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdALU3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:29:15 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id E186F67DDE5
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 21:29:04 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_PREEMPT=y, CONFIG_IPV6=m and CONFIG_SEG6_HMAC=y,
seg6_hmac_init() is called during the initialization of the ipv6 module.
This causes a subsequent call to smp_processor_id() with preemption
enabled, resulting in the following trace.

[   20.451460] BUG: using smp_processor_id() in preemptible [00000000] code: systemd/1
[   20.452556] caller is debug_smp_processor_id+0x17/0x19
[   20.453304] CPU: 0 PID: 1 Comm: systemd Not tainted 4.9.0-rc5-00973-g46738b1 #1
[   20.454406]  ffffc9000062fc18 ffffffff813607b2 0000000000000000 ffffffff81a7f782
[   20.455528]  ffffc9000062fc48 ffffffff813778dc 0000000000000000 00000000001dcf98
[   20.456539]  ffffffffa003bd08 ffffffff81af93e0 ffffc9000062fc58 ffffffff81377905
[   20.456539] Call Trace:
[   20.456539]  [<ffffffff813607b2>] dump_stack+0x63/0x7f
[   20.456539]  [<ffffffff813778dc>] check_preemption_disabled+0xd1/0xe3
[   20.456539]  [<ffffffff81377905>] debug_smp_processor_id+0x17/0x19
[   20.460260]  [<ffffffffa0061f3b>] seg6_hmac_init+0xfa/0x192 [ipv6]
[   20.460260]  [<ffffffffa0061ccc>] seg6_init+0x39/0x6f [ipv6]
[   20.460260]  [<ffffffffa006121a>] inet6_init+0x21a/0x321 [ipv6]
[   20.460260]  [<ffffffffa0061000>] ? 0xffffffffa0061000
[   20.460260]  [<ffffffff81000457>] do_one_initcall+0x8b/0x115
[   20.460260]  [<ffffffff811328a3>] do_init_module+0x53/0x1c4
[   20.460260]  [<ffffffff8110650a>] load_module+0x1153/0x14ec
[   20.460260]  [<ffffffff81106a7b>] SYSC_finit_module+0x8c/0xb9
[   20.460260]  [<ffffffff81106a7b>] ? SYSC_finit_module+0x8c/0xb9
[   20.460260]  [<ffffffff81106abc>] SyS_finit_module+0x9/0xb
[   20.460260]  [<ffffffff810014d1>] do_syscall_64+0x62/0x75
[   20.460260]  [<ffffffff816834f0>] entry_SYSCALL64_slow_path+0x25/0x25

Moreover, dst_cache_* functions also call smp_processor_id(), generating
a similar trace.

This patch uses raw_cpu_ptr() in seg6_hmac_init() rather than this_cpu_ptr()
and disable preemption when using dst_cache_* functions.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_hmac.c     | 2 +-
 net/ipv6/seg6_iptunnel.c | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index ef1c8a4..03a0648 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -400,7 +400,7 @@ static int seg6_hmac_init_algo(void)
 			*p_tfm = tfm;
 		}
 
-		p_tfm = this_cpu_ptr(algo->tfms);
+		p_tfm = raw_cpu_ptr(algo->tfms);
 		tfm = *p_tfm;
 
 		shsize = sizeof(*shash) + crypto_shash_descsize(tfm);
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index bbfca22..1d60cb1 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -265,7 +265,9 @@ int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	slwt = seg6_lwt_lwtunnel(orig_dst->lwtstate);
 
 #ifdef CONFIG_DST_CACHE
+	preempt_disable();
 	dst = dst_cache_get(&slwt->cache);
+	preempt_enable();
 #endif
 
 	if (unlikely(!dst)) {
@@ -286,7 +288,9 @@ int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 		}
 
 #ifdef CONFIG_DST_CACHE
+		preempt_disable();
 		dst_cache_set_ip6(&slwt->cache, dst, &fl6.saddr);
+		preempt_enable();
 #endif
 	}
 
-- 
2.7.3
