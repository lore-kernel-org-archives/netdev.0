From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NET] NEIGHBOUR: hold refcnt of net_device from proxy
 neighbor entries.
Date: Thu, 30 Sep 2004 17:07:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930.170729.51800585.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

[NET] NEIGHBOUR: hold refcnt of net_device from proxy neighbor entries.
 
We did not hold refcnt of net_device from proxy neighbor entries
while we did from neighbor entries.
 
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Thanks.

diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-30 16:32:24 +09:00
+++ b/net/core/neighbour.c	2004-09-30 16:32:24 +09:00
@@ -496,8 +496,12 @@
 
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
+	if (dev)
+		dev_hold(dev);
 
 	if (tbl->pconstructor && tbl->pconstructor(n)) {
+		if (dev)
+			dev_put(dev);
 		kfree(n);
 		n = NULL;
 		goto out;
@@ -532,6 +536,8 @@
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
 				tbl->pdestructor(n);
+			if (n->dev)
+				dev_put(n->dev);
 			kfree(n);
 			return 0;
 		}
@@ -552,6 +558,8 @@
 				*np = n->next;
 				if (tbl->pdestructor)
 					tbl->pdestructor(n);
+				if (n->dev)
+					dev_put(n->dev);
 				kfree(n);
 				continue;
 			}



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
