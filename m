From: "[PATCH 1/2]"@fess.ebiederm.org, "net:In"@fess.ebiederm.org,
	unregister_netdevice_notifier@fess.ebiederm.org,
	unregister@fess.ebiederm.org, the@fess.ebiederm.org,
	"netdevices."@fess.ebiederm.org
Subject: Re: net: kernel BUG() in net/netns/generic.h:45
Date: Fri, 06 Apr 2012 18:31:14 -0700
Message-ID: <m1iphctjj1.fsf@fess.ebiederm.org>
References: <1333664446.3538.12.camel@lappy>
	<m1aa2pwxap.fsf@fess.ebiederm.org>
	<CA+1xoqdi4QOhRJvBA64pxiN3EphhThjPkf4eLRkYM8jxcJjh=w@mail.gmail.com>
	<m1mx6otk85.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Dave Jones <davej@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	=?utf-8?Q?R=C3=A9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Sasha Levin <levinsasha928@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1mx6otk85.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Fri, 06 Apr 2012 18:16:10 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We already synthesize events in register_netdevice_notifier and synthesizing
events in unregister_netdevice_notifier allows to us remove the need for
special case cleanup code.

This change should be trivially safe as it adds no new cases for
existing callers of unregister_netdevice_notifier to handle.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 452db70..77c0a87 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1410,14 +1410,34 @@ EXPORT_SYMBOL(register_netdevice_notifier);
  *	register_netdevice_notifier(). The notifier is unlinked into the
  *	kernel structures and may then be reused. A negative errno code
  *	is returned on a failure.
+ *
+ * 	After unregistering unregister and down device events are synthesized
+ *	for all devices on the device list to the removed notifier to remove
+ *	the need for special case cleanup code.
  */
 
 int unregister_netdevice_notifier(struct notifier_block *nb)
 {
+	struct net_device *dev;
+	struct net *net;
 	int err;
 
 	rtnl_lock();
 	err = raw_notifier_chain_unregister(&netdev_chain, nb);
+	if (err)
+		goto unlock;
+
+	for_each_net(net) {
+		for_each_netdev(net, dev) {
+			if (dev->flags & IFF_UP) {
+				nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
+				nb->notifier_call(nb, NETDEV_DOWN, dev);
+			}
+			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
+			nb->notifier_call(nb, NETDEV_UNREGISTER_BATCH, dev);
+		}
+	}
+unlock:
 	rtnl_unlock();
 	return err;
 }
-- 
1.7.2.5
