From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: fix module unload for good
Date: Fri, 18 May 2012 11:52:26 +0200
Message-ID: <1337334746.3403.114.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:32901 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762250Ab2ERJwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 05:52:31 -0400
Received: by eaak11 with SMTP id k11so746470eaa.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 02:52:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit c57b5468406 (pktgen: fix crash at module unload) did a very poor
job with list primitives.

1) list_splice() arguments were in the wrong order 

2) list_splice(list, head) has undefined behavior if head is not
initialized.

3) We should use the list_splice_init() variant to clear pktgen_threads
list.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Sorry for the mess, I really dont understand how my machine did not
crash with c57b5468406 commit...

 net/core/pktgen.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 77a5998..b81369b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3755,13 +3755,13 @@ static void __exit pg_cleanup(void)
 {
 	struct pktgen_thread *t;
 	struct list_head *q, *n;
-	struct list_head list;
+	LIST_HEAD(list);
 
 	/* Stop all interfaces & threads */
 	pktgen_exiting = true;
 
 	mutex_lock(&pktgen_thread_lock);
-	list_splice(&list, &pktgen_threads);
+	list_splice_init(&pktgen_threads, &list);
 	mutex_unlock(&pktgen_thread_lock);
 
 	list_for_each_safe(q, n, &list) {
