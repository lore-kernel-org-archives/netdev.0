From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Wed, 09 Jan 2013 15:39:31 +0800
Message-ID: <50ED1EB3.3080605@oracle.com>
References: <50EC099D.6020407@oracle.com>  <50EC297A02000078000B3BB5@nat28.tlf.novell.com>  <1357652541.7989.179.camel@zakaz.uk.xensource.com>  <50EC3DFD.8060206@oracle.com> <1357660834.12649.103.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070807060703070303070301"
Cc: xen-devel@lists.xensource.com, Jan Beulich <JBeulich@suse.com>,
	netdev@vger.kernel.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35325 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884Ab3AIHj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 02:39:56 -0500
In-Reply-To: <1357660834.12649.103.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070807060703070303070301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Sorry,
   My attachment is wrong, please check the patch.

On 2013-1-9 0:00, Ian Campbell wrote:
> On Tue, 2013-01-08 at 15:40 +0000, jianhai luan wrote:
>> On 2013-1-8 21:42, Ian Campbell wrote:
>>> On Tue, 2013-01-08 at 13:13 +0000, Jan Beulich wrote:
>>>>>>> On 08.01.13 at 12:57, jianhai luan <jianhai.luan@oracle.com>
>>>>>>> wrote:
>>>>>      When Xen Dom0's network circumstance changed, DomU
>>>>> should be notified in some special condition. For
>>>>> example the below circumstance:
>>>>>      ping from Guest A to DomU:
>>>>>      Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU)
>>>>>                  eth1 /
>>>>>      when eth0 inactive, and eth1 active.
>>> How is eth0 failing? Are you unplugging it, un-enslaving it or
>>> taking
>>> some other sort of administrative action?
>> In my emulation environment, i unplug it or ifdown the interface,
> I expect these would behave rather different, since the affect of ifdown
> looks rather different to an unplug from the PoV of the switch.
>
> Is the ifdown case something which you are trying to solve or just what
> appeared to be a convenient test case? I'd be less inclined to worry
> about explict admin actions such as that.
>
> Unplugging the cable should cause:
>
>>> Doesn't this state change cause the switch to which eth0 and eth1
>>> are
>>> attached to forget the MAC tables associated with the eth0 port,
>>> meaning
>>> that subsequent traffic will be flooded until it learns that eth1 is
>>> the
>>> new port?
> Ian
>
>


--------------070807060703070303070301
Content-Type: text/plain; charset=gb18030;
 name="0001-xen-netback-notify-DomU-to-send-ARP.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-xen-netback-notify-DomU-to-send-ARP.patch"

>From f1235377724b4363cba27ef8b29fb89e2b36189a Mon Sep 17 00:00:00 2001
From: Jason Luan <jianhai.luan@oracle.com>
Date: Fri, 28 Dec 2012 15:43:06 +0800
Subject: [PATCH] xen-netback notify DomU to send ARP.

When Xen Dom0's network circumstance changed, DomU
should be notified in some special condition. For
example the below circumstance:
  ping from Guest A to DomU:
  Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU)
              eth1 /
  when eth0 inactive, and eth1 active.
  Guest A --> eth0   bond0 - xenbr0 --VIF(DOMU)
              eth1 /
  Guest A will don't reach to DomU. After Guest A
  send ARP request and DomU respond, Guest A will
  reach DomU. But some more second will be elapsed.
              eth0   bond0 - xenbr0 --VIF(DOMU)
  Guest A --> eth1/

If Xen netback watch the network change, will notify
DomU by change it own status. So netfront will watch
netback's change, and DomU send ARP initiative.

Signed-off-by: Jason Luan <jianhai.luan@oracle.com>
---
 drivers/net/xen-netback/xenbus.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 410018c..ead1a28 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -26,6 +26,7 @@ struct backend_info {
 	struct xenvif *vif;
 	enum xenbus_state frontend_state;
 	struct xenbus_watch hotplug_status_watch;
+	struct notifier_block vif_notifier;
 	u8 have_hotplug_status_watch:1;
 };
 
@@ -34,11 +35,42 @@ static void connect(struct backend_info *);
 static void backend_create_xenvif(struct backend_info *be);
 static void unregister_hotplug_status_watch(struct backend_info *be);
 
+#define nb_to_backend(nb) container_of(nb, struct backend_info, vif_notifier)
+/**
+ * When network condition of vif change, notify the frontend.
+ */
+static int netback_netdev_event(struct notifier_block *this,
+				unsigned long event, void *ptr)
+{
+	struct net_device *event_dev = (struct net_device *)ptr;
+	struct backend_info *be = nb_to_backend(this);
+
+	pr_debug("event_dev: %s, event: %lx\n",
+		 event_dev ? event_dev->name : "None", event);
+
+	if (!be->vif)
+		goto out;
+
+	switch (event) {
+	case NETDEV_NOTIFY_PEERS:
+		/* Notify frontend to Send gratuitous ARP */
+		xenbus_switch_state(be->dev, XenbusStateInitialised);
+		xenbus_switch_state(be->dev, XenbusStateConnected);
+		break;
+	default:
+		break;
+	}
+
+out:
+	return NOTIFY_DONE;
+}
+
 static int netback_remove(struct xenbus_device *dev)
 {
 	struct backend_info *be = dev_get_drvdata(&dev->dev);
 
 	unregister_hotplug_status_watch(be);
+	unregister_netdevice_notifier(&be->vif_notifier);
 	if (be->vif) {
 		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
 		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
@@ -129,6 +161,10 @@ static int netback_probe(struct xenbus_device *dev,
 	/* This kicks hotplug scripts, so do it immediately. */
 	backend_create_xenvif(be);
 
+	/* Register Frontend Event Notify */
+	(be->vif_notifier).notifier_call = netback_netdev_event;
+	register_netdevice_notifier(&be->vif_notifier);
+
 	return 0;
 
 abort_transaction:
-- 
1.7.6.5


--------------070807060703070303070301--
