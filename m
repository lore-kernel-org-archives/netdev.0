From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/5] macvtap: Fix macvtap_open races in the zero copy enable code.
Date: Thu, 20 Oct 2011 07:26:39 -0700
Message-ID: <m1mxcvu4bk.fsf_-_@fess.ebiederm.org>
References: <m1wrbzu4ec.fsf@fess.ebiederm.org>
	<m1sjmnu4cm.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arnd.de>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Shirly Ma <mashirley@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51566 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693Ab1JTO0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:26:11 -0400
In-Reply-To: <m1sjmnu4cm.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 20 Oct 2011 07:26:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To see if it is appropriate to enable the macvtap zero copy feature
don't test the lowerdev network device flags.   Instead test the
macvtap network device flags which are a direct copy of the lowerdev
flags.  This is important because nothing holds a reference to lowerdev
and on a very bad day we lowerdev could be a pointer to stale memory.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/macvtap.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 70aa628..1d9c9c2 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -343,7 +343,6 @@ static int macvtap_open(struct inode *inode, struct file *file)
 {
 	struct net *net = current->nsproxy->net_ns;
 	struct net_device *dev = dev_get_by_index(net, iminor(inode));
-	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvtap_queue *q;
 	int err;
 
@@ -376,12 +375,12 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	/*
 	 * so far only KVM virtio_net uses macvtap, enable zero copy between
 	 * guest kernel and host kernel when lower device supports zerocopy
+	 *
+	 * The macvlan supports zerocopy iff the lower device supports zero
+	 * copy so we don't have to look at the lower device directly.
 	 */
-	if (vlan) {
-		if ((vlan->lowerdev->features & NETIF_F_HIGHDMA) &&
-		    (vlan->lowerdev->features & NETIF_F_SG))
-			sock_set_flag(&q->sk, SOCK_ZEROCOPY);
-	}
+	if ((dev->features & NETIF_F_HIGHDMA) && (dev->features & NETIF_F_SG))
+		sock_set_flag(&q->sk, SOCK_ZEROCOPY);
 
 	err = macvtap_set_queue(dev, file, q);
 	if (err)
-- 
1.7.2.5
