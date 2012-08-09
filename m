From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/5] veth: Allow to create peer link with given ifindex
Date: Thu, 09 Aug 2012 11:53:03 +0400
Message-ID: <50236C5F.1010609@parallels.com>
References: <50236C20.4050108@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18604 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754371Ab2HIHxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 03:53:12 -0400
In-Reply-To: <50236C20.4050108@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ifinfomsg is in there (thanks kaber@ for foreseeing this long time ago),
so take the given ifidex and register netdev with it.

Ben noticed, that this code path previously ignored ifmp->ifi_index and
userland could be passing in garbage. Thus it may now fail occasionally
because the value clashes with an existing interface.

To address this it's assumed that if the caller specifies the ifindex for
the veth master device, then it's aware of this possibility and should
explicitly specify (or set to 0 for auto-assignment) the peer's ifindex as
well. With this the compatibility with old tools not setting ifindex is
preserved.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 drivers/net/veth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 5852361..e522ff7 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -348,6 +348,9 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	if (tbp[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(peer);
 
+	if (ifmp && (dev->ifindex != 0))
+		peer->ifindex = ifmp->ifi_index;
+
 	err = register_netdevice(peer);
 	put_net(net);
 	net = NULL;
-- 
1.7.6.5
