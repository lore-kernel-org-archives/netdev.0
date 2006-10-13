From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 3/14] [TIPC] Stream socket can now send > 66000 bytes at a time
Date: Fri, 13 Oct 2006 13:37:44 +0200
Message-ID: <11607394753960-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:47008 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751391AbWJMLiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

The stream socket send code was not initializing some required fields
of the temporary msghdr structure it was utilizing; this is now fixed.
A check has also been added to detect if a user illegally specifies
a destination address when sending on an established stream connection.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index acfb852..ed900fe 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2,7 +2,7 @@
  * net/tipc/socket.c: TIPC socket API
  * 
  * Copyright (c) 2001-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -629,6 +629,9 @@ static int send_stream(struct kiocb *ioc
                         return -ENOTCONN;
         }
 
+	if (unlikely(m->msg_name))
+		return -EISCONN;
+
 	/* 
 	 * Send each iovec entry using one or more messages
 	 *
@@ -641,6 +644,8 @@ static int send_stream(struct kiocb *ioc
 	curr_iovlen = m->msg_iovlen;
 	my_msg.msg_iov = &my_iov;
 	my_msg.msg_iovlen = 1;
+	my_msg.msg_flags = m->msg_flags;
+	my_msg.msg_name = NULL;
 	bytes_sent = 0;
 
 	while (curr_iovlen--) {
-- 
1.4.1

