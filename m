From: Ian Wienand <iwienand@redhat.com>
Subject: [PATCH net] OVS: Ignore negative headroom value
Date: Wed, 3 Aug 2016 09:56:46 +1000
Message-ID: <52e102db-a75f-c239-b396-ac2b9860d809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Benjamin Poirier <bpoirier@suse.com>,
	Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755194AbcHBX4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 19:56:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

net_device->ndo_set_rx_headroom (introduced in
871b642adebe300be2e50aa5f65a418510f636ec) says

  "Setting a negative value reset the rx headroom
   to the default value".

It seems that the OVS implementation in
3a927bc7cf9d0fbe8f4a8189dd5f8440228f64e7 overlooked this and sets
dev->needed_headroom unconditionally.

This doesn't have an immediate effect, but can mess up later
LL_RESERVED_SPACE calculations, such as done in
net/ipv6/mcast.c:mld_newpack.  For reference, this issue was found
from a skb_panic raised there after the length calculations had given
the wrong result.

Note the other current users of this interface
(drives/net/tun.c:tun_set_headroom and
drives/net/veth.c:veth_set_rx_headroom) are both checking this
correctly and thus need no modification.

An OpenStack tempest run
(http://docs.openstack.org/developer/tempest/) that reliably hit this
panic works correctly with this patch.  Thanks to Ben for some
pointers from the crash dumps!

Cc: Benjamin Poirier <bpoirier@suse.com>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org
Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1361414
Signed-off-by: Ian Wienand <iwienand@redhat.com>
---
 net/openvswitch/vport-internal_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 434e04c..f294253 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -140,7 +140,7 @@ internal_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 
 static void internal_set_rx_headroom(struct net_device *dev, int new_hr)
 {
-	dev->needed_headroom = new_hr;
+	dev->needed_headroom = new_hdr < 0 ? 0 : new_hr;
 }
 
 static const struct net_device_ops internal_dev_netdev_ops = {
-- 
2.7.4
