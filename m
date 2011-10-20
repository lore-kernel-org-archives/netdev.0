From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/5] macvtap: Close a race between macvtap_open and macvtap_dellink.
Date: Thu, 20 Oct 2011 07:26:01 -0700
Message-ID: <m1sjmnu4cm.fsf@fess.ebiederm.org>
References: <m1wrbzu4ec.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arnd.de>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Shirly Ma <mashirley@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57782 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331Ab1JTOZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:25:30 -0400
In-Reply-To: <m1wrbzu4ec.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 20 Oct 2011 07:24:59 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is a small window in macvtap_open between looking up a
networking device and calling macvtap_set_queue in which
macvtap_del_queues called from macvtap_dellink.   After
calling macvtap_del_queues it is totally incorrect to
allow macvtap_set_queue to proceed so prevent success by
reporting that all of the available queues are in use.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/macvtap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3da5578..70aa628 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -231,6 +231,8 @@ static void macvtap_del_queues(struct net_device *dev)
 		}
 	}
 	BUG_ON(vlan->numvtaps != 0);
+	/* guarantee that any future macvtap_set_queue will fail */
+	vlan->numvtaps = MAX_MACVTAP_QUEUES;
 	spin_unlock(&macvtap_lock);
 
 	synchronize_rcu();
-- 
1.7.2.5
