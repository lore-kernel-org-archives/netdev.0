From: David Woodhouse <dwmw2@infradead.org>
Subject: Bluetooth BUG() in set_sk_owner().
Date: Wed, 10 Sep 2003 09:58:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063184337.32473.529.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, makx@qualcomm.com,
   marcel@holtmann.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It loks like the recent addition of sk_set_owner() to 
bt_sock_alloc() was bogus... some of the callers of bt_sock_alloc()
already do that for  This patch reverts it, and makes the remaining
callers also set the owner for themselves...

===== net/bluetooth/af_bluetooth.c 1.22 vs edited =====
--- 1.22/net/bluetooth/af_bluetooth.c	Sun Aug 31 03:30:42 2003
+++ edited/net/bluetooth/af_bluetooth.c	Tue Sep  9 11:28:51 2003
@@ -130,7 +130,6 @@
 	}
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 	
 	sk->sk_zapped   = 0;
===== net/bluetooth/hci_sock.c 1.24 vs edited =====
--- 1.24/net/bluetooth/hci_sock.c	Sat Jul  5 07:52:58 2003
+++ edited/net/bluetooth/hci_sock.c	Tue Sep  9 11:30:43 2003
@@ -587,6 +587,8 @@
 	if (!sk)
 		return -ENOMEM;
 
+	sk_set_owner(sk, THIS_MODULE);
+
 	sock->state = SS_UNCONNECTED;
 	sk->sk_state   = BT_OPEN;
 
===== net/bluetooth/bnep/sock.c 1.11 vs edited =====
--- 1.11/net/bluetooth/bnep/sock.c	Thu Jun  5 01:57:08 2003
+++ edited/net/bluetooth/bnep/sock.c	Tue Sep  9 11:29:54 2003
@@ -175,6 +175,9 @@
 
 	if (!(sk = bt_sock_alloc(sock, PF_BLUETOOTH, 0, GFP_KERNEL)))
 		return -ENOMEM;
+
+	sk_set_owner(sk, THIS_MODULE);
+
 	sock->ops = &bnep_sock_ops;
 
 	sock->state  = SS_UNCONNECTED;


-- 
dwmw2
