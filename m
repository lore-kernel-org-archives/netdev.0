From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 4/4] [IPV6] TCPMD5: Fix deleting key operation.
Date: Wed, 21 Nov 2007 01:54:32 +0900 (JST)
Message-ID: <20071121.015432.109301152.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, ming-baini@163.com
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35819 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755198AbXKTQy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 11:54:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to the bug, refcnt for md5sig pool was leaked when
an user try to delete a key if we have more than one key.
In addition to the leakage, we returned incorrect return
result value for userspace.

This fix should close Bug #9418, reported by <ming-baini@163.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/tcp_ipv6.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b1bfbdd..93980c3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -637,10 +637,6 @@ static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
 				kfree(tp->md5sig_info->keys6);
 				tp->md5sig_info->keys6 = NULL;
 				tp->md5sig_info->alloced6 = 0;
-
-				tcp_free_md5sig_pool();
-
-				return 0;
 			} else {
 				/* shrink the database */
 				if (tp->md5sig_info->entries6 != i)
@@ -649,6 +645,8 @@ static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
 						(tp->md5sig_info->entries6 - i)
 						* sizeof (tp->md5sig_info->keys6[0]));
 			}
+			tcp_free_md5sig_pool();
+			return 0;
 		}
 	}
 	return -ENOENT;
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
