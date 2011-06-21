From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/3] udp/recvmsg: Clear MSG_TRUNC flag when starting over for a new packet
Date: Tue, 21 Jun 2011 16:43:40 -0400
Message-ID: <1308689020-1873-4-git-send-email-paul.gortmaker@windriver.com>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Xufeng Zhang <xufeng.zhang@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58267 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757527Ab1FUUoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:44:12 -0400
In-Reply-To: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xufeng Zhang <xufeng.zhang@windriver.com>

Consider this scenario: When the size of the first received udp packet
is bigger than the receive buffer, MSG_TRUNC bit is set in msg->msg_flags.
However, if checksum error happens and this is a blocking socket, it will
goto try_again loop to receive the next packet.  But if the size of the
next udp packet is smaller than receive buffer, MSG_TRUNC flag should not
be set, but because MSG_TRUNC bit is not cleared in msg->msg_flags before
receive the next packet, MSG_TRUNC is still set, which is wrong.

Fix this problem by clearing MSG_TRUNC flag when starting over for a
new packet.

Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/ipv4/udp.c |    3 +++
 net/ipv6/udp.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6f53a5a..15d550c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1249,6 +1249,9 @@ csum_copy_err:
 
 	if (noblock)
 		return -EAGAIN;
+
+	/* starting over for a new packet */
+	msg->msg_flags &= ~MSG_TRUNC;
 	goto try_again;
 }
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e7a43f..328985c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -455,6 +455,9 @@ csum_copy_err:
 
 	if (noblock)
 		return -EAGAIN;
+
+	/* starting over for a new packet */
+	msg->msg_flags &= ~MSG_TRUNC;
 	goto try_again;
 }
 
-- 
1.7.4.4

