From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] x25: add a sanity check parsing X.25 facilities
Date: Tue, 3 Sep 2013 12:03:40 +0300
Message-ID: <20130903090340.GB4351@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37940 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932515Ab3ICJD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 05:03:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was found with a manual audit and I don't have a reproducer.  We
limit ->calling_len and ->called_len when we get them from
copy_from_user() in x25_ioctl() so when they come from skb->data then
we should cap them there as well.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Possibly should be applied to -stable.  My guess is that this leads to
memory corruption, but I don't know.

diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index 66c63873..b825325 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -156,6 +156,8 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 			case X25_FAC_CALLING_AE:
 				if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <= 1)
 					return -1;
+				if (p[2] > X25_MAX_AE_LEN)
+					return -1;
 				dte_facs->calling_len = p[2];
 				memcpy(dte_facs->calling_ae, &p[3], p[1] - 1);
 				*vc_fac_mask |= X25_MASK_CALLING_AE;
@@ -163,6 +165,8 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 			case X25_FAC_CALLED_AE:
 				if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <= 1)
 					return -1;
+				if (p[2] > X25_MAX_AE_LEN)
+					return -1;
 				dte_facs->called_len = p[2];
 				memcpy(dte_facs->called_ae, &p[3], p[1] - 1);
 				*vc_fac_mask |= X25_MASK_CALLED_AE;
