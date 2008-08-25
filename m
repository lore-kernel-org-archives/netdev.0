From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 2/3] enic: add main file with module infrastructure, etc
Date: Mon, 25 Aug 2008 16:06:39 -0700
Message-ID: <adaej4clmo0.fsf@cisco.com>
References: <Pine.LNX.4.64.0808251123240.3972@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:65016 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbYHYXGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 19:06:48 -0400
In-Reply-To: <Pine.LNX.4.64.0808251123240.3972@palito_client100.nuovasystems.com>
	(Scott Feldman's message of "Mon, 25 Aug 2008 11:27:02 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

General comment -- probably a good idea to run everything through
checkpatch.pl (catches a few trivial whitespace problems) and also
sparse with endianness checking (build with "make C=2
CF=-D__CHECK_ENDIAN__ SUBDIRS=drivers/net/enic") and look at all the
warnings you get.

 > +	{ PCI_DEVICE(PCI_VENDOR_ID_CISCO, PCI_DEVICE_ID_CISCO_ENIC) },

PCI_VDEVICE() makes this look slightly nicer.

 > +	netdev->features |= NETIF_F_LLTX;

LLTX is kind of deprecated for new drivers.  Would be nice to avoid this.

 > +	case VNIC_DEV_INTR_MODE_INTX:
 > +	case VNIC_DEV_INTR_MODE_MSI:
 > +		free_irq(enic->pdev->irq, netdev);
 > +		break;
 > +	case VNIC_DEV_INTR_MODE_MSIX:

Do you really need both MSI and MSI-X support?  Systems where MSI works
but MSI-X doesn't a pretty rare, and having both leads to a more complex
driver with one code path (MSI) that rarely gets tested.  I removed MSI
support from drivers/infiniband/hw/mthca at the beginning of the year
afer deprecating it for a while, and I've never heard anyone even
mention it, let alone complain.

 > +	mod_timer(&enic->notify_timer, jiffies + ENIC_NOTIFY_TIMER_PERIOD);

Would probably be nice to use round_jiffies() or a deferrable timer here
to avoid unnecessary wakeups.

 > +	pba = vnic_intr_legacy_pba(enic->legacy_pba);

enic->legacy_pba is just u32 * but vnic_intr_legacy_pba expects an
__iomem pointer.

 > +	if (skb->protocol == ntohs(ETH_P_IP)) {
 > +	} else if (skb->protocol == ntohs(ETH_P_IPV6)) {

trivial but you're converting from host to network order, so you should
use htons() not ntohs().

 > +	unsigned int vlan_tag = 0;
 > +	int vlan_tag_insert = 0;
 > +
 > +	if (enic->vlan_group && vlan_tx_tag_present(skb)) {
 > +		/* VLAN tag from trunking driver */
 > +		vlan_tag_insert = 1;
 > +		vlan_tag = cpu_to_le16(vlan_tx_tag_get(skb));
 > +	}

vlan_tag is declared as a plain int but you assign the result of
cpu_to_le16() to it.  This leads to a sparse warning if you build with
endianness checking on.

 > +	/* check if ip header and tcp header are complete */
 > +	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
 > +		return -1;

Heh, looks like you copied and pasted a bad example from another driver
before I fixed it (in 3ff2cd23, "ehea: Access iph->tot_len with correct
endianness," where I was prescient enough in the changelog to say "this
... avoids having a bad example in the tree.").  iph->tot_len is stored
in network order so you should use ntohs(iph->tot_len).

 > +	u16 q_number, completed_index, bytes_written, vlan, checksum, len;
 > +	len = le16_to_cpu(bytes_written);
 > +			skb->csum = htons(checksum);
 > +					le16_to_cpu(vlan), cq_desc);

bytes_written is declared as u16 but then byte-swapped.  Creates a
sparse warning.  Similar for checksum, vlan.

 > +void enic_del_station_addr(struct enic *enic)
 > +{
 > +	vnic_dev_del_addr(enic->vdev, enic->mac_addr);
 > +}
 > 
 > +int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len)
 > +{
 > +	u64 a0 = (u64)key_pa, a1 = len;
 > +	int wait = 1000;
 > +
 > +	return vnic_dev_cmd(enic->vdev, CMD_RSS_KEY, &a0, &a1, wait);
 > +}
 > +
 > +int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len)
 > +{
 > +	u64 a0 = (u64)cpu_pa, a1 = len;
 > +	int wait = 1000;
 > +
 > +	return vnic_dev_cmd(enic->vdev, CMD_RSS_CPU, &a0, &a1, wait);
 > +}

I can't find anywhere any of these functions are actually used.

