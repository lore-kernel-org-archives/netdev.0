From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 1/1] l2tp: fix oops in l2tp_eth_create() error path
Date: Tue, 30 Oct 2012 09:41:48 +0000
Message-ID: <1351590108-21067-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:50148 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757484Ab2J3Jlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 05:41:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating an L2TPv3 Ethernet session, if register_netdev() should fail for
any reason (for example, automatic naming for "l2tpeth%d" interfaces hits the
32k-interface limit), the netdev is freed in the error path.  However, the
l2tp_eth_sess structure's dev pointer is left uncleared, and this results in
l2tp_eth_delete() then attempting to unregister the same netdev later in the
session teardown.  This results in an oops.

To avoid this, clear the session dev pointer in the error path.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
---
 net/l2tp/l2tp_eth.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 37b8b8b..76125c5 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -291,6 +291,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 
 out_del_dev:
 	free_netdev(dev);
+	spriv->dev = NULL;
 out_del_session:
 	l2tp_session_delete(session);
 out:
-- 
1.7.9.5
