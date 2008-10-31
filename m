From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] key: fix setkey(8) policy set breakage
Date: Sat, 1 Nov 2008 01:13:13 +0300
Message-ID: <20081031221312.GA10575@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:6923 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbYJaWKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 18:10:06 -0400
Received: by ug-out-1314.google.com with SMTP id 39so1383524ugf.37
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 15:10:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steps to reproduce:

	#/usr/sbin/setkey -f
	flush;
	spdflush;

	add 192.168.0.42 192.168.0.1 ah 24500 -A hmac-md5 "1234567890123456";
	add 192.168.0.42 192.168.0.1 esp 24501 -E 3des-cbc "123456789012123456789012";

	spdadd 192.168.0.42 192.168.0.1 any -P out ipsec
		esp/transport//require
		ah/transport//require;

setkey: invalid keymsg length

Policy dump will bail out with the same message after that.

-recv(4, "\2\16\0\0\32\0\3\0\0\0\0\0\37\r\0\0\3\0\5\0\377 \0\0\2\0\0\0\300\250\0*\0"..., 32768, 0) = 208
+recv(4, "\2\16\0\0\36\0\3\0\0\0\0\0H\t\0\0\3\0\5\0\377 \0\0\2\0\0\0\300\250\0*\0"..., 32768, 0) = 208

Dunno how to explain this, but the following patch works. :^)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/key/af_key.c |    1 -
 1 file changed, 1 deletion(-)

--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2075,7 +2075,6 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 			req_size += socklen * 2;
 		} else {
 			size -= 2*socklen;
-			socklen = 0;
 		}
 		rq = (void*)skb_put(skb, req_size);
 		pol->sadb_x_policy_len += req_size/8;
