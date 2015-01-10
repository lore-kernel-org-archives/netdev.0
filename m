From: Sriharsha Basavapatna <Sriharsha.Basavapatna@Emulex.Com>
Subject: [Question] vxlan_features_check()
Date: Sat, 10 Jan 2015 06:52:22 +0000
Message-ID: <31318D46B5DF3F4AB71CC057601E9FEB12BFBC57@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>, Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:17604 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbbAJGwy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 01:52:54 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse, Tom,

The current implementation of vxlan_features_check() disables csum/gso flags
for only a subset of Non-VxLAN tunnels - those with tunnel outer transport type
of UDP. Is there any reason why this was not done for non-UDP tunnels like
GRE too ? This can avoid additional code in the driver ndo_features_check()
to disable those flags for non-UDP tunnels.  Please let me know if I'm
missing something here.

The current code in vxlan_features_check() is this:
        if ((l4_hdr == IPPROTO_UDP) &&
            (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
             skb->inner_protocol != htons(ETH_P_TEB) ||
             (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
              sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
                return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);

That should change to:
        if (l4_hdr != IPPROTO_UDP ||
            skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
            skb->inner_protocol != htons(ETH_P_TEB) ||
            (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
            sizeof(struct udphdr) + sizeof(struct vxlanhdr)))
                return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);

Thanks,
-Harsha
