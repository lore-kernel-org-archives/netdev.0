From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: fix a possible memory leak
Date: Fri, 25 Apr 2014 10:44:15 +0800
Message-ID: <1398393855-24772-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <jon.maloy@ericsson.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53352 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbaDYCok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 22:44:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit a8b9b96e959f3c035af20b1bd2ba67b0b7269b19 ("tipc: fix race
in disc create/delete") leads to the following static checker warning:

	net/tipc/discover.c:352 tipc_disc_create()
		warn: possible memory leak of 'req'

The risk of memory leak really exists in practice. Especially when
it's failed to allocate memory for "req->buf", tipc_disc_create()
doesn't free its allocated memory, instead just directly returns
with ENOMEM error code. In this situation, memory leak, of course,
happens.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/discover.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index ada42e4..bd35c4a 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -348,8 +348,10 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
 		return -ENOMEM;
 
 	req->buf = tipc_buf_acquire(INT_H_SIZE);
-	if (!req->buf)
+	if (!req->buf) {
+		kfree(req);
 		return -ENOMEM;
+	}
 
 	tipc_disc_init_msg(req->buf, DSC_REQ_MSG, b_ptr);
 	memcpy(&req->dest, dest, sizeof(*dest));
-- 
1.7.9.5
