From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH] irda: prevent integer underflow in IRLMP_ENUMDEVICES
Date: Wed, 22 Dec 2010 18:58:27 -0500
Message-ID: <1293062307.9820.331.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: samuel@sortiz.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:51215 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab0LVX6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 18:58:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user-provided len is less than the expected offset, the
IRLMP_ENUMDEVICES getsockopt will do a copy_to_user() with a very large
size value.  While this isn't be a security issue on x86 because it will
get caught by the access_ok() check, it may leak large amounts of kernel
heap on other architectures.  In any event, this patch fixes it.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: stable <stable@kernel.org>
---
 net/irda/af_irda.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index a6de305..241d7a0 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2280,6 +2280,16 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 
 	switch (optname) {
 	case IRLMP_ENUMDEVICES:
+
+		/* Offset to first device entry */
+		offset = sizeof(struct irda_device_list) -
+			sizeof(struct irda_device_info);
+
+		if (len < offset) {
+			err = -EINVAL;
+			goto out;
+		}
+
 		/* Ask lmp for the current discovery log */
 		discoveries = irlmp_get_discoveries(&list.len, self->mask.word,
 						    self->nslots);
@@ -2290,15 +2300,9 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 		}
 
 		/* Write total list length back to client */
-		if (copy_to_user(optval, &list,
-				 sizeof(struct irda_device_list) -
-				 sizeof(struct irda_device_info)))
+		if (copy_to_user(optval, &list, offset))
 			err = -EFAULT;
 
-		/* Offset to first device entry */
-		offset = sizeof(struct irda_device_list) -
-			sizeof(struct irda_device_info);
-
 		/* Copy the list itself - watch for overflow */
 		if (list.len > 2048) {
 			err = -EINVAL;


