From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] macvtap: Correctly set tap features when IFF_VNET_HDR
 is disabled.
Date: Wed, 14 Aug 2013 23:52:36 +0300
Message-ID: <20130814205236.GA6412@redhat.com>
References: <1376499820-27764-1-git-send-email-vyasevic@redhat.com>
 <20130814192437.GA20226@redhat.com>
 <520BE700.7020302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933083Ab3HNUvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 16:51:00 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7EKp0rF020913
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 16:51:00 -0400
Content-Disposition: inline
In-Reply-To: <520BE700.7020302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 04:22:24PM -0400, Vlad Yasevich wrote:
> On 08/14/2013 03:24 PM, Michael S. Tsirkin wrote:
> >On Wed, Aug 14, 2013 at 01:03:40PM -0400, Vlad Yasevich wrote:
> >>When the user turns off IFF_VNET_HDR flag, attempts to change
> >>offload features via TUNSETOFFLOAD do not work.  This could cause
> >>GSO packets to be delivered to the user when the user is
> >>not prepared to handle them.
> >
> >Just to clarify - is there some userspace that actually
> >triggers this?
> 
> Yes.  The configuration that triggers is running windows guest
> which uses non-virtio driver over macvtap.
> 
> The issue is that in non-virtio configuration, libvirt turns off
> IFF_VNET_HDR support in macvtap.  Later, windows guest end up trying
> to change offload capabilities.  Win7 (and others that don't support
> GSO) will try to turn off offloads and that operation will fail.  Thus
> GSO packets will get queued to the socket without vnet hdr support.
> 
> -vlad

OK so I'm guessing the root of the problem is that offloads
default to on for macvtap.

> >
> >
> >>To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
> >>disabled.  Treat any attempt to enable offloads as an error in
> >>this case.
> >>We also need to update the TUN_FEATURES mask to include all checksum
> >>options as the underlying device may have something other then
> >>HW_CSUM set.
> >>
> >>Change since v1:
> >>   - Removed the call to update offloads when IFF_VNET_HDR is turned off.
> >>   - Changed the macvtap version of TUN_OFFLOADS to include all checksum
> >>     offloads since the physical nic may have them set.
> >>   - Treat enabling of offloads without vnet_hdr support as error.
> >>
> >>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> >>---
> >>  drivers/net/macvtap.c | 12 +++++++-----
> >>  1 file changed, 7 insertions(+), 5 deletions(-)
> >>
> >>diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> >>index a98fb0e..3acfc37 100644
> >>--- a/drivers/net/macvtap.c
> >>+++ b/drivers/net/macvtap.c
> >>@@ -65,7 +65,7 @@ static struct cdev macvtap_cdev;
> >>
> >>  static const struct proto_ops macvtap_socket_ops;
> >>
> >>-#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
> >>+#define TUN_OFFLOADS (NETIF_F_ALL_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
> >>  		      NETIF_F_TSO6 | NETIF_F_UFO)
> >>  #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
> >>  /*
> >>@@ -1024,6 +1024,12 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
> >>  	if (!vlan)
> >>  		return -ENOLINK;
> >>
> >>+	/* If the user is trying to set offloads while IFF_VNET_HDR is
> >>+	 * off, report it as an error.
> >>+	 */
> >>+	if (!(q->flags & IFF_VNET_HDR) && arg)
> >>+		return -EINVAL;
> >>+

So now you can disable hdr versus offloads in any order,
but you still must first enable hdr and then the offloads.
Which looks asymmetrical.
Maybe just drop this completely? You can get an invalid
state temporarily but we live with it e.g. for packet sockets.

> >>  	features = vlan->dev->features;
> >>
> >>  	if (arg & TUN_F_CSUM) {
> >>@@ -1155,10 +1161,6 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
> >>  			    TUN_F_TSO_ECN | TUN_F_UFO))
> >>  			return -EINVAL;
> >>
> >>-		/* TODO: only accept frames with the features that
> >>-			 got enabled for forwarded frames */
> >>-		if (!(q->flags & IFF_VNET_HDR))
> >>-			return  -EINVAL;
> >>  		rtnl_lock();
> >>  		ret = set_offload(q, arg);
> >>  		rtnl_unlock();
> >>--
> >>1.8.1.4
