From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Mon, 01 Nov 2004 10:58:54 -0800
Message-ID: <4186876E.5040204@candelatech.com>
References: <41797696.9070905@candelatech.com>	 <20041022214611.GA4948@electric-eye.fr.zoreil.com>	 <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>	 <4181838B.6040002@tpack.net>  <41818D99.9020300@candelatech.com> <1099038566.1813.99.camel@cyan.cph.tpack.net> <418281C1.9080707@candelatech.com> <4182D44E.7070507@tpack.net> <4182DABE.7000502@candelatech.com> <4182E0C6.6090205@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4182E0C6.6090205@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


How does this look?  I think it should fix the problem with
having a new skb created in the __vlan_put_tag() method.


int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
	struct net_device_stats *stats = vlan_dev_get_stats(dev);
	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);

	/* Please note, dev_queue_xmit consumes the pkt regardless of the
	 * return value.  So, will copy the skb first and free if successful.
	 */
	struct sk_buff* skb2 = skb_get(skb);

	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
	 *
	 * NOTE: THIS ASSUMES DIX ETHERNET, SPECIFICALLY NOT SUPPORTING
	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
	 */

	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
		int orig_headroom = skb_headroom(skb);
		unsigned short veth_TCI;

		/* This is not a VLAN frame...but we can fix that! */
		VLAN_DEV_INFO(dev)->cnt_encap_on_xmit++;

#ifdef VLAN_DEBUG
		printk(VLAN_DBG "%s: proto to encap: 0x%hx (hbo)\n",
			__FUNCTION__, htons(veth->h_vlan_proto));
#endif
		/* Construct the second two bytes. This field looks something
		 * like:
		 * usr_priority: 3 bits	 (high bits)
		 * CFI		 1 bit
		 * VLAN ID	 12 bits (low bits)
		 */
		veth_TCI = VLAN_DEV_INFO(dev)->vlan_id;
		veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);

		skb = __vlan_put_tag(skb, veth_TCI);
		if (!skb) {
			stats->tx_dropped++;
			/* Free the extra copy, assuming this is a non-recoverable
			 * issue and we don't want calling code to retry.
			 */
			kfree_skb(skb2);
			return 0;
		}

		if (orig_headroom < VLAN_HLEN) {
			VLAN_DEV_INFO(dev)->cnt_inc_headroom_on_tx++;
		}
	}

#ifdef VLAN_DEBUG
	printk(VLAN_DBG "%s: about to send skb: %p to dev: %s\n",
		__FUNCTION__, skb, skb->dev->name);
	printk(VLAN_DBG "  %2hx.%2hx.%2hx.%2xh.%2hx.%2hx %2hx.%2hx.%2hx.%2hx.%2hx.%2hx %4hx %4hx %4hx\n",
	       veth->h_dest[0], veth->h_dest[1], veth->h_dest[2], veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
	       veth->h_source[0], veth->h_source[1], veth->h_source[2], veth->h_source[3], veth->h_source[4], veth->h_source[5],
	       veth->h_vlan_proto, veth->h_vlan_TCI, veth->h_vlan_encapsulated_proto);
#endif

	skb->dev = VLAN_DEV_INFO(dev)->real_dev;

	{
		int rv = dev_queue_xmit(skb);
		if (rv == 0) {
			/* Was success, need to free the skb reference since
			 * we bumped up the user count above.  If there was an
			 * error instead, then the skb2 will not be freed, and so
			 * the calling code will be able to re-send it.
			 */

			stats->tx_packets++; /* for statics only */
			stats->tx_bytes += skb2->len;

			kfree_skb(skb2);
		}
		return rv;
	}
}


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
