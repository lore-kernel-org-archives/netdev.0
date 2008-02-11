From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Mon, 11 Feb 2008 08:47:09 -0800
Message-ID: <1202748429.8276.21.camel@nimitz.home.sr71.net>
References: <200802111724.12416.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	"Themann, Jan-Bernd" <themann@de.ibm.com>,
	Greg KH <greg@kroah.com>, Christoph Raisch <RAISCH@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, apw <apw@uk.ibm.com>,
	Badari Pulavarty <pbadari@us.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:57799 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757105AbYBKQrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 11:47:11 -0500
In-Reply-To: <200802111724.12416.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-11 at 17:24 +0100, Jan-Bernd Themann wrote:
>  the eHEA patch belongs to a patchset that is usually
>  added by Jeff Garzik once this dependency (EXPORTS)
>  is resolved.

I know that's already in mainline but, man, that code is nasty.  It has
stuff indented 7 levels or so and is virtually impossible to read.

This:

> int ehea_create_busmap(void)
> {
>         u64 vaddr = EHEA_BUSMAP_START;
>         unsigned long high_section_index = 0;
>         int i;
> 
>         /*
>          * Sections are not in ascending order -> Loop over all sections and
>          * find the highest PFN to compute the required map size.
>         */
>         ehea_bmap.valid_sections = 0;
> 
>         for (i = 0; i < NR_MEM_SECTIONS; i++)
>                 if (valid_section_nr(i))
>                         high_section_index = i;

is also completely bogus for arch-independent code.  If someone ever
wants to do ppc without sparsemem (or redoes internal sparsemem
interfaces), this code will break.  

Also, keeping your own mapping of all of memory is really nasty.  With
SPARSEMEM_EXTREME/VMEMMAP you can have extremely sparse physical memory,
and this:

>         ehea_bmap.entries = high_section_index + 1;
>         ehea_bmap.vaddr = vmalloc(ehea_bmap.entries * sizeof(*ehea_bmap.vaddr));

could theoretically consume all of memory if the sections are very sparse.

Could you please try to explain what the heck this driver is doing?
We'll try to fix up the generic interfaces so that you can deal with
things in a more generic fashion, but it can't stay this way.

Also, just ripping down and completely re-doing the entire mass of cards
every time a 16MB area of memory is added or removed seems like an
awfully big sledgehammer to me.  I would *HATE* to see anybody else
using this driver as an example to work off of?  Can't you just keep
track of which areas the driver is actually *USING* and only worry about
changing mappings if that intersects with an area having hotplug done on
it?

Can you please give it some CodingStyle love and make it so that it
doesn't indent so much?  Something like this:

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c051c7e..72c5652 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2638,38 +2638,40 @@ static void ehea_rereg_mrs(struct work_struct *work)
 	down(&dlpar_mem_lock);
 	ehea_info("LPAR memory enlarged - re-initializing driver");
 
-	list_for_each_entry(adapter, &adapter_list, list)
-		if (adapter->active_ports) {
-			/* Shutdown all ports */
-			for (i = 0; i < EHEA_MAX_PORTS; i++) {
-				struct ehea_port *port = adapter->port[i];
-
-				if (port) {
-					struct net_device *dev = port->netdev;
-
-					if (dev->flags & IFF_UP) {
-						down(&port->port_lock);
-						netif_stop_queue(dev);
-						ret = ehea_stop_qps(dev);
-						if (ret) {
-							up(&port->port_lock);
-							goto out;
-						}
-						port_napi_disable(port);
-						up(&port->port_lock);
-					}
-				}
-			}
-
-			/* Unregister old memory region */
-			ret = ehea_rem_mr(&adapter->mr);
+	list_for_each_entry(adapter, &adapter_list, list) {
+		if (!adapter->active_ports)
+			continue;
+		/* Shutdown all ports */
+		for (i = 0; i < EHEA_MAX_PORTS; i++) {
+			struct ehea_port *port = adapter->port[i];
+			struct net_device *dev;
+			if (!port)
+				continue;
+
+			dev = port->netdev;
+			if (!(dev->flags & IFF_UP))
+				continue;
+
+			down(&port->port_lock);
+			netif_stop_queue(dev);
+			ret = ehea_stop_qps(dev);
 			if (ret) {
-				ehea_error("unregister MR failed - driver"
-					   " inoperable!");
+				up(&port->port_lock);
 				goto out;
 			}
+			port_napi_disable(port);
+			up(&port->port_lock);
 		}
 
+		/* Unregister old memory region */
+		ret = ehea_rem_mr(&adapter->mr);
+		if (ret) {
+			ehea_error("unregister MR failed - driver"
+				   " inoperable!");
+			goto out;
+		}
+	}
+
 	ehea_destroy_busmap();
 	ret = ehea_create_busmap();
 	if (ret) {


-- Dave

