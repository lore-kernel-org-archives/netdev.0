From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v5 5/6] lib: Ensure EWMA does not store wrong intermediate values
Date: Thu, 16 Jan 2014 18:36:15 -0800
Message-ID: <1389926176-6699-6-git-send-email-mwdalton@google.com>
References: <1389926176-6699-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:36965 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbaAQCge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 21:36:34 -0500
Received: by mail-ob0-f202.google.com with SMTP id vb8so731416obc.5
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 18:36:33 -0800 (PST)
In-Reply-To: <1389926176-6699-1-git-send-email-mwdalton@google.com>
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
