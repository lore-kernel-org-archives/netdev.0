From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Wed, 09 Jan 2013 10:06:05 +0000
Message-ID: <50ED4F1D02000078000B3F87@nat28.tlf.novell.com>
References: <50EC099D.6020407@oracle.com>
 <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
 <1357652541.7989.179.camel@zakaz.uk.xensource.com>
 <50EC3DFD.8060206@oracle.com>
 <1357660834.12649.103.camel@dagon.hellion.org.uk>
 <50ED1EB3.3080605@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <Ian.Campbell@citrix.com>,
	<xen-devel@lists.xensource.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "jianhai luan" <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:53081 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757528Ab3AIKGH convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Wed, 9 Jan 2013 05:06:07 -0500
In-Reply-To: <50ED1EB3.3080605@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 09.01.13 at 08:39, jianhai luan <jianhai.luan@oracle.com> wrote:
>@@ -34,11 +35,42 @@ static void connect(struct backend_info *);
> static void backend_create_xenvif(struct backend_info *be);
> static void unregister_hotplug_status_watch(struct backend_info *be);
> 
>+#define nb_to_backend(nb) container_of(nb, struct backend_info, vif_notifier)
>+/**
>+ * When network condition of vif change, notify the frontend.
>+ */
>+static int netback_netdev_event(struct notifier_block *this,
>+				unsigned long event, void *ptr)
>+{
>+	struct net_device *event_dev = (struct net_device *)ptr;

Pointless cast.

>+	struct backend_info *be = nb_to_backend(this);
>+
>+	pr_debug("event_dev: %s, event: %lx\n",
>+		 event_dev ? event_dev->name : "None", event);
>+
>+	if (!be->vif)
>+		goto out;
>+
>+	switch (event) {
>+	case NETDEV_NOTIFY_PEERS:
>+		/* Notify frontend to Send gratuitous ARP */
>+		xenbus_switch_state(be->dev, XenbusStateInitialised);
>+		xenbus_switch_state(be->dev, XenbusStateConnected);

This is the sort of change that clearly isn't acceptable, as I don't
think you have ways to check _all_ existing frontends for their
compatibility with this. A connected -> connected transition
might be acceptable (that was done in the block frontend too, for
implementing dynamic resize), but will likely need to be
accompanied by a frontend side patch to handle that (which so
far should be a no-op).

>+		break;
>+	default:
>+		break;

Pointless default case.

>+	}
>+
>+out:

I don't think you really need the label (and the goto above) - just
put a return there.

>+	return NOTIFY_DONE;
>+}
>+
> static int netback_remove(struct xenbus_device *dev)
> {
> 	struct backend_info *be = dev_get_drvdata(&dev->dev);
> 
> 	unregister_hotplug_status_watch(be);
>+	unregister_netdevice_notifier(&be->vif_notifier);
> 	if (be->vif) {
> 		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
> 		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
>@@ -129,6 +161,10 @@ static int netback_probe(struct xenbus_device *dev,
> 	/* This kicks hotplug scripts, so do it immediately. */
> 	backend_create_xenvif(be);
> 
>+	/* Register Frontend Event Notify */
>+	(be->vif_notifier).notifier_call = netback_netdev_event;

Pointless parentheses.

Jan

>+	register_netdevice_notifier(&be->vif_notifier);
>+
> 	return 0;
> 
> abort_transaction:
