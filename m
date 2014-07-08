From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] net/hsr: Use list_head+rcu, better
 frame dispatch, etc.
Date: Tue, 08 Jul 2014 11:45:48 -0700 (PDT)
Message-ID: <20140708.114548.1274719854380242049.davem@davemloft.net>
References: <53B71DB8.1040505@alten.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: arvid.brodin@alten.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbaGHSpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 14:45:49 -0400
In-Reply-To: <53B71DB8.1040505@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@alten.se>
Date: Fri, 4 Jul 2014 23:33:44 +0200

> This patch series is meant to improve the HSR code in several ways:
> 
> * Better code readability.
> * In general, make the code structure more like the net/bridge code (HSR 
>   operates similarly to a bridge, but uses the HSR-specific frame headers to 
>   break up rings, instead of the STP protocol).
> * Better handling of HSR ports' net_device features.
> * Use list_head and the _rcu list traversing routines instead of array of slave 
>   devices.
> * Make it easy to support HSR Interlink devices (for future Redbox/Quadbox 
>   support).
> * Somewhat better throughput on non-HAVE_EFFICIENT_UNALIGNED_ACCESS archs, due 
>   to lesser copying of skb data.
> 
> The code has been tested in a ring together with other HSR nodes running 
> unchanged code, on both avr32 and x86_64. There should only be one minor change 
> in behaviour from a user perspective:
> 
> * Anyone using the Netlink HSR_C_GET_NODE_LIST message to dump the internal 
>   node database will notice that the database now also contains the self node.
> 
> All patches pass 'checkpatch.pl --ignore CAMELCASE --max-line-length=83 
> --strict' with only CHECKs, each of which have been deliberately left in place.
> 
> The final code passes sparse checks with no output.

Series applied, thanks.

Just one question:

@@ -575,6 +579,13 @@ int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2],
 		}
 	}
 
+	for (i = 0; i < HSR_MAX_SLAVE; i++) {
+		res = netdev_rx_handler_register(slave[i], hsr_handle_frame,
+						 hsr);
+		if (res)
+			goto fail;
+	}
+
 	/* Make sure we recognize frames from ourselves in hsr_rcv() */
 	res = hsr_create_self_node(&hsr->self_node_db, hsr_dev->dev_addr,
 				   hsr->slave[1]->dev_addr);

If one of the slaves fails to register it's RX handler here, what unregisters
the slaves which already succeeded?

Thanks.
