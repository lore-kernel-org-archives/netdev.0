From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Wed, 09 Jan 2013 20:28:05 +0800
Message-ID: <50ED6255.7020006@oracle.com>
References: <50EC099D.6020407@oracle.com> <50EC297A02000078000B3BB5@nat28.tlf.novell.com> <1357652541.7989.179.camel@zakaz.uk.xensource.com> <50EC3DFD.8060206@oracle.com> <1357660834.12649.103.camel@dagon.hellion.org.uk> <50ED1EB3.3080605@oracle.com> <50ED4F1D02000078000B3F87@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090002070100000502000305"
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	Jan Beulich <JBeulich@suse.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26424 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757608Ab3AIM21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 07:28:27 -0500
In-Reply-To: <50ED4F1D02000078000B3F87@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090002070100000502000305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


On 2013-1-9 18:06, Jan Beulich wrote:
>>>> On 09.01.13 at 08:39, jianhai luan <jianhai.luan@oracle.com> wrote:
>> @@ -34,11 +35,42 @@ static void connect(struct backend_info *);
>> static void backend_create_xenvif(struct backend_info *be);
>> static void unregister_hotplug_status_watch(struct backend_info *be);
>>
>> +#define nb_to_backend(nb) container_of(nb, struct backend_info, vif_notifier)
>> +/**
>> + * When network condition of vif change, notify the frontend.
>> + */
>> +static int netback_netdev_event(struct notifier_block *this,
>> +				unsigned long event, void *ptr)
>> +{
>> +	struct net_device *event_dev = (struct net_device *)ptr;
> Pointless cast.
>
>> +	struct backend_info *be = nb_to_backend(this);
>> +
>> +	pr_debug("event_dev: %s, event: %lx\n",
>> +		 event_dev ? event_dev->name : "None", event);
>> +
>> +	if (!be->vif)
>> +		goto out;
>> +
>> +	switch (event) {
>> +	case NETDEV_NOTIFY_PEERS:
>> +		/* Notify frontend to Send gratuitous ARP */
>> +		xenbus_switch_state(be->dev, XenbusStateInitialised);
>> +		xenbus_switch_state(be->dev, );
> This is the sort of change that clearly isn't acceptable, as I don't
> think you have ways to check _all_ existing frontends for their
> compatibility with this. A connected -> connected transition
> might be acceptable (that was done in the block frontend too, for
> implementing dynamic resize), but will likely need to be
> accompanied by a frontend side patch to handle that (which so
> far should be a no-op).
The latest xen net-frontent driver have handled the condition. State 
XenbusStateInitialised will do nothing,
but change to XenbusStateConnected will trigger 
netdev_notify_peers(netdev) to send ARP.
>
>> +		break;
>> +	default:
>> +		break;
> Pointless default case.
>
>> +	}
>> +
>> +out:
> I don't think you really need the label (and the goto above) - just
> put a return there.
>
>> +	return NOTIFY_DONE;
>> +}
>> +
>> static int netback_remove(struct xenbus_device *dev)
>> {
>> 	struct backend_info *be = dev_get_drvdata(&dev->dev);
>>
>> 	unregister_hotplug_status_watch(be);
>> +	unregister_netdevice_notifier(&be->vif_notifier);
>> 	if (be->vif) {
>> 		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
>> 		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
>> @@ -129,6 +161,10 @@ static int netback_probe(struct xenbus_device *dev,
>> 	/* This kicks hotplug scripts, so do it immediately. */
>> 	backend_create_xenvif(be);
>>
>> +	/*   Event Notify */
>> +	(be->vif_notifier).notifier_call = netback_netdev_event;
> Pointless parentheses.
>
> Jan
>
>> +	register_netdevice_notifier(&be->vif_notifier);
>> +
>> 	return 0;
>>
>> abort_transaction:
>


--------------090002070100000502000305
Content-Type: text/plain; charset=gb18030;
 name="0001-xen-netback-notify-DomU-to-send-ARP.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-xen-netback-notify-DomU-to-send-ARP.patch"

>From a64d80cc0c780bee7a8d6e842126cb5f7d17f0d2 Mon Sep 17 00:00:00 2001
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
 drivers/net/xen-netback/xenbus.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 410018c..17a3990 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -26,6 +26,7 @@ struct backend_info {
 	struct xenvif *vif;
 	enum xenbus_state frontend_state;
 	struct xenbus_watch hotplug_status_watch;
+	struct notifier_block vif_notifier;
 	u8 have_hotplug_status_watch:1;
 };
 
@@ -34,11 +35,39 @@ static void connect(struct backend_info *);
 static void backend_create_xenvif(struct backend_info *be);
 static void unregister_hotplug_status_watch(struct backend_info *be);
 
+#define nb_to_backend(nb) container_of(nb, struct backend_info, vif_notifier)
+/**
+ * When network condition of vif change, notify the frontend.
+ */
+static int netback_netdev_event(struct notifier_block *this,
+				unsigned long event, void *ptr)
+{
+	struct net_device *event_dev = ptr;
+	struct backend_info *be = nb_to_backend(this);
+
+	pr_debug("event_dev: %s, event: %lx\n",
+		 event_dev ? event_dev->name : "None", event);
+
+	if (!be->vif)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_NOTIFY_PEERS:
+		/* Notify frontend to Send gratuitous ARP */
+		xenbus_switch_state(be->dev, XenbusStateInitialised);
+		xenbus_switch_state(be->dev, XenbusStateConnected);
+		break;
+	}
+
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
@@ -129,6 +158,10 @@ static int netback_probe(struct xenbus_device *dev,
 	/* This kicks hotplug scripts, so do it immediately. */
 	backend_create_xenvif(be);
 
+	/* Register Frontend Event Notify */
+	be->vif_notifier.notifier_call = netback_netdev_event;
+	register_netdevice_notifier(&be->vif_notifier);
+
 	return 0;
 
 abort_transaction:
-- 
1.7.6.5


--------------090002070100000502000305--
