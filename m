From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v6 5/6] lib: Ensure EWMA does not store wrong intermediate values
Date: Thu, 16 Jan 2014 22:23:29 -0800
Message-ID: <1389939810-14998-6-git-send-email-mwdalton@google.com>
References: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:45711 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaAQGXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:23:42 -0500
Received: by mail-pd0-f201.google.com with SMTP id q10so193327pdj.0
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 22:23:42 -0800 (PST)
In-Reply-To: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To ensure ewma_read() without a lock returns a valid but possibly
out of date average, modify ewma_add() by using ACCESS_ONCE to prevent
intermediate wrong values from being written to avg->internal.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 lib/average.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/average.c b/lib/average.c
index 99a67e6..114d1be 100644
--- a/lib/average.c
+++ b/lib/average.c
@@ -53,8 +53,10 @@ EXPORT_SYMBOL(ewma_init);
  */
 struct ewma *ewma_add(struct ewma *avg, unsigned long val)
 {
-	avg->internal = avg->internal  ?
-		(((avg->internal << avg->weight) - avg->internal) +
+	unsigned long internal = ACCESS_ONCE(avg->internal);
+
+	ACCESS_ONCE(avg->internal) = internal ?
+		(((internal << avg->weight) - internal) +
 			(val << avg->factor)) >> avg->weight :
 		(val << avg->factor);
 	return avg;
-- 
1.8.5.2
