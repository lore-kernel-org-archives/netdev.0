From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: redo stateless addrconf properly
Date: Tue, 25 Nov 2003 22:40:37 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125.224037.85040739.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Interface that had configured via stateless addrconf did not do 
stateless addrconf again correctly after interface was down.
Forget IF_RS_SENT|IF_RA_RCVD flags when interface goes down.

Patch is against 2.6.0-test10, but similar logic applies to
2.4.x and 2.2.x.

Thanks.

===== net/ipv6/addrconf.c 1.76 vs edited =====
--- 1.76/net/ipv6/addrconf.c	Sun Nov  9 15:32:54 2003
+++ edited/net/ipv6/addrconf.c	Tue Nov 25 22:23:03 2003
@@ -1924,9 +1924,13 @@
 		write_unlock_bh(&addrconf_hash_lock);
 	}
 
-	/* Step 3: clear address list */
-
 	write_lock_bh(&idev->lock);
+
+	/* Step 3: clear flags for stateless addrconf */
+	if (how != 1)
+		idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+
+	/* Step 4: clear address list */
 #ifdef CONFIG_IPV6_PRIVACY
 	if (how == 1 && del_timer(&idev->regen_timer))
 		in6_dev_put(idev);
@@ -1962,7 +1966,7 @@
 	}
 	write_unlock_bh(&idev->lock);
 
-	/* Step 4: Discard multicast list */
+	/* Step 5: Discard multicast list */
 
 	if (how == 1)
 		ipv6_mc_destroy_dev(idev);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
