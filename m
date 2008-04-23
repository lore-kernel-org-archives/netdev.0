From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Wed, 23 Apr 2008 16:40:17 +0300
Message-ID: <480F3C41.10908@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt> <480DA2CA.8090705@teltonika.lt> <480DED38.3080900@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050008060805020505090302"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480DED38.3080900-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050008060805020505090302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- converted network interface from ethernet to PtP
- some includes cleanup
- fixed false gcc warning about using uninitialized
   variable. Introduced by previous patch.

Signed-of-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>

--------------050008060805020505090302
Content-Type: text/x-patch;
 name="hso_not_eth.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_not_eth.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-22 16:37:31.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-23 16:24:30.000000000 +0300
@@ -47,8 +47,6 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
-#include <linux/inetdevice.h>
-#include <linux/etherdevice.h>
 #include <linux/module.h>
 #include <linux/ethtool.h>
 #include <linux/usb.h>
@@ -171,7 +169,6 @@ struct hso_net {
 	unsigned short rx_buf_size;
 	unsigned short rx_buf_missing;
 	struct iphdr rx_ip_hdr;
-	struct ethhdr dummy_eth_head;
 
 	unsigned long flags;
 };
@@ -294,19 +291,6 @@ static int hso_get_activity(struct hso_d
 /* Helping functions                                                         */
 /*****************************************************************************/
 
-/* convert a character representing a hex value to a number */
-static unsigned char hex2dec(unsigned char digit)
-{
-	if ((digit >= '0') && (digit <= '9'))
-		return (digit - '0');
-	/* Map all characters to 0-15 */
-	if ((digit >= 'a') && (digit <= 'z'))
-		return (digit - 'a' + 10) % 16;
-	if ((digit >= 'A') && (digit <= 'Z'))
-		return (digit - 'A' + 10) % 16;
-	return 0;
-}
-
 /* #define DEBUG */
 
 #define dev2net(x) (x->port_data.dev_net)
@@ -790,8 +774,6 @@ static int hso_net_start_xmit(struct sk_
 		return 0;
 	}
 
-	/* fetch the packet */
-	skb_pull(skb, ETH_HLEN);
 	/* log if asked */
 	DUMP1(skb->data, skb->len);
 	/* Copy it from kernel memory to OUR memory */
@@ -870,7 +852,6 @@ static void packetizeRx(struct hso_net *
 	unsigned short buffer_offset = 0;
 	unsigned short frame_len;
 	unsigned char *tmp_rx_buf;
-	struct ethhdr *eth_head;
 
 	/* log if needed */
 	D1("Rx %d bytes", count);
@@ -909,9 +890,7 @@ static void packetizeRx(struct hso_net *
 					continue;
 				}
 				/* Allocate an sk_buff */
-				odev->skb_rx_buf = dev_alloc_skb(
-					frame_len + 2 +
-					odev->net->hard_header_len);
+				odev->skb_rx_buf = dev_alloc_skb(frame_len);
 				if (!odev->skb_rx_buf) {
 					/* We got no receive buffer. */
 					D1("could not allocate memory");
@@ -921,11 +900,6 @@ static void packetizeRx(struct hso_net *
 				/* Here's where it came from */
 				odev->skb_rx_buf->dev = odev->net;
 
-				/* Make some headroom: standard alignment + the
-				 * ethernet header. */
-				skb_reserve(odev->skb_rx_buf,
-					    2 + odev->net->hard_header_len);
-
 				/* Copy what we got so far. make room for iphdr
 				 * after tail. */
 				tmp_rx_buf =
@@ -935,9 +909,7 @@ static void packetizeRx(struct hso_net *
 				       sizeof(struct iphdr));
 
 				/* ETH_HLEN */
-				odev->rx_buf_size =
-				    odev->net->hard_header_len +
-				    sizeof(struct iphdr);
+				odev->rx_buf_size = sizeof(struct iphdr);
 
 				/* Filip actually use .tot_len */
 				odev->rx_buf_missing =
@@ -962,22 +934,15 @@ static void packetizeRx(struct hso_net *
 			odev->rx_buf_size += temp_bytes;
 			if (!odev->rx_buf_missing) {
 				/* Packet is complete. Inject into stack. */
-				/* Add fake ethernet header. */
-				eth_head = (struct ethhdr *)skb_push(odev->
-							      skb_rx_buf,
-							      odev->
-							      net->
-							      hard_header_len);
-				memcpy(eth_head, &odev->dummy_eth_head,
-				       sizeof(struct ethhdr));
-
-				/* Not sure here either */
-				odev->skb_rx_buf->protocol = eth_type_trans(
-							odev->skb_rx_buf,
-							odev->net);
+				/* We have IP packet here */
+				odev->skb_rx_buf->protocol =
+						__constant_htons(ETH_P_IP);
 				/* don't check it */
 				odev->skb_rx_buf->ip_summed =
 					CHECKSUM_UNNECESSARY;
+
+				skb_reset_mac_header(odev->skb_rx_buf);
+
 				/* Ship it off to the kernel */
 				netif_rx(odev->skb_rx_buf);
 				/* No longer our buffer. */
@@ -986,8 +951,6 @@ static void packetizeRx(struct hso_net *
 				/* update out statistics */
 				odev->net->stats.rx_packets++;
 
-				/* Hmmm, wonder if we have received the IP len
-				 * or the ETH len. */
 				odev->net->stats.rx_bytes += odev->rx_buf_size;
 
 				odev->rx_buf_size = 0;
@@ -2103,70 +2066,22 @@ static void hso_net_init(struct net_devi
 
 	D1("sizeof hso_net is %d", (int)sizeof(*hso_net));
 
-	/* most of the setup is done by standard function */
-	ether_setup(net);
-
 	/* fill in the other fields */
 	net->open = hso_net_open;
 	net->stop = hso_net_close;
 	net->hard_start_xmit = hso_net_start_xmit;
 	net->tx_timeout = hso_net_tx_timeout;
 	net->watchdog_timeo = HSO_NET_TX_TIMEOUT;
-	net->flags |= IFF_NOARP;
+	net->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+	net->type = ARPHRD_NONE;
 	net->mtu = DEFAULT_MTU - 14;
 	net->tx_queue_len = 10;
 	SET_ETHTOOL_OPS(net, &ops);
-	hso_net->skb_rx_buf = NULL;
-	hso_net->rx_parse_state = WAIT_IP;
 
 	/* and initialize the semaphore */
 	spin_lock_init(&hso_net->net_lock);
 }
 
-/* setting the mac-address of the newly created iface */
-static void set_ethernet_addr(struct hso_net *odev)
-{
-	unsigned char mac_addr[6];
-	unsigned char dummy_mac[6];
-	int i, len;
-	unsigned char buffer[13];
-
-	/* we can't fail, therefor we use a random macaddress */
-	random_ether_addr(mac_addr);
-	dummy_mac[0] = 0xFA;
-	dummy_mac[1] = mac_addr[1];
-	dummy_mac[2] = mac_addr[2];
-	dummy_mac[3] = mac_addr[3];
-	dummy_mac[4] = mac_addr[4];
-	dummy_mac[5] = mac_addr[5];
-
-	/* but we like consistency, that's why we try to use the serial number
-	 * as a macaddress if available */
-	len = usb_string(odev->parent->usb,
-			 odev->parent->usb->descriptor.iSerialNumber,
-			 buffer, 13);
-	if (len != 12 && strcmp("Serial", buffer)) {
-		/* Fill in the mac_addr */
-		for (i = 0; i < 6; i++) {
-			mac_addr[i] = (hex2dec(buffer[2 * i]) << 4) +
-				       hex2dec(buffer[2 * i + 1]);
-		}
-		mac_addr[0] &= 0xfe;	/* clear multicast bit */
-		mac_addr[0] |= 0x02;	/* set local assignment bit (IEEE802) */
-	} else {
-		dev_err(&odev->parent->usb->dev, "Attempting to get MAC "
-			"address failed: using random\n");
-	}
-
-	/* Now copy it over to our network device structure */
-	memcpy(odev->net->dev_addr, mac_addr, sizeof(mac_addr));
-
-	/* Create the default fake ethernet header. */
-	memcpy(odev->dummy_eth_head.h_dest, mac_addr, ETH_ALEN);
-	memcpy(odev->dummy_eth_head.h_source, dummy_mac, ETH_ALEN);
-	odev->dummy_eth_head.h_proto = htons(ETH_P_IP);
-}
-
 /* Adds a network device in the network device table */
 static int add_net_device(struct hso_device *hso_dev)
 {
@@ -2255,9 +2170,6 @@ static struct hso_device *hso_create_net
 		goto exit;
 	}
 
-	/* and don't forget the MAC address. */
-	set_ethernet_addr(hso_net);
--------------050008060805020505090302--
