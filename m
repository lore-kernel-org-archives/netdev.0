From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH v2] xen-netback: fix some error return code
Date: Tue, 17 Dec 2013 10:42:09 +0800
Message-ID: <CAPgLHd9Q7A--LQnsMKt-Tt-FwrA3FC1Un3kwLRH5pc4Z3N2K7A@mail.gmail.com>
References: <CAPgLHd9aQQq-gLuNzGaYP2TSz=5Xk_GqgS=MSrAB7Tnn0nCydw@mail.gmail.com>
	<20131216131313.GE12582@zion.uk.xensource.com>
	<1387201238.10247.37.camel@kazak.uk.xensource.com>
	<CAPgLHd_yD=s0xKXop8T47hvxw2MZD9PHZ9tKKB+45Y5uOHNUVQ@mail.gmail.com>
	<1387203160.21086.1.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: wei.liu2@citrix.com, yongjun_wei@trendmicro.com.cn,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:43940 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab3LQCmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 21:42:10 -0500
Received: by mail-bk0-f50.google.com with SMTP id e11so2578192bkh.23
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 18:42:09 -0800 (PST)
In-Reply-To: <1387203160.21086.1.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'err' is overwrited to 0 after maybe_pull_tail() call, so the error
code was not set if skb_partial_csum_set() call failed. Fix to return
error -EPROTO from those error handling case instead of 0.

Fixes: d52eb0d46f36 ('xen-netback: make sure skb linear area covers checksum field')
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
v1 -> v2: rebased and fixed the description
---
 drivers/net/xen-netback/netback.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index e884ee1..5d28e64 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1206,8 +1206,10 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct tcphdr, check)))
+					  offsetof(struct tcphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			tcp_hdr(skb)->check =
@@ -1224,8 +1226,10 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct udphdr, check)))
+					  offsetof(struct udphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			udp_hdr(skb)->check =
@@ -1347,8 +1351,10 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct tcphdr, check)))
+					  offsetof(struct tcphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			tcp_hdr(skb)->check =
@@ -1365,8 +1371,10 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct udphdr, check)))
+					  offsetof(struct udphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			udp_hdr(skb)->check =
