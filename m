From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Thu, 18 Dec 2014 09:39:27 -0800
Message-ID: <17951.1418924367@famine>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com> <1418920017.9773.80.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com,
	Jiri Benc <jbenc@redhat.com>,
	Stefan Assmann <sassmann@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:58789 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaLRRjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:39:36 -0500
In-reply-to: <1418920017.9773.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>On Thu, 2014-12-18 at 15:58 +0530, Govindarajulu Varadarajan wrote:
>> Hardware always provides compliment of IP pseudo checksum. Stack expects
>> whole packet checksum without pseudo checksum if CHECKSUM_COMPLETE is set.
>> 
>> This causes checksum error in nf & ovs.
>> 
>> kernel: qg-19546f09-f2: hw csum failure
>> kernel: CPU: 9 PID: 0 Comm: swapper/9 Tainted: GF          O--------------   3.10.0-123.8.1.el7.x86_64 #1
>> kernel: Hardware name: Cisco Systems Inc UCSB-B200-M3/UCSB-B200-M3, BIOS B200M3.2.2.3.0.080820141339 08/08/2014
>> kernel: ffff881218f40000 df68243feb35e3a8 ffff881237a43ab8 ffffffff815e237b
>> kernel: ffff881237a43ad0 ffffffff814cd4ca ffff8829ec71eb00 ffff881237a43af0
>> kernel: ffffffff814c6232 0000000000000286 ffff8829ec71eb00 ffff881237a43b00
>> kernel: Call Trace:
>> kernel: <IRQ>  [<ffffffff815e237b>] dump_stack+0x19/0x1b
>> kernel: [<ffffffff814cd4ca>] netdev_rx_csum_fault+0x3a/0x40
>> kernel: [<ffffffff814c6232>] __skb_checksum_complete_head+0x62/0x70
>> kernel: [<ffffffff814c6251>] __skb_checksum_complete+0x11/0x20
>> kernel: [<ffffffff8155a20c>] nf_ip_checksum+0xcc/0x100
>> kernel: [<ffffffffa049edc7>] icmp_error+0x1f7/0x35c [nf_conntrack_ipv4]
>> kernel: [<ffffffff814cf419>] ? netif_rx+0xb9/0x1d0
>> kernel: [<ffffffffa040eb7b>] ? internal_dev_recv+0xdb/0x130 [openvswitch]
>> kernel: [<ffffffffa04c8330>] nf_conntrack_in+0xf0/0xa80 [nf_conntrack]
>> kernel: [<ffffffff81509380>] ? inet_del_offload+0x40/0x40
>> kernel: [<ffffffffa049e302>] ipv4_conntrack_in+0x22/0x30 [nf_conntrack_ipv4]
>> kernel: [<ffffffff815005ca>] nf_iterate+0xaa/0xc0
>> kernel: [<ffffffff81509380>] ? inet_del_offload+0x40/0x40
>> kernel: [<ffffffff81500664>] nf_hook_slow+0x84/0x140
>> kernel: [<ffffffff81509380>] ? inet_del_offload+0x40/0x40
>> kernel: [<ffffffff81509dd4>] ip_rcv+0x344/0x380
>> 
>> Hardware verifies IP & tcp/udp header checksum but does not provide payload
>> checksum, use CHECKSUM_UNNECESSARY. Set it only if its valid IP tcp/udp packet.
>> 
>> Cc: Jiri Benc <jbenc@redhat.com>
>> Cc: Stefan Assmann <sassmann@redhat.com>
>> Reported-by: Sunil Choudhary <schoudha@redhat.com>
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>> ---
>>  drivers/net/ethernet/cisco/enic/enic_main.c | 12 ++++++++----
>>  1 file changed, 8 insertions(+), 4 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
>> index 868d0f6..705f334 100644
>> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
>> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
>> @@ -1060,10 +1060,14 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
>>  				     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
>>  		}
>>  
>> -		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
>> -			skb->csum = htons(checksum);
>> -			skb->ip_summed = CHECKSUM_COMPLETE;
>> -		}
>> +		/* Hardware does not provide whole packet checksum. It only
>> +		 * provides pseudo checksum. Since hw validates the packet
>> +		 * checksum but not provide us the checksum value. use
>> +		 * CHECSUM_UNNECESSARY.
>> +		 */
>> +		if ((netdev->features & NETIF_F_RXCSUM) && tcp_udp_csum_ok &&
>> +		    ipv4_csum_ok)
>> +			skb->ip_summed = CHECKSUM_UNNECESSARY;
>>  
>>  		if (vlan_stripped)
>>  			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
>
>Hmm.. this looks like CHECKSUM_COMPLETE could be kept for tunneling
>cases. 
>
>Check commit f8c6455bb04b944e ("net/mlx4_en: Extend checksum offloading
>by CHECKSUM COMPLETE") for a start.

	I've actually been looking into this "hw csum failure" (as it
appears with OVS and VXLAN) the last couple of days, and, at least on
the sky2 hardware I have, the problem doesn't appear to be the
hardware's CHECKSUM_COMPLETE checksumming.  Instead, it appears that
when the encapsulated packet is decapsulated and forwarded to the guest
or container, the checksum isn't updated for the encapsulated ethernet
header.  eth_type_trans does a pull for the ethernet header, but
skb->csum isn't updated.

	I'm testing this patch, and it resolves the problem for me, but
I'm not yet entirely sure whether breaks something else:

diff --git a/net/core/dev.c b/net/core/dev.c
index f411c28..df755e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1694,6 +1694,7 @@ int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 
 	skb_scrub_packet(skb, true);
 	skb->protocol = eth_type_trans(skb, dev);
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
 	return 0;
 }

	I'd very much appreciate comments from someone who knows the
checksum logic better than I do as to whether this is a reasonable thing
to do.

	I've also not tested it on enic hardware.  Govindarajulu, would
you be able to test this against the unmodified enic driver and see if
it resolves the problem for you?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
