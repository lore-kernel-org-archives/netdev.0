From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [Q] LL_RESERVED_SPACE(dev) vs HH_DATA_ALIGN(dev->hard_header_len)
Date: Sun, 08 Feb 2004 20:39:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208.203930.36073978.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

There're many places like:
  (dev->hard_header_len + 15) & ~15
or
  dev->hard_header_len + 15.

I guess the second one trying to express maximum number of the 
first one and it seems that
  HH_DATA_ALIGN(dev->hard_header_len)
  LL_SPACE_RESERVED(dev)
(defined in include/linux/netdevice.h) will do for us respectively.

Question: 
  How do you think about the following patch?
  Or, is it okay to simply use LL_RESERVED_SPACE(dev) in both places?

Thanks in advance.

===== net/econet/af_econet.c 1.30 vs edited =====
--- 1.30/net/econet/af_econet.c	Mon Jan 26 04:05:06 2004
+++ edited/net/econet/af_econet.c	Sun Feb  8 17:18:51 2004
@@ -318,12 +318,12 @@
 #ifdef CONFIG_ECONET_NATIVE
 		dev_hold(dev);
 		
-		skb = sock_alloc_send_skb(sk, len+dev->hard_header_len+15, 
+		skb = sock_alloc_send_skb(sk, len + LL_RESERVED_SPACE(dev),
 					  msg->msg_flags & MSG_DONTWAIT, &err);
 		if (skb==NULL)
 			goto out_unlock;
 		
-		skb_reserve(skb, (dev->hard_header_len+15)&~15);
+		skb_reserve(skb, HH_DATA_ALIGN(dev->hard_header_len));
 		skb->nh.raw = skb->data;
 		
 		eb = (struct ec_cb *)&skb->cb;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
