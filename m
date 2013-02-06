From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 6 Feb 2013 13:43:21 +0200
Message-ID: <20130206114321.GA13497@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: alexander.h.duyck@intel.com, stephen.s.ko@intel.com,
	jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951Ab3BFLjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 06:39:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that starting with kernel 3.3 ixgbe sets gso_size for
incoming frames. It seems that this might result in gso_size
being set even when gso_type is 0.
This in turn leads to a crash at macvtap_skb_to_vnet_hdr
drivers/net/macvtap.c:628
which has this code:

       if (skb_is_gso(skb)) {
                struct skb_shared_info *sinfo = skb_shinfo(skb);

                /* This is a hint as to how much should be linear. */
                vnet_hdr->hdr_len = skb_headlen(skb);
                vnet_hdr->gso_size = sinfo->gso_size;
                if (sinfo->gso_type & SKB_GSO_TCPV4)
                        vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
                else if (sinfo->gso_type & SKB_GSO_TCPV6)
                        vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
                else if (sinfo->gso_type & SKB_GSO_UDP)
                        vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
                else
                        BUG();
                if (sinfo->gso_type & SKB_GSO_TCP_ECN)
                        vnet_hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
        } else
                vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;


Since skb_is_gso tests gso_size.

What's the right way to handle this? Should skb_is_gso be
changed to test gso_type != 0?

-- 
MST
