From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 1/1] net: ipv4: Fix truncated timestamp returned by inet_current_timestamp()
Date: Mon, 21 Mar 2016 17:41:11 -0700
Message-ID: <1458607271-6984-1-git-send-email-deepa.kernel@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Arnd Bergmann <arnd@arndb.de>
To: y2038@list.linaro.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35323 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbcCVAm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 20:42:26 -0400
Received: by mail-pf0-f193.google.com with SMTP id u190so32841284pfb.2
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 17:42:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The millisecond timestamps returned by the function is
converted to network byte order by making a call to htons().
htons() only returns __be16 while __be32 is required here.

This was identified by the sparse warning from the buildbot:
net/ipv4/af_inet.c:1405:16: sparse: incorrect type in return
			    expression (different base types)
net/ipv4/af_inet.c:1405:16: expected restricted __be32
net/ipv4/af_inet.c:1405:16: got restricted __be16 [usertype] <noident>

Change the function to use htonl() to return the correct __be32 type
instead so that the millisecond value doesn't get truncated.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: James Morris <jmorris@namei.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Arnd Bergmann <arnd@arndb.de>
Fixes: 822c868532ca ("net: ipv4: Convert IP network timestamps to be y2038 safe")
Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
---
 net/ipv4/af_inet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0cc923f..5fab7e3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1402,7 +1402,7 @@ __be32 inet_current_timestamp(void)
 	msecs += (u32)ts.tv_nsec / NSEC_PER_MSEC;
 
 	/* Convert to network byte order. */
-	return htons(msecs);
+	return htonl(msecs);
 }
 EXPORT_SYMBOL(inet_current_timestamp);
 
-- 
1.9.1
