From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of most of the trees
Date: Thu, 28 May 2015 11:42:03 -0700 (PDT)
Message-ID: <20150528.114203.717794268051352731.davem@davemloft.net>
References: <20150528220607.67a68696@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbbE1SmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 14:42:06 -0400
In-Reply-To: <20150528220607.67a68696@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 28 May 2015 22:06:07 +1000

> Ouch :-(

The only thing I will say on this matter is that the _only_ way this
problem will go away is if someone does the work necessary to get rid
of that implicit vmalloc.h include that happens on all x86 platform
builds.

So if you want this to stop happening, work on that.

I've applied the following to net-next, thanks for your report.

====================
[PATCH] treewide: Add missing vmalloc.h inclusion.

All of these files were only building on non-x86 because of
the indirect of inclusion of vmalloc.h by, of all things,
"net/inet_hashtables.h"

None of this got caught during build testing, because on x86
there is an implicit vmalloc.h include via on of the arch asm/
headers.

This fixes all of these

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 crypto/algif_skcipher.c                | 1 +
 drivers/scsi/qla2xxx/tcm_qla2xxx.c     | 1 +
 drivers/target/iscsi/iscsi_target.c    | 1 +
 drivers/target/target_core_file.c      | 1 +
 drivers/target/target_core_pr.c        | 1 +
 drivers/target/target_core_transport.c | 1 +
 drivers/target/target_core_user.c      | 1 +
 drivers/vhost/scsi.c                   | 1 +
 8 files changed, 8 insertions(+)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 37110fd..4d1c315 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -444,6 +444,7 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
 			err = skcipher_wait_for_data(sk, flags);
 			if (err)
 				goto unlock;
+			used = ctx->used;
 		}
 
 		used = min_t(unsigned long, used, iov_iter_count(&msg->msg_iter));
diff --git a/drivers/scsi/qla2xxx/tcm_qla2xxx.c b/drivers/scsi/qla2xxx/tcm_qla2xxx.c
index 73f9fee..54c986a 100644
--- a/drivers/scsi/qla2xxx/tcm_qla2xxx.c
+++ b/drivers/scsi/qla2xxx/tcm_qla2xxx.c
@@ -27,6 +27,7 @@
 #include <linux/moduleparam.h>
 #include <generated/utsrelease.h>
 #include <linux/utsname.h>
+#include <linux/vmalloc.h>
 #include <linux/init.h>
 #include <linux/list.h>
 #include <linux/slab.h>
diff --git a/drivers/target/iscsi/iscsi_target.c b/drivers/target/iscsi/iscsi_target.c
index aebde32..f2ce95c 100644
--- a/drivers/target/iscsi/iscsi_target.c
+++ b/drivers/target/iscsi/iscsi_target.c
@@ -21,6 +21,7 @@
 #include <linux/crypto.h>
 #include <linux/completion.h>
 #include <linux/module.h>
+#include <linux/vmalloc.h>
 #include <linux/idr.h>
 #include <asm/unaligned.h>
 #include <scsi/scsi_device.h>
diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index d836de2..5f8b119 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -30,6 +30,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/module.h>
+#include <linux/vmalloc.h>
 #include <linux/falloc.h>
 #include <scsi/scsi.h>
 #include <scsi/scsi_host.h>
diff --git a/drivers/target/target_core_pr.c b/drivers/target/target_core_pr.c
index 283cf78..06cd53e 100644
--- a/drivers/target/target_core_pr.c
+++ b/drivers/target/target_core_pr.c
@@ -27,6 +27,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/list.h>
+#include <linux/vmalloc.h>
 #include <linux/file.h>
 #include <scsi/scsi.h>
 #include <scsi/scsi_cmnd.h>
diff --git a/drivers/target/target_core_transport.c b/drivers/target/target_core_transport.c
index 0adc0f6..c99d2ea 100644
--- a/drivers/target/target_core_transport.c
+++ b/drivers/target/target_core_transport.c
@@ -34,6 +34,7 @@
 #include <linux/cdrom.h>
 #include <linux/module.h>
 #include <linux/ratelimit.h>
+#include <linux/vmalloc.h>
 #include <asm/unaligned.h>
 #include <net/sock.h>
 #include <net/tcp.h>
diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 1a1bcf7..ca43a10 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -21,6 +21,7 @@
 #include <linux/idr.h>
 #include <linux/timer.h>
 #include <linux/parser.h>
+#include <linux/vmalloc.h>
 #include <scsi/scsi.h>
 #include <scsi/scsi_host.h>
 #include <linux/uio_driver.h>
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index dc78d87..16b45ca 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -35,6 +35,7 @@
 #include <linux/compat.h>
 #include <linux/eventfd.h>
 #include <linux/fs.h>
+#include <linux/vmalloc.h>
 #include <linux/miscdevice.h>
 #include <asm/unaligned.h>
 #include <scsi/scsi.h>
-- 
2.1.0
