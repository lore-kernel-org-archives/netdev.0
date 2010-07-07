From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH RFC 3/4] net: Implement napi_try_disable()
Date: Wed, 7 Jul 2010 21:13:29 +0400
Message-ID: <20100707171329.GC20015@oksana.dev.rtsoft.ru>
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
	with ESMTP id S1754669Ab0GGRNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 13:13:34 -0400
Received: by eya25 with SMTP id 25so236905eya.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 10:13:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For KGDBoE we'll need to disable NAPI, so that we don't randomly
interrupt secondary CPUs while they process networking stuff.

We need to wait for NAPI to become disabled from an atomic context,
thus we can't use napi_disable() as it calls msleep().

Plus, in KGDB we have to always poll for IPIs during busy-waiting,
which means that we must implement the function in a such way that
we can do some caller specific work during the time we wait for
NAPI disable, so just changing msleep() to mdelay() won't work.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 include/linux/netdevice.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 08a1dd8..4fc24eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -414,6 +414,27 @@ extern void __napi_complete(struct napi_struct *n);
 extern void napi_complete(struct napi_struct *n);
 
 /**
+ *	napi_try_disable - try to prevent NAPI from scheduling
+ *	@n: napi context
+ *
+ * This call is similar to napi_disable(), except that it doesn't
+ * wait till any outstanding processing completes, but returns
+ * whether napi was successfuly disabled.
+ *
+ * Note that you still must wait till napi is actually disabled,
+ * so the only benefit from using this call is that you can do
+ * some useful work while you wait.
+ */
+static inline int napi_try_disable(struct napi_struct *n)
+{
+	set_bit(NAPI_STATE_DISABLE, &n->state);
+	if (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
+		return 0;
+	clear_bit(NAPI_STATE_DISABLE, &n->state);
+	return 1;
+}
+
+/**
  *	napi_disable - prevent NAPI from scheduling
  *	@n: napi context
  *
-- 
1.7.0.5

