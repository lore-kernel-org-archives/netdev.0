From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-2.6 v2 2/3] bnx2x: Look inside vlan when determining checksum proto.
Date: Thu, 11 Nov 2010 15:47:58 -0800
Message-ID: <1289519279-20641-2-git-send-email-jesse@nicira.com>
References: <1289519279-20641-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, Hao Zheng <hzheng@nicira.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64599 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab0KKXsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 18:48:09 -0500
Received: by vws13 with SMTP id 13so732755vws.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 15:48:08 -0800 (PST)
In-Reply-To: <1289519279-20641-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hao Zheng <hzheng@nicira.com>

Currently the skb->protocol field is used to setup checksum
offloading on transmit for the correct protocol.  However, if
vlan offloading is disabled or otherwise not used, the protocol
field will be ETH_P_8021Q, not the actual protocol.  This will
cause the checksum to be not computed correctly, even though the
hardware is capable of looking inside vlan tags.  Instead,
look inside the header if necessary to determine the correct
protocol type.

To some extent this fixes a regression from 2.6.36 because it
was previously not possible to disable vlan offloading and this
error case was not exposed.

Signed-off-by: Hao Zheng <hzheng@nicira.com>
CC: Eilon Greenstein <eilong@broadcom.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
--
Unchanged from v1.
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 459614d..94d5f59 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1680,7 +1680,7 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 		rc = XMIT_PLAIN;
 
 	else {
-		if (skb->protocol == htons(ETH_P_IPV6)) {
+		if (vlan_get_protocol(skb) == htons(ETH_P_IPV6)) {
 			rc = XMIT_CSUM_V6;
 			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 				rc |= XMIT_CSUM_TCP;
-- 
1.7.1

