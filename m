From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/4] flowcache: make flow_key_size() return "unsigned int"
Date: Mon, 20 Mar 2017 01:20:19 +0300
Message-ID: <20170319222019.GA17015@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33763 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdCSWVF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 18:21:05 -0400
Received: by mail-lf0-f68.google.com with SMTP id r36so8845069lfi.0
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 15:20:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flow keys aren't 4GB+ numbers so 64-bit arithmetic is excessive.

Space savings (I'm not sure what is CSWTCH):

	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-48 (-48)
	function                                     old     new   delta
	flow_cache_lookup                           1163    1159      -4
	CSWTCH                                     75553   75509     -44
	Total: Before=170822932, After=170822884, chg -0.00%

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/flow.h |    2 +-
 net/core/flow.c    |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -202,7 +202,7 @@ static inline struct flowi *flowidn_to_flowi(struct flowidn *fldn)
 
 typedef unsigned long flow_compare_t;
 
-static inline size_t flow_key_size(u16 family)
+static inline unsigned int flow_key_size(u16 family)
 {
 	switch (family) {
 	case AF_INET:
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -161,7 +161,7 @@ static void flow_new_hash_rnd(struct flow_cache *fc,
 static u32 flow_hash_code(struct flow_cache *fc,
 			  struct flow_cache_percpu *fcp,
 			  const struct flowi *key,
-			  size_t keysize)
+			  unsigned int keysize)
 {
 	const u32 *k = (const u32 *) key;
 	const u32 length = keysize * sizeof(flow_compare_t) / sizeof(u32);
@@ -174,7 +174,7 @@ static u32 flow_hash_code(struct flow_cache *fc,
  * important assumptions that we can here, such as alignment.
  */
 static int flow_key_compare(const struct flowi *key1, const struct flowi *key2,
-			    size_t keysize)
+			    unsigned int keysize)
 {
 	const flow_compare_t *k1, *k1_lim, *k2;
 
@@ -199,7 +199,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 	struct flow_cache_percpu *fcp;
 	struct flow_cache_entry *fle, *tfle;
 	struct flow_cache_object *flo;
-	size_t keysize;
+	unsigned int keysize;
 	unsigned int hash;
 
 	local_bh_disable();
