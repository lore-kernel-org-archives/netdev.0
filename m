From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net] ipv6: sr: fix BUG in HMAC init when preemption is enabled
Date: Tue, 10 Jan 2017 14:39:22 +0100
Message-ID: <1484055562-6414-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:55698 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765664AbdAJNoh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 08:44:37 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id 2DA8367DCE8
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 14:38:39 +0100 (CET)
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

This patch disable BHs in seg6_hmac_init() and seg6_hmac_exit(). BHs are
re-enabled for the call to crypto_alloc_shash. Indeed, this function might
call try_module_get(), which cannot be called in atomic context.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_hmac.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index ef1c8a4..ab2ceb4 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -363,7 +363,7 @@ static int seg6_hmac_init_ring(void)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		char *ring = kzalloc(SEG6_HMAC_RING_SIZE, GFP_KERNEL);
+		char *ring = kzalloc(SEG6_HMAC_RING_SIZE, GFP_ATOMIC);
 
 		if (!ring)
 			return -ENOMEM;
@@ -393,7 +393,9 @@ static int seg6_hmac_init_algo(void)
 			return -ENOMEM;
 
 		for_each_possible_cpu(cpu) {
-			tfm = crypto_alloc_shash(algo->name, 0, GFP_KERNEL);
+			local_bh_enable();
+			tfm = crypto_alloc_shash(algo->name, 0, GFP_ATOMIC);
+			local_bh_disable();
 			if (IS_ERR(tfm))
 				return PTR_ERR(tfm);
 			p_tfm = per_cpu_ptr(algo->tfms, cpu);
@@ -410,7 +412,7 @@ static int seg6_hmac_init_algo(void)
 			return -ENOMEM;
 
 		for_each_possible_cpu(cpu) {
-			shash = kzalloc(shsize, GFP_KERNEL);
+			shash = kzalloc(shsize, GFP_ATOMIC);
 			if (!shash)
 				return -ENOMEM;
 			*per_cpu_ptr(algo->shashs, cpu) = shash;
@@ -424,6 +426,8 @@ int __init seg6_hmac_init(void)
 {
 	int ret;
 
+	local_bh_disable();
+
 	ret = seg6_hmac_init_ring();
 	if (ret < 0)
 		goto out;
@@ -431,6 +435,7 @@ int __init seg6_hmac_init(void)
 	ret = seg6_hmac_init_algo();
 
 out:
+	local_bh_enable();
 	return ret;
 }
 EXPORT_SYMBOL(seg6_hmac_init);
@@ -450,6 +455,8 @@ void seg6_hmac_exit(void)
 	struct seg6_hmac_algo *algo = NULL;
 	int i, alg_count, cpu;
 
+	local_bh_disable();
+
 	for_each_possible_cpu(i) {
 		char *ring = *per_cpu_ptr(hmac_ring, i);
 
@@ -472,6 +479,8 @@ void seg6_hmac_exit(void)
 		free_percpu(algo->tfms);
 		free_percpu(algo->shashs);
 	}
+
+	local_bh_enable();
 }
 EXPORT_SYMBOL(seg6_hmac_exit);
 
-- 
2.7.3
