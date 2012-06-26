From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 1/1] use USER_DS in vhost_worker thread
Date: Tue, 26 Jun 2012 12:59:58 +0200
Message-ID: <1340708398-17965-2-git-send-email-borntraeger@de.ibm.com>
References: <1340708398-17965-1-git-send-email-borntraeger@de.ibm.com>
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	Jens Freimann <jfrei@linux.vnet.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:50019 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab2FZLAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 07:00:08 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
	Tue, 26 Jun 2012 12:00:06 +0100
In-Reply-To: <1340708398-17965-1-git-send-email-borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Freimann <jfrei@linux.vnet.ibm.com>

On some architectures address spaces are set up in a way that this is
not necessary to work properly but on some others (like s390) it is.
Make sure we operate on the user address space to allow copy_xxx_user()
from the vhost_worker() thread by setting it explicitly before calling
use_mm() and revert it after unuse_mm().

Signed-off-by: Jens Freimann <jfrei@linux.vnet.ibm.com>
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 drivers/vhost/vhost.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 94dbd25..112156f 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -191,7 +191,9 @@ static int vhost_worker(void *data)
 	struct vhost_dev *dev = data;
 	struct vhost_work *work = NULL;
 	unsigned uninitialized_var(seq);
+	mm_segment_t oldfs = get_fs();
 
+	set_fs(USER_DS);
 	use_mm(dev->mm);
 
 	for (;;) {
@@ -229,6 +231,7 @@ static int vhost_worker(void *data)
 
 	}
 	unuse_mm(dev->mm);
+	set_fs(oldfs);
 	return 0;
 }
 
-- 
1.7.0.4
