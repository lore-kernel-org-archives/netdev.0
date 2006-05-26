From: Pradeep Dalvi <pradeep@linsyssoft.com>
Subject: Re: [PATCH 2/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 14:16:35 +0000
Message-ID: <1148652995.3453.102.camel@arya.linsyssoft.com>
References: <Pine.LNX.4.33.0605250349110.5844-100000@unmsrvr>
	 <20060525094221.18c79b3a@dxpl.pdx.osdl.net>
Reply-To: pradeep@linsyssoft.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:58728 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1750735AbWEZOc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 10:32:59 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525094221.18c79b3a@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following are the minor changes for [PATCH 2/9] in accordance with the
given suggestions.

Regards,
pradeep

diff -u linux-2.6.16.18/drivers/net/netxen/netxen_nic.h
linux-2.6.16.18/drivers/net/netxen/netxen_nic.h
--- linux-2.6.16.18/drivers/net/netxen/netxen_nic.h     2006-05-25
02:43:22.000000000 -0700
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic.h     2006-05-26
04:05:34.000000000 -0700
@@ -98,12 +98,11 @@
        (void *)(ptrdiff_t)(adapter->ahw.pci_base+ (reg)        \
        - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST)

-#define IP_ALIGNMENT_BYTES             2 /* make ip aligned on 16 bytes
addr */
 #define MAX_RX_BUFFER_LENGTH           2000
 #define MAX_RX_JUMBO_BUFFER_LENGTH     9046
-#define RX_DMA_MAP_LEN                 (MAX_RX_BUFFER_LENGTH -
IP_ALIGNMENT_BYTES)
+#define RX_DMA_MAP_LEN                 (MAX_RX_BUFFER_LENGTH -
NET_IP_ALIGN)
 #define RX_JUMBO_DMA_MAP_LEN   \
-       (MAX_RX_JUMBO_BUFFER_LENGTH - IP_ALIGNMENT_BYTES)
+       (MAX_RX_JUMBO_BUFFER_LENGTH - NET_IP_ALIGN)

 /* Opcodes to be used with the commands */
 #define        TX_ETHER_PKT 0x01
@@ -608,7 +607,7 @@
        struct netxen_board_info boardcfg;
        u32 xg_linkup;
        struct netxen_adapter *adapter;
-       struct cmd_desc_type0_t *cmd_desc_head; /* Address of cmd ring
in Phantom */
+       struct cmd_desc_type0_t *cmd_desc_head;
        u32 cmd_producer;
        u32 cmd_consumer;
        u32 rcv_flag;
@@ -695,8 +694,6 @@
        struct work_struct watchdog_task;
        struct work_struct tx_timeout_task[4];
        struct timer_list watchdog_timer;
-       struct tasklet_struct tx_tasklet;
-       struct tasklet_struct rx_tasklet;

        u32 curr_window;

@@ -742,20 +739,6 @@
        struct net_device *netdev;
 };

-struct netxen_port_hw {
-       unsigned char mac_addr[MAX_ADDR_LEN];
-       int mtu;
-       struct pci_dev *pdev;
-       struct netxen_port *port;
-};
-
-/* Following structure is for specific port information    */
-
-#define        NETXEN_PORT_UP                  0
-#define        NETXEN_PORT_DOWN                1
-#define        NETXEN_PORT_INITIALIAZED        2
-#define        NETXEN_PORT_SUSPEND             3
-
 /* Max number of xmit producer threads that can run simultaneously */
 #define        MAX_XMIT_PRODUCERS              16

@@ -785,11 +768,9 @@
 struct netxen_port {
        struct netxen_adapter *adapter;

-       struct netxen_port_hw hw;       /* port hardware structure */
        u16 portnum;            /* GBE port number */
        u16 link_speed;
        u16 link_duplex;
-       u16 state;              /* state of the port */
        u16 link_autoneg;

        int flags;


On Thu, 2006-05-25 at 09:42 -0700, Stephen Hemminger wrote:
> On Thu, 25 May 2006 03:51:03 -0700 (PDT)
> "Linsys Contractor Amit S. Kale" <amitkale@unminc.com> wrote:
> 
> > diff -Naru linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic.h linux-2.6.16.18/drivers/net/netxen/netxen_nic.h
> > --- linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic.h	1969-12-31 16:00:00.000000000 -0800
> > +++ linux-2.6.16.18/drivers/net/netxen/netxen_nic.h	2006-05-25 02:43:22.000000000 -0700
> > @@ -0,0 +1,950 @@
> >
> > +#define IP_ALIGNMENT_BYTES		2 /* make ip aligned on 16 bytes addr */
> 
> Please use NET_IP_ALIGN, it does the right architecture dependent
> offset.
> 
> ...
> > +#define NETXEN_PCI_ID(X) { PCI_DEVICE(PCI_VENDOR_ID_NX, (X)) }
> 
> Nested macro's on macro's, just use PCI_DEVICE()
> 
> > +
> > +#define PFX "netxen: "
> > +
> > +/* Note: Make sure to not call this before adapter->port is valid */
> > +#if !defined(NETXEN_DEBUG)
> > +#define DPRINTK(klevel, fmt, args...)	do { \
> > +	} while (0)
> > +#else
> > +#define DPRINTK(klevel, fmt, args...)	do { \
> > +	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
> > +		(adapter != NULL && adapter->port != NULL && \
> > +		adapter->port[0] != NULL && \
> > +		adapter->port[0]->netdev != NULL) ? \
> > +		adapter->port[0]->netdev->name : NULL, \
> > +		## args); } while(0)
> > +#endif
> > +
> 
> Ugh. Macro with magic variable.  if you need to keep this, pass adapter.
> 
> 
> > +struct netdev_list {
> > +	struct netdev_list *next;
> > +	struct net_device *netdev;
> > +};
> 
> Why not use regular list.h or simple linked list.  Even better
> figure out how to not need need "list of devices at all"
> 
> > +struct netxen_port_hw {
> > +	unsigned char mac_addr[MAX_ADDR_LEN];
> > +	int mtu;
> > +	struct pci_dev *pdev;
> > +	struct netxen_port *port;
> > +};
> 
> Isn't mtu redundant with dev->mtu and mac_addr redundant
> with dev->dev_addr
> 
> 
> > +/* Following structure is for specific port information    */
> > +
> > +#define	NETXEN_PORT_UP			0
> > +#define	NETXEN_PORT_DOWN		1
> > +#define	NETXEN_PORT_INITIALIAZED	2
> > +#define	NETXEN_PORT_SUSPEND		3
> 
> Don't mirror port state with netdevice state because you risk
> getting the two out of sync. Isn't this redundant with
> netif_running()
> 
> 
> 
-- 
pradeep

