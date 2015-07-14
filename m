From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v3 5/5] ipvlan: ignore addresses from ipv6 autoconfiguration
Date: Tue, 14 Jul 2015 16:35:55 +0300
Message-ID: <20150714133555.22448.82099.stgit@buzz>
References: <20150714132941.22448.42175.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: linux-netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:59170 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752928AbbGNNf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 09:35:58 -0400
In-Reply-To: <20150714132941.22448.42175.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inet6addr notifier is atomic and runs in bh context without RTNL when
ipv6 receives router advertisement packet and performs autoconfiguration.

Proper fix still in discussion. Let's at least plug the bug.
v1: http://lkml.kernel.org/r/20150514135618.14062.1969.stgit@buzz
v2: http://lkml.kernel.org/r/20150703125840.24121.91556.stgit@buzz

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ipvlan/ipvlan_main.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index e995bc501ee6..20b58bdecf75 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -655,6 +655,10 @@ static int ipvlan_addr6_event(struct notifier_block *unused,
 	struct net_device *dev = (struct net_device *)if6->idev->dev;
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 
+	/* FIXME IPv6 autoconf calls us from bh without RTNL */
+	if (in_softirq())
+		return NOTIFY_DONE;
+
 	if (!netif_is_ipvlan(dev))
 		return NOTIFY_DONE;
 
