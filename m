From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] nlmon: fix comparison in nlmon_is_valid_mtu
Date: Thu, 27 Jun 2013 13:44:26 +0200
Message-ID: <1372333466-29913-1-git-send-email-dborkman@redhat.com>
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069Ab3F0Lo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 07:44:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following warning introduced in e4fc408e0e99
("packet: nlmon: virtual netlink monitoring device for packet
sockets") reported by Dan Carpenter:

warning: "drivers/net/nlmon.c:31 nlmon_is_valid_mtu()
	 warn: always true condition '(new_mtu <= ((~0 >> 1))) =>
				      (s32min-s32max <= s32max)'"

Thus, we should simply remove the test against INT_MAX. Next to that
we also need to explicitly cast the sizeof() case as the comparison
is type promoted to unsigned long so negative values are then
valid instead of invalid. While at it, this also adds a comment about
Netlink and MTUs.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Thanks again Dan! Note that this only concerns net-next, not net.

 drivers/net/nlmon.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index dc364be..0fad94d 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -28,7 +28,11 @@ static netdev_tx_t nlmon_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int nlmon_is_valid_mtu(int new_mtu)
 {
-	return new_mtu >= sizeof(struct nlmsghdr) && new_mtu <= INT_MAX;
+	/* Note that in netlink we do not really have an upper limit. On
+	 * default, we use NLMSG_GOODSIZE. Here at least we should make
+	 * sure that it's at least the header size.
+	 */
+	return new_mtu >= (int) sizeof(struct nlmsghdr);
 }
 
 static int nlmon_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.7.11.7
