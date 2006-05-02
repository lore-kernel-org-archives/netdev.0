From: Ben Greear <greearb@candelatech.com>
Subject: Question on e1000 patch, rx-copy-break related.
Date: Tue, 02 May 2006 12:56:26 -0700
Message-ID: <4457B96A.4030808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:11905 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751246AbWEBT43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 15:56:29 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit:  a292ca6efbc1f259ddfb9c902367f2588e0e8b0f
to e1000_main.c, there is the change below.

I am curious why the skb_put no longer subtracts ETHERNET_FCS_SIZE
from the length.  Is the idea that we will now always include the
FCS at the end of the skb?

It also seems that the skb_put for the else clause is missing here, but
I think it is fixed in some later patch.

The main reason I ask is that I have a patch that enabled reception of the
FCS in 2.6.13.  It used a flag to determine whether to subtract the ETHERNET_FCS_SIZE
from length (or not, if we are capturing FCS).  I am trying to figure out if this
is still needed in the later releases.

Thanks,
Ben

@@ -3613,17 +3618,40 @@ #endif
  			}
  		}

-		/* Good Receive */
-		skb_put(skb, length - ETHERNET_FCS_SIZE);
+		/* code added for copybreak, this should improve
+		 * performance for small packets with large amounts
+		 * of reassembly being done in the stack */
+#define E1000_CB_LENGTH 256
+		if ((length < E1000_CB_LENGTH) &&
+		   !rx_ring->rx_skb_top &&
+		   /* or maybe (status & E1000_RXD_STAT_EOP) && */
+		   !multi_descriptor) {
+			struct sk_buff *new_skb =
+			    dev_alloc_skb(length + NET_IP_ALIGN);
+			if (new_skb) {
+				skb_reserve(new_skb, NET_IP_ALIGN);
+				new_skb->dev = netdev;
+				memcpy(new_skb->data - NET_IP_ALIGN,
+				       skb->data - NET_IP_ALIGN,
+				       length + NET_IP_ALIGN);
+				/* save the skb in buffer_info as good */
+				buffer_info->skb = skb;
+				skb = new_skb;
+				skb_put(skb, length);
+			}
+		}
+
+		/* end copybreak code */



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

