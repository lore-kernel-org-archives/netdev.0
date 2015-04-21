From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net 1/2] rhashtable: Schedule async resize when sync realloc fails
Date: Tue, 21 Apr 2015 14:55:34 +0200
Message-ID: <4f55f5c9abd6b09ed44f0da3f0e72a10040e8278.1429620438.git.tgraf@suug.ch>
References: <cover.1429620438.git.tgraf@suug.ch>
Cc: herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44808 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbbDUMzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 08:55:40 -0400
In-Reply-To: <cover.1429620438.git.tgraf@suug.ch>
In-Reply-To: <cover.1429620438.git.tgraf@suug.ch>
References: <cover.1429620438.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rhashtable_insert_rehash() fails with ENOMEM, this indicates that
we can't allocate the necessary memory in the current context but the
limits as set by the user would still allow to grow.

Thus attempt an async resize in the background where we can allocate
using GFP_KERNEL which is more likely to succeed. The insertion itself
will still fail to indicate pressure.

This fixes a bug where the table would never continue growing once the
utilization is above 100%.

Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index e23d242..7040b5c 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -593,6 +593,8 @@ slow_path:
 		spin_unlock_bh(lock);
 		err = rhashtable_insert_rehash(ht);
 		rcu_read_unlock();
+		if (err == -ENOMEM)
+			schedule_work(&ht->run_work);
 		if (err)
 			return err;
 
-- 
2.3.5
