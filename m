From: Pradeep Dalvi <pradeep@linsyssoft.com>
Subject: Re: [PATCH 8/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 14:26:56 +0000
Message-ID: <1148653616.3453.115.camel@arya.linsyssoft.com>
References: <Pine.LNX.4.33.0605250356420.5844-100000@unmsrvr>
	 <20060525100339.40b19371@dxpl.pdx.osdl.net>
Reply-To: pradeep@linsyssoft.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:52590 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1750838AbWEZOnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 10:43:20 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525100339.40b19371@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.16.18/drivers/net/netxen/netxen_nic_main.c
linux-2.6.16.18/drivers/net/netxen/netxen_nic_main.c
--- linux-2.6.16.18/drivers/net/netxen/netxen_nic_main.c
2006-05-25 02:43:22.000000000 -0700
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_main.c
2006-05-26 04:05:34.000000000 -0700
@@ -259,14 +259,12 @@
        pci_read_config_byte(pdev, PCI_REVISION_ID, &adapter-
>ahw.revision_id);
        pci_read_config_word(pdev, PCI_COMMAND, &adapter-
>ahw.pci_cmd_word);

-#if defined(CONFIG_PCI_MSI)
-       adapter->flags |= NETXEN_NIC_MSI_ENABLED;
        if (pci_enable_msi(pdev)) {
                adapter->flags &= ~NETXEN_NIC_MSI_ENABLED;
                printk(KERN_WARNING "%s: unable to allocate MSI
interrupt"
                       " error\n", netxen_nic_driver_name);
-       }
-#endif
+       } else
+               adapter->flags |= NETXEN_NIC_MSI_ENABLED;

        if (is_flash_supported(adapter) == 0 &&
            get_flash_mac_addr(adapter, mac_addr) == 0)
@@ -295,7 +293,6 @@
                port = netdev_priv(netdev);
                port->netdev = netdev;
                port->pdev = pdev;
-               port->hw.port = port;
                port->adapter = adapter;
                port->portnum = i;      /* Gigabit port number starting
from 0-3 */
                port->flags &= ~NETXEN_NETDEV_STATUS;
@@ -329,27 +326,25 @@
                boardno = netxen_nic_get_board_num(adapter);
                if (valid_mac) {
                        unsigned char *p = (unsigned char *)&mac_addr
[i];
-                       port->hw.mac_addr[0] = *(p + 5);
-                       port->hw.mac_addr[1] = *(p + 4);
-                       port->hw.mac_addr[2] = *(p + 3);
-                       port->hw.mac_addr[3] = *(p + 2);
-                       port->hw.mac_addr[4] = *(p + 1);
-                       port->hw.mac_addr[5] = *(p + 0);
-
-                       if (!is_valid_ether_addr(port->hw.mac_addr)) {
-                               printk(KERN_ERR"%s: Bad MAC address"
-                                      "%02x:%02x:%02x:%02x:%02x:%
02x.\n",
+                       netdev->dev_addr[0] = *(p + 5);
+                       netdev->dev_addr[1] = *(p + 4);
+                       netdev->dev_addr[2] = *(p + 3);
+                       netdev->dev_addr[3] = *(p + 2);
+                       netdev->dev_addr[4] = *(p + 1);
+                       netdev->dev_addr[5] = *(p + 0);
+
+                       if (!is_valid_ether_addr(netdev->dev_addr)) {
+                               printk(KERN_ERR
+                                      "%s: Bad MAC address %02x:%02x:%
02x:%02x:%02x:%02x.\n",
                                       netxen_nic_driver_name,
-                                      port->hw.mac_addr[0],
-                                      port->hw.mac_addr[1],
-                                      port->hw.mac_addr[2],
-                                      port->hw.mac_addr[3],
-                                      port->hw.mac_addr[4],
-                                      port->hw.mac_addr[5]);
+                                      netdev->dev_addr[0],
+                                      netdev->dev_addr[1],
+                                      netdev->dev_addr[2],
+                                      netdev->dev_addr[3],
+                                      netdev->dev_addr[4],
+                                      netdev->dev_addr[5]);
                        } else {
-                               memcpy(netdev->dev_addr, port-
>hw.mac_addr,
-                                      netdev->addr_len);
-                               netxen_nic_macaddr_set(port, port-
>hw.mac_addr);
+                               netxen_nic_macaddr_set(port, netdev-
>dev_addr);
                        }
                }
                INIT_WORK(adapter->tx_timeout_task + i,
@@ -629,14 +624,13 @@

        /* Done here again so that even if phantom sw overwrote it,
           we set it */
-       netxen_nic_macaddr_set(port, port->hw.mac_addr);
+       netxen_nic_macaddr_set(port, netdev->dev_addr);
        netxen_nic_set_link_parameters(port);

        netxen_nic_set_multi(netdev);
        if (!adapter->driver_mismatch)
                netif_start_queue(netdev);

-       port->state = NETXEN_PORT_UP;
        return 0;
 }

@@ -728,7 +722,7 @@
                if (((skb->nh.iph)->ihl * sizeof(u32)) +
                    ((skb->h.th)->doff * sizeof(u32)) +
                    sizeof(struct ethhdr) >
-                   (sizeof(struct cmd_desc_type0_t) -
IP_ALIGNMENT_BYTES)) {
+                   (sizeof(struct cmd_desc_type0_t) - NET_IP_ALIGN)) {
                        no_of_desc++;
                }
        }
