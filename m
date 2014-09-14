From: Andrew Lunn <andrew@lunn.ch>
Subject: DSA and skb->protocol
Date: Sun, 14 Sep 2014 17:37:51 +0200
Message-ID: <20140914153751.GA28585@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: seugene@marvell.com, Andrew Lunn <lunn@lunn.ch>,
	netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49304 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbaINPoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Sep 2014 11:44:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

I've been debugging a WARNING when using DSA with a D-Link
DIR665. I've had reports of the same warning with another device.

WARNING: CPU: 0 PID: 2014 at net/core/dev.c:2260 skb_warn_bad_offload+0xd0/0x104()
mv643xx_eth_port: caps=(0x0000000400014803, 0x00000000001b482b) len=1722 data_len=16 gso_size=1448 gso_type=1 gso_segs 2 ip_summed=3 encapsulation 0 features 400014801
Modules linked in:
CPU: 0 PID: 2014 Comm: sshd Tainted: G        W      3.17.0-rc1-00007-g2f06b2c08099-dirty #228
[<c000e2a0>] (unwind_backtrace) from [<c000bd88>] (show_stack+0x10/0x14)
[<c000bd88>] (show_stack) from [<c0016db8>] (warn_slowpath_common+0x6c/0x8c)
[<c0016db8>] (warn_slowpath_common) from [<c0016e08>] (warn_slowpath_fmt+0x30/0x40)
[<c0016e08>] (warn_slowpath_fmt) from [<c04ebad4>] (skb_warn_bad_offload+0xd0/0x104)
[<c04ebad4>] (skb_warn_bad_offload) from [<c03eea5c>] (skb_checksum_help+0x160/0x170)
[<c03eea5c>] (skb_checksum_help) from [<c03eef40>] (dev_hard_start_xmit+0x3f8/0x4c0)
[<c03eef40>] (dev_hard_start_xmit) from [<c04071ec>] (sch_direct_xmit+0x148/0x250)
[<c04071ec>] (sch_direct_xmit) from [<c03ef280>] (__dev_queue_xmit+0x278/0x5f4)
[<c03ef280>] (__dev_queue_xmit) from [<c04719b8>] (edsa_xmit+0xf8/0x2c8)
[<c04719b8>] (edsa_xmit) from [<c03eee24>] (dev_hard_start_xmit+0x2dc/0x4c0)
[<c03eee24>] (dev_hard_start_xmit) from [<c03ef3cc>] (__dev_queue_xmit+0x3c4/0x5f4)
[<c03ef3cc>] (__dev_queue_xmit) from [<c0415e88>] (ip_finish_output+0x64c/0x920)
[<c0415e88>] (ip_finish_output) from [<c0416e2c>] (ip_local_out_sk+0x34/0x38)
[<c0416e2c>] (ip_local_out_sk) from [<c0417144>] (ip_queue_xmit+0x128/0x388)
[<c0417144>] (ip_queue_xmit) from [<c042caa8>] (tcp_transmit_skb+0x534/0x93c)
[<c042caa8>] (tcp_transmit_skb) from [<c042cff8>] (tcp_write_xmit+0x148/0xbf8)
[<c042cff8>] (tcp_write_xmit) from [<c042dd7c>] (__tcp_push_pending_frames+0x30/0x9c)
[<c042dd7c>] (__tcp_push_pending_frames) from [<c041fbc8>] (tcp_sendmsg+0xc0/0xcec)
[<c041fbc8>] (tcp_sendmsg) from [<c0445710>] (inet_sendmsg+0x3c/0x70)
[<c0445710>] (inet_sendmsg) from [<c03d7d5c>] (sock_aio_write+0xcc/0xec)
[<c03d7d5c>] (sock_aio_write) from [<c00bb218>] (do_sync_write+0x7c/0xa4)
[<c00bb218>] (do_sync_write) from [<c00bbc40>] (vfs_write+0x108/0x1b0)
[<c00bbc40>] (vfs_write) from [<c00bc214>] (SyS_write+0x40/0x94)
[<c00bc214>] (SyS_write) from [<c0009480>] (ret_fast_syscall+0x0/0x2c)
---[ end trace b1b02d15aba4766a ]---

I think i understand what is going on, and one of your recent patches
may indicate you have seen something similar.

int dev_hard_start_xmit() we have:

2607 
2608                 features = netif_skb_features(skb);

...
2637                         /* If packet is not checksummed and device does not
2638                          * support checksumming for this protocol, complete
2639                          * checksumming here.
2640                          */
2641                         if (skb->ip_summed == CHECKSUM_PARTIAL) {
2642                                 if (skb->encapsulation)
2643                                         skb_set_inner_transport_header(skb,
2644                                                 skb_checksum_start_offset(skb));
2645                                 else
2646                                         skb_set_transport_header(skb,
2647                                                 skb_checksum_start_offset(skb));
2648                                 if (!(features & NETIF_F_ALL_CSUM) &&
2649                                      skb_checksum_help(skb))
2650                                         goto out_kfree_skb;
2651                         }

This packet is CHECKSUM_PARTIAL, but it is also a GSO packet, with two
segments, so the skb_checksum_help() is throwing the warning. It is
expected that the hardware with do the checksum when using GSO. The
reason it is trying to do software checksums, not hardware, is because
features does not indicate the protocol is supported by hardware
checksumming. This i initially thought was odd, since this is a TCP/IP
packet, as you can see from the stack trace. However, 

netif_skb_features(skb) calls harmonize_features() which calls
can_checksum_protocol():

3206 static inline bool can_checksum_protocol(netdev_features_t features,
3207                                          __be16 protocol)
3208 {
3209         return ((features & NETIF_F_GEN_CSUM) ||
3210                 ((features & NETIF_F_V4_CSUM) &&
3211                  protocol == htons(ETH_P_IP)) ||
3212                 ((features & NETIF_F_V6_CSUM) &&
3213                  protocol == htons(ETH_P_IPV6)) ||
3214                 ((features & NETIF_F_FCOE_CRC) &&
3215                  protocol == htons(ETH_P_FCOE)));
3216 }

However looking in the skb, we see protocol is now ETH_P_EDSA, not
ETH_P_IP. Hence the hardware does not support this protocol.

This protocol value is because edsa_xmit() changes it in the slave
device TX path.

Your patch "net: dsa: change tag_protocol to an enum"
has a hunk:

diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index e0b759ec209e..8fbc21c0de78 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -91,7 +91,6 @@ static netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
        /* Queue the SKB for transmission on the parent interface, but
         * do not modify its EtherType
         */
-       skb->protocol = htons(ETH_P_BRCMTAG);
        skb->dev = p->parent->dst->master_netdev;
        dev_queue_xmit(skb);

making me think it is not actually needed to change
skb->protocol. When i remove this from edsa_xmit(), the warning goes
away and networking seems to work O.K.

Is this the right fix? Should we remove this setting of skb->protocol
in the other dsa xmit functions?

Thanks
	Andrew
