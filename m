From: Daniel Mack <daniel@caiaq.de>
Subject: [PATCH] wireless: wext: allocate space for NULL-termination for 32byte SSIDs
Date: Sun, 13 Dec 2009 04:47:30 +0800
Message-ID: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
Cc: Daniel Mack <daniel@caiaq.de>, Dan Williams <dcbw@redhat.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:60770 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbZLOJSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 04:18:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've experienced a long standing bug when quickly switching from
ad-hoc to managed mode on a hardware using a Libertas chipset.

The effect is that after a number of mode transistions (sometimes as few
as two sufficed), the kernel will oops at very strange locations, mostly
in something like __kmem_alloc().

While the root cause turned out to be an issue with the wpa-supplicant
which feeds the kernel driver with garbage, this occasion pointed out a
bug in the wireless wext core when SSIDs with 32 byte lengths are passed
from userspace. In this case, the string is not properly NULL-terminated
which causes some other part to corrupt memory.

(In the particular case I observed, an SIOCSIWESSID was issued with
 bogus data in iwp->pointer but iwp->length=32).

I admitedly couldn't find where the actual corruption itself happens,
but with this trivial fix, I can't reproduce the bug anymore.

Signed-off-by: Daniel Mack <daniel@caiaq.de>
Cc: Dan Williams <dcbw@redhat.com>
Cc: Michael Hirsch <m.hirsch@raumfeld.com>
Cc: netdev@vger.kernel.org
Cc: libertas-dev@lists.infradead.org
Cc: stable@kernel.org
---
 net/wireless/wext.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)
---
 net/wireless/wext-core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 5e1656b..3d8f4b0 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -759,8 +759,8 @@ static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
 		}
 	}
 
-	/* kzalloc() ensures NULL-termination for essid_compat. */
-	extra = kzalloc(extra_size, GFP_KERNEL);
+	/* kzalloc() +1 ensures NULL-termination for essid_compat. */
+	extra = kzalloc(extra_size + 1, GFP_KERNEL);
 	if (!extra)
 		return -ENOMEM;
 
-- 
1.6.3.3

