From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix sctp_auth_asoc_get_hmac() to avoid kernel panic
Date: Thu, 20 Mar 2008 13:53:36 +0800
Message-ID: <47E1FBE0.6030209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57995 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753235AbYCTFwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 01:52:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If association is setup with HMAC-ALGO parameter in which there is no 
HMAC algorithm supported by the endpoint, send a chunk with AUTH will 
cause kernel panic.

This is because  when send chunk with AUTH, sctp_auth_asoc_get_hmac() 
will be used to get the hmac. In this function, if the HMAC-ALGO is 
empty, it return NULL. If is not empty, it will find a valid hmac for 
using. But if all of the HMAC-ALGOs is not supported by endpoint, it 
will return a bogus pointer, not expected NULL pointer.

This patch fix this problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/sctp/auth.c	2008-02-11 17:14:05.000000000 -0500
+++ b/net/sctp/auth.c	2008-02-14 02:01:18.000000000 -0500
@@ -549,13 +549,10 @@ struct sctp_hmac *sctp_auth_asoc_get_hma
 		if (!sctp_hmac_list[id].hmac_name)
 			continue;
 
-		break;
+		return &sctp_hmac_list[id];
 	}
 
-	if (id == 0)
-		return NULL;
-
-	return &sctp_hmac_list[id];
+	return NULL;
 }
 
 static int __sctp_auth_find_hmacid(__be16 *hmacs, int n_elts, __be16 hmac_id)


