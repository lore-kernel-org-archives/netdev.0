From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 13/17] br2684: allow assign only on a connected socket
Date: Fri, 30 Nov 2012 00:35:32 +0000
Message-ID: <1354235736-26833-14-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37541 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Mazur <krzysiek@podlesie.net>

The br2684 does not check if used vcc is in connected state,
causing potential Oops in pppoatm_send() when vcc->send() is called
on not fully connected socket.

Now br2684 can be assigned only on connected sockets; otherwise
-EINVAL error is returned.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 net/atm/br2684.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 373d784..a4ee4ad 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -704,10 +704,13 @@ static int br2684_ioctl(struct socket *sock, unsigned int cmd,
 			return -ENOIOCTLCMD;
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (cmd == ATM_SETBACKEND)
+		if (cmd == ATM_SETBACKEND) {
+			if (sock->state != SS_CONNECTED)
+				return -EINVAL;
 			return br2684_regvcc(atmvcc, argp);
-		else
+		} else {
 			return br2684_create(argp);
+		}
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	case BR2684_SETFILT:
 		if (atmvcc->push != br2684_push)
-- 
1.8.0
