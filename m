From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvtap: Correctly set tap features when IFF_VNET_HDR is
 disabled.
Date: Wed, 14 Aug 2013 20:43:39 +0300
Message-ID: <20130814174339.GA17580@redhat.com>
References: <1376416558-25015-1-git-send-email-vyasevic@redhat.com>
 <20130814121043.GH5430@redhat.com>
 <520B8F05.6060402@redhat.com>
 <520BAA86.1060204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758368Ab3HNRmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 13:42:04 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7EHg3sB009890
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 13:42:03 -0400
Content-Disposition: inline
In-Reply-To: <520BAA86.1060204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 12:04:22PM -0400, Vlad Yasevich wrote:
> On 08/14/2013 10:07 AM, Vlad Yasevich wrote:
> >On 08/14/2013 08:10 AM, Michael S. Tsirkin wrote:
> >>On Tue, Aug 13, 2013 at 01:55:58PM -0400, Vlad Yasevich wrote:
> >>>When the user turns off IFF_VNET_HDR flag, attempts to change
> >>>offload features via TUNSETOFFLOAD do not work.  This could cause
> >>>GSO packets to be delivered to the user when the user is
> >>>not prepared to handle them.
> >>>
> >>>To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
> >>>disabled and make sure to turn off all offloads in this case.
> >>>Also, when IFF_VNET_HDR is disabled, run throught the offload change
> >>>as well to make sure that the functionality is not dependent on
> >>>the order of the ioclt() calls.
> >>>
> >>>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> >>
> >>Hmm, this seems to make it even messier.
> >>So
> >>    set TUNSETOFFLOAD
> >>    clear IFF_VNET_HDR
> >>    set IFF_VNET_HDR
> >>
> >>offloads are now clear?
> >>
> >>I'm also not sure userspace that sets offloads but clears
> >>vnet hdr knows what it's doing.
> >>
> >>How about we fail attempts to clear vnet hdr
> >>unless offloads are disabled?
> >>
> >
> >OK.  That makes it simpler...
> 
> Spoke too soon.
> 
> What happens is that libvirt is typically the one that turns off
> IFF_VNET_HDR, and qemu controls the offloads.
> 
> So, if we forbid turning off vnet_hdr while offloads are set, that
> will break libvirt (this is because macvtap defaults to tap offloads
> being enabled).
> 
> -vlad

Well what prevents libvirt from disabling offloads?
Anyway, another approach is to say that this is up to user -
if user disables hdr but not offloads, user will get
packets without a checksum.



> >
> >-vlad
> >
> >>
> >>
> >>
> >>>---
> >>>  drivers/net/macvtap.c | 27 +++++++++++++++++++--------
> >>>  1 file changed, 19 insertions(+), 8 deletions(-)
> >>>
> >>>diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> >>>index a98fb0e..076b9e7 100644
> >>>--- a/drivers/net/macvtap.c
> >>>+++ b/drivers/net/macvtap.c
> >>>@@ -1019,6 +1019,7 @@ static int set_offload(struct macvtap_queue *q,
> >>>unsigned long arg)
> >>>      struct macvlan_dev *vlan;
> >>>      netdev_features_t features;
> >>>      netdev_features_t feature_mask = 0;
> >>>+    netdev_features_t tap_mask = TUN_OFFLOADS;
> >>>
> >>>      vlan = rtnl_dereference(q->vlan);
> >>>      if (!vlan)
> >>>@@ -1026,7 +1027,12 @@ static int set_offload(struct macvtap_queue
> >>>*q, unsigned long arg)
> >>>
> >>>      features = vlan->dev->features;
> >>>
> >>>-    if (arg & TUN_F_CSUM) {
> >>>+    if (!(q->flags & IFF_VNET_HDR)) {
> >>>+        /* Turn off all checsum offloading also if user does
> >>>+         * not user vnet_hdr.
> >>
> >>Does not set?
> >>
> >>>+         */
> >>>+        tap_mask |= NETIF_F_ALL_CSUM;
> >>>+    } else if (arg & TUN_F_CSUM) {
> >>>          feature_mask = NETIF_F_HW_CSUM;
> >>>
> >>>          if (arg & (TUN_F_TSO4 | TUN_F_TSO6)) {
> >>>@@ -1058,8 +1064,7 @@ static int set_offload(struct macvtap_queue *q,
> >>>unsigned long arg)
> >>>      /* tap_features are the same as features on tun/tap and
> >>>       * reflect user expectations.
> >>>       */
> >>>-    vlan->tap_features = vlan->dev->features &
> >>>-                (feature_mask | ~TUN_OFFLOADS);
> >>>+    vlan->tap_features = vlan->dev->features & (feature_mask |
> >>>~tap_mask);
> >>>      vlan->set_features = features;
> >>>      netdev_update_features(vlan->dev);
> >>>
> >>>@@ -1092,8 +1097,18 @@ static long macvtap_ioctl(struct file *file,
> >>>unsigned int cmd,
> >>>          if ((u & ~(IFF_VNET_HDR | IFF_MULTI_QUEUE)) !=
> >>>              (IFF_NO_PI | IFF_TAP))
> >>>              ret = -EINVAL;
> >>>-        else
> >>>+        else {
> >>>+            if ((q->flags ^ u) & IFF_VNET_HDR) {
> >>>+                /* vnet_hdr support impacts the offloads,
> >>>+                 * so we need to run throught the offload
> >>
> >>throught ?
> >>
> >>>+                 * change.
> >>>+                 */
> >>>+                rtnl_lock();
> >>>+                ret = set_offload(q, 0);
> >>>+                rtnl_unlock();
> >>>+            }
> >>>              q->flags = u;
> >>>+        }
> >>>
> >>>          return ret;
> >>>
> >>>@@ -1155,10 +1170,6 @@ static long macvtap_ioctl(struct file *file,
> >>>unsigned int cmd,
> >>>                  TUN_F_TSO_ECN | TUN_F_UFO))
> >>>              return -EINVAL;
> >>>
> >>>-        /* TODO: only accept frames with the features that
> >>>-             got enabled for forwarded frames */
> >>>-        if (!(q->flags & IFF_VNET_HDR))
> >>>-            return  -EINVAL;
> >>>          rtnl_lock();
> >>>          ret = set_offload(q, arg);
> >>>          rtnl_unlock();
> >>>--
> >>>1.8.1.4
> >
