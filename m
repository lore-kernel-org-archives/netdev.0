From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 1/2] sock_diag: Fix out-of-bounds access to sock_diag_handlers[]
Date: Sat, 23 Feb 2013 12:13:47 +0100
Message-ID: <1361618028-9024-2-git-send-email-minipli@googlemail.com>
References: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:46309 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757044Ab3BWLOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 06:14:12 -0500
Received: by mail-bk0-f53.google.com with SMTP id j10so635828bkw.40
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2013 03:14:11 -0800 (PST)
In-Reply-To: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userland can send a netlink message requesting SOCK_DIAG_BY_FAMILY
with a family greater or equal then AF_MAX -- the array size of
sock_diag_handlers[]. The current code does not test for this
condition therefore is vulnerable to an out-of-bound access opening
doors for a privilege escalation.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/core/sock_diag.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 602cd63..750f44f 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -121,6 +121,9 @@ static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (nlmsg_len(nlh) < sizeof(*req))
 		return -EINVAL;
 
+	if (req->sdiag_family >= AF_MAX)
+		return -EINVAL;
+
 	hndl = sock_diag_lock_handler(req->sdiag_family);
 	if (hndl == NULL)
 		err = -ENOENT;
-- 
1.7.10.4
