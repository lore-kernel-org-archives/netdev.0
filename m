From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] rhashtable: don't allocate ht structure on stack in test_rht_init
Date: Fri, 20 Feb 2015 21:14:21 +0100
Message-ID: <8e1d6d2ffb44eac6518f435a044dbc6c0fd754ae.1424463131.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45627 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755236AbbBTUO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:14:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With object runtime debugging enabled, the rhashtable test suite
will rightfully throw a warning "ODEBUG: object is on stack, but
not annotated" from rhashtable_init().

This is because run_work is (correctly) being initialized via
INIT_WORK(), and not annotated by INIT_WORK_ONSTACK(). Meaning,
rhashtable_init() is okay as is, we just need to move ht e.g.,
into global scope.

It never triggered anything, since test_rhashtable is rather a
controlled environment and effectively runs to completion, so
that stack memory is not vanishing underneath us, we shouldn't
confuse any testers with it though.

Fixes: 7e1e77636e36 ("lib: Resizable, Scalable, Concurrent Hash Table")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/test_rhashtable.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 9c5fcce..58b9953 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -191,9 +191,10 @@ error:
 	return err;
 }
 
+static struct rhashtable ht;
+
 static int __init test_rht_init(void)
 {
-	struct rhashtable ht;
 	struct rhashtable_params params = {
 		.nelem_hint = TEST_HT_SIZE,
 		.head_offset = offsetof(struct test_obj, node),
-- 
1.9.3
