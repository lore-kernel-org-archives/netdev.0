From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH RFC 4/4] kgdb: Quiesce IO back-end before rounding up
 secondary CPUs
Date: Wed, 7 Jul 2010 21:13:38 +0400
Message-ID: <20100707171338.GD20015@oksana.dev.rtsoft.ru>
References: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wessel <jason.wessel@windriver.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: kgdb-bugreport@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63004 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823Ab0GGRNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 13:13:42 -0400
Received: by mail-ey0-f174.google.com with SMTP id 25so236905eya.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 10:13:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KGDB may try to roundup secondary CPUs while they're in the IO
back-end code (e.g. NAPI is polling an eth device), so the
secondary CPU might stop processing IO at a random place, which
may cause the IO back-end to become unusable for KGDB itself.

This patch implements try_quiesce and activate KGDB IO callbacks,
so that we quiesce the IO back-end before rounding up the CPUs.
So far it's only implemented for KGDBoE driver.

Note that we have to quiesce the devices via _try mechanism since
we have to poll for IPIs during the time we wait for the other
CPUs.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/kgdboe.c |   21 +++++++++++++++++++++
 include/linux/kgdb.h |    2 ++
 kernel/kgdb.c        |    6 ++++++
 3 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/net/kgdboe.c b/drivers/net/kgdboe.c
index 939797a..b46cc9a 100644
--- a/drivers/net/kgdboe.c
+++ b/drivers/net/kgdboe.c
@@ -270,8 +270,29 @@ static int param_set_kgdboe_var(const char *kmessage, struct kernel_param *kp)
 	return 0;
 }
 
+static int eth_try_quiesce(void)
+{
+	struct napi_struct *napi;
+
+	list_for_each_entry(napi, &np.dev->napi_list, dev_list) {
+		if (!napi_try_disable(napi))
+			return 0;
+	}
+	return 1;
+}
+
+static void eth_activate(void)
+{
+	struct napi_struct *napi;
+
+	list_for_each_entry(napi, &np.dev->napi_list, dev_list)
+		napi_enable(napi);
+}
+
 static struct kgdb_io local_kgdb_io_ops = {
 	.name = "kgdboe",
+	.try_quiesce = eth_try_quiesce,
+	.activate = eth_activate,
 	.read_char = eth_get_char,
 	.write_char = eth_put_char,
 	.flush = eth_flush_buf,
diff --git a/include/linux/kgdb.h b/include/linux/kgdb.h
index 4c80859..93cd305 100644
--- a/include/linux/kgdb.h
+++ b/include/linux/kgdb.h
@@ -250,6 +250,8 @@ struct kgdb_arch {
  */
 struct kgdb_io {
 	const char		*name;
+	int			(*try_quiesce) (void);
+	void			(*activate) (void);
 	int			(*read_char) (void);
 	void			(*write_char) (u8);
 	void			(*flush) (void);
diff --git a/kernel/kgdb.c b/kernel/kgdb.c
index 97edb05..e7a2274 100644
--- a/kernel/kgdb.c
+++ b/kernel/kgdb.c
@@ -1475,6 +1475,9 @@ return_normal:
 			atomic_inc(&passive_cpu_wait[i]);
 	}
 
+	while (kgdb_io_ops->try_quiesce && !kgdb_io_ops->try_quiesce())
+		kgdb_arch_poll_ipi(regs);
+
 #ifdef CONFIG_SMP
 	/* Signal the other CPUs to enter kgdb_wait() */
 	if ((!kgdb_single_step) && kgdb_do_roundup)
@@ -1489,6 +1492,9 @@ return_normal:
 			kgdb_arch_poll_ipi(regs);
 	}
 
+	if (kgdb_io_ops->activate)
+		kgdb_io_ops->activate();
+
 	/*
 	 * At this point the primary processor is completely
 	 * in the debugger and all secondary CPUs are quiescent
-- 
1.7.0.5
