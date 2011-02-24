From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/17] tipc: Prevent invalid memory access when sending to configuration service
Date: Wed, 23 Feb 2011 20:26:32 -0500
Message-ID: <1298510805-20630-5-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34488 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755571Ab1BXB1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:06 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Reject TIPC configuration service messages without a full message
header.  Previously, an application that sent a message to the
configuration service that was too short could cause the validation
code to access an uninitialized field in the msghdr structure,
resulting in a memory access exception.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 893ca6e..125dcb0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -493,6 +493,8 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 	if (likely(dest->addr.name.name.type != TIPC_CFG_SRV))
 		return -EACCES;
 
+	if (!m->msg_iovlen || (m->msg_iov[0].iov_len < sizeof(hdr)))
+		return -EMSGSIZE;
 	if (copy_from_user(&hdr, m->msg_iov[0].iov_base, sizeof(hdr)))
 		return -EFAULT;
 	if ((ntohs(hdr.tcm_type) & 0xC000) && (!capable(CAP_NET_ADMIN)))
-- 
1.7.3.3

