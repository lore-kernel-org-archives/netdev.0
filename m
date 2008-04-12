From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] tg3: fix MMIO for PPC 44x platforms
Date: Sat, 12 Apr 2008 21:01:22 +0400
Message-ID: <200804122101.22438.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:9174 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754077AbYDLRCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 13:02:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver stores the PCI resource addresses into 'unsigned long' variable
before calling ioremap_nocache() on them. This warrants kernel oops when the
registers are accessed on PPC 44x platforms which (being 32-bit) have PCI
memory space mapped beyond 4 GB.

The arch/ppc/ kernel has a fixup in ioremap() that creates an illusion that
the PCI memory resource is mapped below 4 GB, but arch/powerpc/ code got rid
of this trick, having instead CONFIG_RESOURCES_64BIT enabled.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
Reposting the patch with the log and summary corrected.
This is the same issue as the one that has been recently addressed by commits
3c34ac36ac1084e571ef9b6fb1d6a5b10ccc1fd0 (e1000: Fix for 32 bits platforms with
64 bits resources) and c976816b6e901341ec3c4653147316c15549a1c4 (siimage: fix
kernel oops on PPC 44x).  The patch has only been compile tested though...

 drivers/net/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -12578,7 +12578,8 @@ static int __devinit tg3_init_one(struct
 				  const struct pci_device_id *ent)
 {
 	static int tg3_version_printed = 0;
-	unsigned long tg3reg_base, tg3reg_len;
+	resource_size_t tg3reg_base;
+	unsigned long tg3reg_len;
 	struct net_device *dev;
 	struct tg3 *tp;
 	int err, pm_cap;

