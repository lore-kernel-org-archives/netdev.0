From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] isdnloop: NUL-terminate strings from userspace
Date: Tue,  1 Apr 2014 12:08:18 +0200
Message-ID: <1396346898-8950-1-git-send-email-vegard.nossum@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both the in-kernel and BSD strlcpy() require that the source string is
NUL terminated. We could use strncpy() + explicitly terminate the result,
but this relies on src and dest having the same size, so the safest thing
to do seems to explicitly terminate the source string before doing the
strlcpy().

Fixes: f9a23c84486ed35 ("isdnloop: use strlcpy() instead of strcpy()")
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: stable@vger.kernel.org
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 drivers/isdn/isdnloop/isdnloop.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index 02125e6..50cd348 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -1070,6 +1070,14 @@ isdnloop_start(isdnloop_card *card, isdnloop_sdef *sdefp)
 		return -EBUSY;
 	if (copy_from_user((char *) &sdef, (char *) sdefp, sizeof(sdef)))
 		return -EFAULT;
+
+	/*
+	 * Null terminate strings from userspace so we don't have to worry
+	 * about this later on.
+	 */
+	for (i = 0; i < 3; i++)
+		sdef.num[i][sizeof(sdef.num[0]) - 1] = '\0';
+
 	spin_lock_irqsave(&card->isdnloop_lock, flags);
 	switch (sdef.ptype) {
 	case ISDN_PTYPE_EURO:
-- 
1.7.10.4
