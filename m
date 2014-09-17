From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Subject: [PATCH 1/1] net: allow macvlans to move to net namespace
Date: Wed, 17 Sep 2014 11:12:27 -0700
Message-ID: <20140917181227.09F4E480087@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@arista.com, fw@strlen.de, chenweilong@huawei.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.aristanetworks.com ([162.210.130.12]:49325 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755807AbaIQSVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 14:21:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 6dad8398aee7fec77838ad591871745508ed481d Mon Sep 17 00:00:00 2001
From: Francesco Ruggeri <fruggeri@arista.com>
Date: Wed, 17 Sep 2014 10:40:44 -0700
Subject: [PATCH 1/1] net: allow macvlans to move to net namespace

I cannot move a macvlan interface created on top of a bonding interface
to a different namespace:

% ip netns add dummy0
% ip link add link bond0 mac0 type macvlan
% ip link set mac0 netns dummy0
RTNETLINK answers: Invalid argument
%

The problem seems to be that commit f9399814927a ("bonding: Don't allow
bond devices to change network namespaces.") sets NETIF_F_NETNS_LOCAL
on bonding interfaces, and commit 797f87f83b60 ("macvlan: fix netdev
feature propagation from lower device") causes macvlan interfaces
to inherit its features from the lower device.

NETIF_F_NETNS_LOCAL should not be inherited from the lower device
by a macvlan.
Patch tested on 3.16.

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 drivers/net/macvlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index a969555..7652fd1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -806,6 +806,7 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 					     features,
 					     mask);
 	features |= ALWAYS_ON_FEATURES;
+	features &= ~NETIF_F_NETNS_LOCAL;
 
 	return features;
 }
-- 
1.8.1.4
