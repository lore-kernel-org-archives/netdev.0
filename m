From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 18:54:42 +0300
Message-ID: <480CB8C2.9090902@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030606070702080706060207"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480BE815.2000409-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030606070702080706060207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- Remove multicasting

Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>

--------------030606070702080706060207
Content-Type: text/x-patch;
 name="hso_remove_multicast.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_remove_multicast.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-21 18:41:47.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-21 18:45:43.000000000 +0300
@@ -174,7 +174,6 @@ struct hso_net {
 	struct iphdr rx_ip_hdr;
 	struct ethhdr dummy_eth_head;
 
-	__u16 wNumberMCFilters;
 	unsigned long flags;
 };
 
@@ -870,49 +869,6 @@ static void hso_net_tx_timeout(struct ne
 	odev->stats.tx_errors++;
 }
 
-/* setup the multicast filters */
-static void hso_net_set_multicast(struct net_device *net)
-{
-	struct hso_net *odev = netdev_priv(net);
-	int i = 0;
-	__u8 *buf = NULL;
-
-	/* Tell the kernel to stop sending us frames while we get this all set
-	 * up. */
-	netif_stop_queue(net);
-
-	/* Note: do not reorder, GCC is clever about common statements. */
-	if (net->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		D1("%s: Promiscuous mode enabled", net->name);
-	} else if (net->mc_count > odev->wNumberMCFilters) {
-		/* Too many to filter perfectly -- accept all multicasts. */
-		D1("%s: too many MC filters for hardware, using allmulti",
-		   net->name);
-	} else if (net->flags & IFF_ALLMULTI) {
-		/* Filter in software */
-		D1("%s: using allmulti", net->name);
-	} else {
-		/* do multicast filtering in hardware */
-		struct dev_mc_list *mclist;
-		D1("%s: set multicast filters", net->name);
-		buf = kmalloc(6 * net->mc_count, GFP_ATOMIC);
-		if (!buf) {
-			dev_err(&net->dev, "No memory to allocate?");
-			goto exit;
-		}
-		for (i = 0, mclist = net->mc_list; mclist && i < net->mc_count;
-		     i++, mclist = mclist->next) {
-			memcpy(&mclist->dmi_addr, &buf[i * 6], 6);
-		}
-		kfree(buf);
-	}
-
-exit:
-	/* Tell the kernel to start giving frames to us again. */
-	netif_wake_queue(net);
-}
-
 /* make a real packet from the received USB buffer */
 static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 			unsigned int count, unsigned char is_eop)
@@ -2071,7 +2027,6 @@ static int hso_serial_common_create(stru
 exit:
 	hso_serial_common_free(serial);
 	return -1;
-
 }
 
 /* Frees a general hso device */
@@ -2167,15 +2122,12 @@ static void hso_net_init(struct net_devi
 	net->get_stats = hso_net_get_stats;
 	net->tx_timeout = hso_net_tx_timeout;
 	net->watchdog_timeo = HSO_NET_TX_TIMEOUT;
-	net->set_multicast_list = hso_net_set_multicast;
 	net->flags |= IFF_NOARP;
 	net->mtu = DEFAULT_MTU - 14;
 	net->tx_queue_len = 10;
 	SET_ETHTOOL_OPS(net, &ops);
 	hso_net->skb_rx_buf = NULL;
 	hso_net->rx_parse_state = WAIT_IP;
-	/* always use all multi, no lists of multicasts */
-	hso_net->wNumberMCFilters = 0;
 
 	/* and initialize the semaphore */
 	spin_lock_init(&hso_net->net_lock);
@@ -3084,7 +3036,6 @@ static void __exit hso_exit(void)
 		remove_proc_entry("devices", hso_proc_dir);
 		remove_proc_entry(driver_name, NULL);
 	}
--------------030606070702080706060207--
