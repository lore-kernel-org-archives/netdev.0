From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 11/31] net: Initialize the network namespace of network devices.
Date: Thu, 25 Jan 2007 12:00:13 -0700
Message-ID: <11697516352135-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35813 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030488AbXAYTBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:40 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Except for carefully selected pseudo devices all network
interfaces should start out in the initial network namespace.
Ultimately it will be register_netdev that examines what
dev->nd_net is set to and places a device in a network namespace.

This patch modifies alloc_netdev to initialize the network
namespace a device is in with the initial network namespace.
This gets it right for the vast majority of devices so their
drivers need not be modified and for those few pseudo devices
that need something different they can change this parameter
before calling register_netdevice.

The network namespace parameter on a network device is not
reference counted as the devices are inside of a network namespace
and cannot remain in that namespace past the lifetime of the
network namespace.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/loopback.c |    1 +
 net/core/dev.c         |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 2b739fd..22b672d 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -231,6 +231,7 @@ struct net_device loopback_dev = {
 /* Setup and register the loopback device. */
 static int __init loopback_init(void)
 {
+	loopback_dev.nd_net = init_net();
 	return register_netdev(&loopback_dev);
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 90e4c0e..a3ee150 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3192,6 +3192,7 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	dev = (struct net_device *)
 		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
+	dev->nd_net = init_net();
 
 	if (sizeof_priv)
 		dev->priv = netdev_priv(dev);
-- 
1.4.4.1.g278f

