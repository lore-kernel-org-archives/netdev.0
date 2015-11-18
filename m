From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 12/14] net: move napi_hash[] into read mostly section
Date: Wed, 18 Nov 2015 06:31:01 -0800
Message-ID: <1447857063-618-13-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33686 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932984AbbKRObu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:50 -0500
Received: by pabfh17 with SMTP id fh17so48251899pab.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:50 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not often add/delete a napi context.
Moving napi_hash[] into read mostly section avoids potential false sharing.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/hashtable.h | 4 ++++
 net/core/dev.c            | 2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
index 519b6e2d769e..661e5c2a8e2a 100644
--- a/include/linux/hashtable.h
+++ b/include/linux/hashtable.h
@@ -16,6 +16,10 @@
 	struct hlist_head name[1 << (bits)] =					\
 			{ [0 ... ((1 << (bits)) - 1)] = HLIST_HEAD_INIT }
 
+#define DEFINE_READ_MOSTLY_HASHTABLE(name, bits)				\
+	struct hlist_head name[1 << (bits)] __read_mostly =			\
+			{ [0 ... ((1 << (bits)) - 1)] = HLIST_HEAD_INIT }
+
 #define DECLARE_HASHTABLE(name, bits)                                   	\
 	struct hlist_head name[1 << (bits)]
 
diff --git a/net/core/dev.c b/net/core/dev.c
index ff58a8bc5e3c..02dfbd91a8e4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -184,7 +184,7 @@ EXPORT_SYMBOL(dev_base_lock);
 static DEFINE_SPINLOCK(napi_hash_lock);
 
 static unsigned int napi_gen_id = NR_CPUS;
-static DEFINE_HASHTABLE(napi_hash, 8);
+static DEFINE_READ_MOSTLY_HASHTABLE(napi_hash, 8);
 
 static seqcount_t devnet_rename_seq;
 
-- 
2.6.0.rc2.230.g3dd15c0