@@ -852,10 +846,10 @@
                int hdr_len, first_hdr_len, more_hdr;
                hdr_len = hw->cmd_desc_head
[saved_producer].total_hdr_length;
                if (hdr_len >
-                   (sizeof(struct cmd_desc_type0_t) -
IP_ALIGNMENT_BYTES)) {
+                   (sizeof(struct cmd_desc_type0_t) - NET_IP_ALIGN)) {
                        first_hdr_len =
                            sizeof(struct cmd_desc_type0_t) -
-                           IP_ALIGNMENT_BYTES;
+                           NET_IP_ALIGN;
                        more_hdr = 1;
                } else {
                        first_hdr_len = hdr_len;
@@ -865,7 +859,7 @@
                hwdesc = &hw->cmd_desc_head[producer];

                /* copy the first 64 bytes */
-               memcpy(((void *)hwdesc) + IP_ALIGNMENT_BYTES,
+               memcpy(((void *)hwdesc) + NET_IP_ALIGN,
                       (void *)(skb->data), first_hdr_len);
                producer = get_next_index(producer, max_tx_desc_count);


On Thu, 2006-05-25 at 10:03 -0700, Stephen Hemminger wrote:
> The object factoring is a mess here. You have too many allocations
> and indirections. My expectation would be:
> 
> 1. One PCI device maps to one board and that is the adapter structure
>    allocated with kzalloc.  (You are doing this right)
> 
> 2. An adapter can have up to four ports. Each of these should be a
>    netdevice and any port specific memory should be part of netdev_priv().
> 
> 3. Have an array of pointers in the adapter structure for the maximum
>    possible value, if the board has less the memory waste for three
>    extra pointers is less than cost of dynamically sized array.
> 
> Something like
> 
> pci_prvdata -> adapter --> dev[0] -> netdevice { private data }
>                        --> dev[1] ...
> or
> pci_privdata -> adapter -> port[0] -> private data
>                         -> port[1]
> 
> In the later case, you need to have port->netdev pointer back to the
> start of the net_device data structure.
> 
> If you do it this way, you won't need:
> 
> > +	adapter->port = kcalloc(adapter->ahw.max_ports,
> > +				sizeof(struct netxen_adapter), GFP_KERNEL);
> 
> and
> 
> > +		netlist = kzalloc(sizeof(struct netdev_list), GFP_KERNEL);
> > +		if (netlist == NULL)
> > +			goto err_out_free_dev;
> 
> Also, do you really need to have such a big TX ring that it requires
> a vmalloc?
> 
> 
-- 
pradeep

