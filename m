From: Florian Zumbiehl <florz@florz.de>
Subject: [RESEND][PATCH 2/3] PPPoX/E: return ENOTTY on unknown ioctl requests
Date: Sun, 29 Jul 2007 08:04:36 +0200
Message-ID: <20070729060435.GB27573@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: mostrows@earthlink.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.166.84] ([77.10.166.84]:33225 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1759415AbXG2GgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 02:36:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

here another patch for the PPPoX/E code that makes sure that ENOTTY is
returned for unknown ioctl requests rather than 0 (and removes another
unneeded initializer which I didn't bother creating a separate patch for).

Florian

---------------------------------------------------------------------------
Signed-off-by: Florian Zumbiehl <florz@florz.de>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 954328c..9554924 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -669,8 +669,8 @@ static int pppoe_ioctl(struct socket *sock, unsigned int cmd,
 {
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po = pppox_sk(sk);
-	int val = 0;
-	int err = 0;
+	int val;
+	int err;
 
 	switch (cmd) {
 	case PPPIOCGMRU:
@@ -759,8 +759,9 @@ static int pppoe_ioctl(struct socket *sock, unsigned int cmd,
 		err = 0;
 		break;
 
-	default:;
-	};
+	default:
+		err = -ENOTTY;
+	}
 
 	return err;
 }
diff --git a/drivers/net/pppox.c b/drivers/net/pppox.c
index 3f8115d..51de561 100644
--- a/drivers/net/pppox.c
+++ b/drivers/net/pppox.c
@@ -72,7 +72,7 @@ int pppox_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po = pppox_sk(sk);
-	int rc = 0;
+	int rc;
 
 	lock_sock(sk);
 
@@ -93,12 +93,9 @@ int pppox_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		break;
 	}
 	default:
-		if (pppox_protos[sk->sk_protocol]->ioctl)
-			rc = pppox_protos[sk->sk_protocol]->ioctl(sock, cmd,
-								  arg);
-
-		break;
-	};
+		rc = pppox_protos[sk->sk_protocol]->ioctl ?
+			pppox_protos[sk->sk_protocol]->ioctl(sock, cmd, arg) : -ENOTTY;
+	}
 
 	release_sock(sk);
 	return rc;
