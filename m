From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net] net: ptp: fix time stamp matching logic for VLAN packets.
Date: Wed, 12 Nov 2014 11:33:52 +0100
Message-ID: <1415788432-21617-1-git-send-email-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:64071 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbaKLKeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 05:34:02 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi2so4376274wib.1
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 02:34:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ae5c6c6d "ptp: Classify ptp over ip over vlan packets" changed the
code in two drivers that matches time stamps with PTP frames, with the goal
of allowing VLAN tagged PTP packets to receive hardware time stamps.

However, that commit failed to account for the VLAN header when parsing
IPv4 packets. This patch fixes those two drivers to correctly match VLAN
tagged IPv4/UDP PTP messages with their time stamps.

This patch should also be applied to v3.17.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c |    2 +-
 drivers/net/phy/dp83640.c      |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index ab92f67..4a4388b 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -264,7 +264,7 @@ static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
 
 	switch (ptp_class & PTP_CLASS_PMASK) {
 	case PTP_CLASS_IPV4:
-		offset += ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
+		offset += ETH_HLEN + IPV4_HLEN(data + offset) + UDP_HLEN;
 		break;
 	case PTP_CLASS_IPV6:
 		offset += ETH_HLEN + IP6_HLEN + UDP_HLEN;
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 2954052..e22e602 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -791,7 +791,7 @@ static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
 
 	switch (type & PTP_CLASS_PMASK) {
 	case PTP_CLASS_IPV4:
-		offset += ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
+		offset += ETH_HLEN + IPV4_HLEN(data + offset) + UDP_HLEN;
 		break;
 	case PTP_CLASS_IPV6:
 		offset += ETH_HLEN + IP6_HLEN + UDP_HLEN;
@@ -934,7 +934,7 @@ static int is_sync(struct sk_buff *skb, int type)
 
 	switch (type & PTP_CLASS_PMASK) {
 	case PTP_CLASS_IPV4:
-		offset += ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
+		offset += ETH_HLEN + IPV4_HLEN(data + offset) + UDP_HLEN;
 		break;
 	case PTP_CLASS_IPV6:
 		offset += ETH_HLEN + IP6_HLEN + UDP_HLEN;
-- 
1.7.10.4
