From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] linux-2.4: br2684: allocation out of atomic context
Date: Mon, 29 Jun 2009 16:49:05 +0100
Message-ID: <20090629154905.GD18570@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Seidel <Frank.Seidel@sphairon.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:38734 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059AbZF2PtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 11:49:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arne Redlich <redlicha@sphairon.com>

Moved GFP_Kernel allocation out of atomic context

Signed-off-by: Arne Redlich <redlicha@sphairon.com>
Signed-off-by: Frank Seidel <Frank.Seidel@sphairon.com>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
 net/atm/br2684.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -509,6 +509,10 @@ Note: we do not have explicit unassign,
 		MOD_DEC_USE_COUNT;
 		return -EFAULT;
 	}
+	brvcc = kmalloc(sizeof(struct br2684_vcc), GFP_KERNEL);
+	if (!brvcc)
+		return -ENOMEM;
+	memset(brvcc, 0, sizeof(struct br2684_vcc));
 	write_lock_irq(&devs_lock);
 	brdev = br2684_find_dev(&be.ifspec);
 	if (brdev == NULL) {
@@ -532,11 +536,6 @@ Note: we do not have explicit unassign,
 		err = -EINVAL;
 		goto error;
 	}
-	brvcc = kmalloc(sizeof(struct br2684_vcc), GFP_KERNEL);
-	if (!brvcc) {
-		err = -ENOMEM;
-		goto error;
-	}
 	memset(brvcc, 0, sizeof(struct br2684_vcc));
 	DPRINTK("br2684_regvcc vcc=%p, encaps=%d, brvcc=%p\n", atmvcc, be.encaps,
 		brvcc);
@@ -567,6 +566,7 @@ Note: we do not have explicit unassign,
 	return 0;
     error:
 	write_unlock_irq(&devs_lock);
+	kfree(brvcc);
 	MOD_DEC_USE_COUNT;
 	return err;
 }
