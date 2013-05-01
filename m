From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: [PATCH] Add support for netconsole driver used on bridge device
 with VIF attached
Date: Wed, 01 May 2013 14:55:01 +0300
Message-ID: <1367409301.3301.21.camel@yuval-pc.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	ian.campbell@citrix.com, bridge <bridge@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46939 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755794Ab3EALzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 07:55:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When starting a VM which has virtual interface attached to the same bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is used for netconsole the
following message appears (after about 60 seconds) and VM creation operation fails.
     Error: Device 0 (vif) could not be connected. Hotplug scripts not working.

Note:
When trying to do the opposite, i.e. first create VM and then run
netconsole we got the error #524 - vif2.0 doesn't support polling,
aborting.

Here is my network setup:
----------                              ----------
| VM A1  |------vif1.0----->|           | Host B |
|--------|                  |--xenbr0   |        |
| Host A |--bond0 (eth0)--->|           |        |
----------          |                   ----------
                    |                        |
                    V                        V
--------------------------------------------------
|                      LAN                       |
--------------------------------------------------

I'm using netconsole to capture logs from  Host-A and send them to Host-B.
Host-A and Host-B are separate hosts (running XEN) which are  connected to the 
same LAN.
src-ip is Host-A address.
dst-ip/mac is Host-B address.
netconsole parameters: netconsole=1111@src-ip/xenbr0,2002@dst-ip/dst-mac

As i see it, netconsole driver requires ndo_poll_controller from the device's controlling driver (function __netpoll_setup in net/core/netpoll.c), a thing that is not supported currently in xen_netback driver which is the driver that runs on dom0 and serve VM's virtual interface.
call flow: init_netconsole() in netconsole.c -> alloc_param_target() -> netpoll_setup() 
in netpoll.c -> __netpoll_setup() which check if ndo_poll_controller()
Per Ian,
Are you sure this is being called for the VIF interface? In your
configuration I'd expect it to be called on the bridge not the vif, or
at least for calling on the VIF to not impact whether netpool was
enabled for the bridge or not.

I think the underlying issue which you are seeing is that
br_netpoll_setup() requires that all members of the bridge support
netpoll before allowing netpoll to be enabled on the bridge itself. 

This seems like an odd restriction in the bridge driver since in
principal only the port over which the netpoll traffic will be going
will need netpoll, but perhaps the bridge can't tell which port that is
or is going to be? I think it is worth discussing this with the bridge
maintainers (who I have CC'd, threads starts at
http://marc.info/?l=linux-netdev&m=135878868112700&w=2)

Hopefully the bridge isn't flooding/broadcasting netpoll to all ports,
at least in the case where DST IP and MAC have been specified. That
would be rather inefficient, especially when most ports go to virtual
machines.

So before I ack this patch I'd like to hear back from the bridge
maintainers about whether the current behaviour in the bridge is
intended and whether it could be fixed in some better way than adding
netpoll to netback.

AFAICT the only reason to actually support netpoll in netback would be
if you wanted host logs to go to a listener running in a domain on the
same host, which sounds like a mad idea to me! If someone actually has a
real need for that use case and can test that it works I'd be happy to
reconsider this patch on that basis (assuming the necessary #ifdefs are
added as mentioned before).

Per Ian,
I can see why the *bridge* device might need an ndo_poll_controller hook
in this setup but I can't see any reason why the netback device would
need one.
Reply:
Please note that without netback driver netconsole runs fine, i.e before trying 
to create VM which attached to the bridge.

The following patch (to latest kernel) fix this bug by adding implementation to ndo_poll_controller.

0001-Add-support-for-netconsole-driver-used-on-bridge-dev.patch
0 2001
From: Yuval <yuval.shaia@oracle.com>
Date: Tue, 8 Jan 2013 10:08:45 +0200
Subject: [PATCH] Add support for netconsole driver used on bridge device with
 VIF attached

Signed-off-by: Yuval <yuval.shaia@oracle.com>
---
 drivers/net/xen-netback/interface.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/xen-netback/interface.c \
b/drivers/net/xen-netback/interface.c index 601ae2a..10751f5 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -179,6 +179,13 @@ static u32 xenvif_fix_features(struct net_device *dev, u32 \
features)  return features;
 }
 
+static void xenvif_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	xenvif_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+
 static const struct xenvif_stat {
 	char name[ETH_GSTRING_LEN];
 	u16 offset;
@@ -237,6 +244,7 @@ static const struct net_device_ops xenvif_netdev_ops = {
 	.ndo_stop	= xenvif_close,
 	.ndo_change_mtu	= xenvif_change_mtu,
 	.ndo_fix_features = xenvif_fix_features,
+	.ndo_poll_controller = xenvif_poll_controller,
 };
 
 struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
-- 
1.7.9.5
