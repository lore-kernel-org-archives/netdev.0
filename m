From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] mpls: allow routes on ipgre devices
Date: Thu, 16 Jun 2016 17:09:09 +0900
Message-ID: <1466064549-32647-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Robert Shearman <rshearma@brocade.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Simon Horman <simon.horman@netronome.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32777 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbcFPIJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 04:09:21 -0400
Received: by mail-pf0-f170.google.com with SMTP id i123so13946008pfg.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 01:09:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This appears to be necessary and sufficient to provide
MPLS in GRE (RFC4023) support.

This can be used by establishing an ipgre tunnel device
and then routing MPLS over it.

The following example will forward MPLS frames received with an outermost
MPLS label 100 over tun1, a GRE tunnel. The forwarded packet will have the
outermost MPLS LSE removed and two new LSEs added with labels 200
(outermost) and 300 (next).

ip link add name tun1 type gre remote 10.0.99.193 local 10.0.99.192 ttl 225
ip link set up dev tun1
ip addr add 10.0.98.192/24 dev tun1
ip route sh

echo 1 > /proc/sys/net/mpls/conf/eth0/input
echo 101 > /proc/sys/net/mpls/platform_labels
ip -f mpls route add 100 as 200/300 via inet 10.0.98.193
ip -f mpls route sh

Also remove unnecessary braces.

Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/mpls/af_mpls.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7a4aa3450dd7..e9beaa58573c 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1009,9 +1009,10 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 	unsigned int flags;
 
 	if (event == NETDEV_REGISTER) {
-		/* For now just support ethernet devices */
-		if ((dev->type == ARPHRD_ETHER) ||
-		    (dev->type == ARPHRD_LOOPBACK)) {
+		/* For now just support Ethernet and IPGRE devices */
+		if (dev->type == ARPHRD_ETHER ||
+		    dev->type == ARPHRD_LOOPBACK ||
+		    dev->type == ARPHRD_IPGRE) {
 			mdev = mpls_add_dev(dev);
 			if (IS_ERR(mdev))
 				return notifier_from_errno(PTR_ERR(mdev));
-- 
2.1.4
