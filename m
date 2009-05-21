From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d"
	as interface name
Date: Thu, 21 May 2009 15:48:57 +0200
Message-ID: <20090521134856.GA3457@psychotron.englab.brq.redhat.com>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux1394-devel@lists.sourceforge.net,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Fenlason <fenlason@redhat.com>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <tkrat.21c425cc195510c9@s5r6.in-berlin.de>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, May 21, 2009 at 03:29:10PM CEST, stefanr@s5r6.in-berlin.de wrote:
>Change the initial name of IP-over-1394 networking interfaces from
>"eth[0-9]+" to "firewire[0-9]+".
>
>This should have been done years ago for the reason mentioned in the
>inline comment.  The naming issue basically prevented acceptance of
>IP networking over 1394 on Linux.
>
>The future IP-over1394 driver in the newer alternative firewire driver
>stack will use the "firewire%d" format from the start while "eth%d" will
>no longer be used in the new driver.
>
>Necessary changes in userland:
>
>People who use the eth1394 driver either have to update their network
>configuration (or instead perhaps respecpective udev interface renaming
>rules) to the new names, or add
>
>    options eth1394 firewire_interface_name=N
>
>to /etc/modprobe.conf or /etc/modprobe.d/whatever if they really prefer
>the old names.
>
>Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
>---
> drivers/ieee1394/eth1394.c |   23 ++++++++++++++++++++++-
> 1 file changed, 22 insertions(+), 1 deletion(-)
>
>Index: linux/drivers/ieee1394/eth1394.c
>===================================================================
>--- linux.orig/drivers/ieee1394/eth1394.c
>+++ linux/drivers/ieee1394/eth1394.c
>@@ -146,6 +146,25 @@ MODULE_DESCRIPTION("IEEE 1394 IPv4 Drive
> MODULE_LICENSE("GPL");
> 
> /*
>+ * Legacy option:  Choose between "eth%d" (old) and "firewire%d" (new, default)
>+ * as name template of eth1304's networking interfaces.
>+ *
>+ * eth1394 used to set "eth[0-9]+" as the initial name of an IP-over-1394
>+ * networking interface.  This caused trouble for users and admins since
>+ * it is indistinguishable from Ethernet drivers' interfaces.
>+ *
>+ * From Linux 2.6.31 on, "eth[0-9]+" remains only an option which can be
>+ * activated by setting the following module parameter to N.  The default
>+ * name format is "firewire[0-9]+" now.  This way, people will immediately
>+ * recognize what kind of networking interface this is, and no mix-ups
>+ * with Ethernet interface configurations will happen anymore.
>+ */
>+static int firewire_interface_name = 1;
>+module_param(firewire_interface_name, bool, S_IRUGO | S_IWUSR);
>+MODULE_PARM_DESC(firewire_interface_name, "use 'firewire' (= Y, default) or "
>+		 "'eth' (= N, legacy option) as name prefix of interfaces");
>+
>+/*
>  * The max_partial_datagrams parameter is the maximum number of fragmented
>  * datagrams per node that eth1394 will keep in memory.  Providing an upper
>  * bound allows us to limit the amount of memory that partial datagrams
>@@ -595,7 +614,9 @@ static void ether1394_add_host(struct hp
> 		return;
> 	}
> 
>-	dev = alloc_netdev(sizeof(*priv), "eth%d", ether1394_init_dev);
>+	dev = alloc_netdev(sizeof(*priv),
>+			   firewire_interface_name ? "firewire%d" : "eth%d",

Isn't "firewire" too long? Wouldn't it be better to use some addrev like other
devices do? "fw"? To safe some time and possible troubles with typos.

Just a thought.

		Jirka

>+			   ether1394_init_dev);
> 	if (dev == NULL) {
> 		ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
> 		goto out;
>
>-- 
>Stefan Richter
>-=====-==--= -=-= =-=-=
>http://arcgraph.de/sr/
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
