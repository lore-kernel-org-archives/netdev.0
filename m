From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Fri, 22 Oct 2004 15:09:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41798506.1030909@candelatech.com>
References: <41797696.9070905@candelatech.com> <20041022214611.GA4948@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041022214611.GA4948@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Minor nits below.
> 
> [...]
> 
>>@@ -484,13 +484,32 @@
>> 	       veth->h_vlan_proto, veth->h_vlan_TCI, 
>> 	       veth->h_vlan_encapsulated_proto);
>> #endif
>>
>>-	stats->tx_packets++; /* for statics only */
>>-	stats->tx_bytes += skb->len;
>>-
>> 	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
>>-	dev_queue_xmit(skb);
>>
>>-	return 0;
>>+	{
>>+		/* Please note, dev_queue_xmit consumes the pkt regardless of the
>>+		 * error value.  So, will copy the skb first and free if successful.
>>+		 */
>>+		struct sk_buff* skb2 = skb_get(skb);
>>+		int rv = dev_queue_xmit(skb2);
>>+		if (rv != 0) {
>>+			/* The skb memory should still be valid since we made a copy,
>>+			 * so can return error code here.
>>+			 */
>>+			return rv;
>>+		}
>>+		else {
>>+			/* Was success, need to free the skb reference since we bumped up the
>>+			 * user count above.
>>+			 */
>>+
>>+			stats->tx_packets++; /* for statics only */
>>+			stats->tx_bytes += skb->len;
>>+
>>+			kfree_skb(skb);
>>+			return 0;
>>+		}
>>+	}
> 
> 
> 
> Why not use a single return point, say:
> 
> 		struct sk_buff *skb2 = skb_get(skb);
> 		int rv = dev_queue_xmit(skb2);
> 
> 		if (!rv) {
> 			/* 
> 			 * Was success, need to free the skb reference since 
> 			 * we bumped up the user count above.
> 			 */
> 
> 			stats->tx_packets++; /* for statics only */
> 			stats->tx_bytes += skb->len;
> 
> 			kfree_skb(skb);
> 		}
> 		return rv;

That should be OK.  I think I was worried that I would have to further
translate the error codes.  There appears to be no documentation on what
valid return values are for the dev_queue_xmit or the hard_start_xmit
method...  I think someone should add comments to the netdevice.h
file to specify the proper return codes (maybe even return an enum).

In my own code, I have this patch to dev.c.  I think it is correct,
but I could be wrong:

@@ -1253,6 +1272,17 @@
   *	A negative errno code is returned on a failure. A success does not
   *	guarantee the frame will be transmitted as it may be dropped due
   *	to congestion or traffic shaping.
+ *
+ * -----------------------------------------------------------------------------------
+ *      I notice this method can also return errors from the queue disciplines,
+ *      including NET_XMIT_DROP, which is a positive value.  So, errors can also
+ *      be positive.
+ *
+ *      Regardless of the return value, the skb is consumed, so it is currently
+ *      impossible to retry a send to this method.  This implies that virtual devices,
+ *      such as VLANs, can ONLY return 0 from their hard_start_xmit method, making
+ *      it difficult to apply pressure back up the stack.
+ *          --Ben
   */

  int dev_queue_xmit(struct sk_buff *skb)


> vlan_dev_get_realdev_name() and vlan_dev_get_vid() can be tidy up 
> a bit (factoring dev_put() or handling debug code differently for instance).

Agreed, will fix this and the white-space issue.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
