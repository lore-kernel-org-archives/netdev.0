From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: [PATCH] dev_change_net_namespace: send a KOBJ_REMOVED/KOBJ_ADD
Date: Mon, 3 Dec 2012 20:17:12 -0600
Message-ID: <20121204021712.GA10268@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Lezcano <dlezcano@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a new nic is created in namespace ns1, the kernel sends a KOBJ_ADD uevent
to ns1.  When the nic is moved to ns2, we only send a KOBJ_MOVE to ns2, and
nothing to ns1.

This patch changes that behavior so that when moving a nic from ns1 to ns2, we
send a KOBJ_REMOVED to ns1 and KOBJ_ADD to ns2.  (The KOBJ_MOVE is still
sent to ns2).

The effects of this can be seen when starting and stopping containers in
an upstart based host.  Lxc will create a pair of veth nics, the kernel
sends KOBJ_ADD, and upstart starts network-instance jobs for each.  When
one nic is moved to the container, because no KOBJ_REMOVED event is
received, the network-instance job for that veth never goes away.  This
was reported at https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1065589
With this patch the networ-instance jobs properly go away.

The other oddness solved here is that if a nic is passed into a running
upstart-based container, without this patch no network-instance job is
started in the container.  But when the container creates a new nic
itself (ip link add new type veth) then network-interface jobs are
created.  With this patch, behavior comes in line with a regular host.

v2: also send KOBJ_ADD to new netns.  There will then be a
_MOVE event from the device_rename() call, but that should
be innocuous.

Signed-off-by: Serge Hallyn <serge.hallyn@canonical.com>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
---
 net/core/dev.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index e2215ee..2c43aaf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6172,6 +6172,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_uc_flush(dev);
 	dev_mc_flush(dev);
 
+	/* Send a netdev-removed uevent to the old namespace */
+	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
+
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
@@ -6183,6 +6186,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 			dev->iflink = dev->ifindex;
 	}
 
+	/* Send a netdev-add uevent to the new namespace */
+	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
+
 	/* Fixup kobjects */
 	err = device_rename(&dev->dev, dev->name);
 	WARN_ON(err);
-- 
1.7.9.5
