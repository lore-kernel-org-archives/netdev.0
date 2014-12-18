From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Thu, 18 Dec 2014 16:58:00 +0300
Message-ID: <5492DD68.1070401@cogentembedded.com>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@redhat.com>, Stefan Assmann <sassmann@redhat.com>
To: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:48173 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbaLRN6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 08:58:04 -0500
Received: by mail-lb0-f177.google.com with SMTP id b6so975026lbj.22
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 05:58:03 -0800 (PST)
In-Reply-To: <1418898522-13588-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/18/2014 1:28 PM, Govindarajulu Varadarajan wrote:

> Hardware always provides compliment of IP pseudo checksum. Stack expects
> whole packet checksum without pseudo checksum if CHECKSUM_COMPLETE is set.

> This causes checksum error in nf & ovs.

> kernel: qg-19546f09-f2: hw csum failure
> kernel: CPU: 9 PID: 0 Comm: swapper/9 Tainted: GF          O--------------   3.10.0-123.8.1.el7.x86_64 #1
> kernel: Hardware name: Cisco Systems Inc UCSB-B200-M3/UCSB-B200-M3, BIOS B200M3.2.2.3.0.080820141339 08/08/2014
> kernel: ffff881218f40000 df68243feb35e3a8 ffff881237a43ab8 ffffffff815e237b
> kernel: ffff881237a43ad0 ffffffff814cd4ca ffff8829ec71eb00 ffff881237a43af0
> kernel: ffffffff814c6232 0000000000000286 ffff8829ec71eb00 ffff881237a43b00
> kernel: Call Trace:
> kernel: <IRQ>  [<ffffffff815e237b>] dump_stack+0x19/0x1b
> kernel: [<ffffffff814cd4ca>] netdev_rx_csum_fault+0x3a/0x40
> kernel: [<ffffffff814c6232>] __skb_checksum_complete_head+0x62/0x70
> kernel: [<ffffffff814c6251>] __skb_checksum_complete+0x11/0x20
> kernel: [<ffffffff8155a20c>] nf_ip_checksum+0xcc/0x100
> kernel: [<ffffffffa049edc7>] icmp_error+0x1f7/0x35c [nf_conntrack_ipv4]
> kernel: [<ffffffff814cf419>] ? netif_rx+0xb9/0x1d0
> kernel: [<ffffffffa040eb7b>] ? internal_dev_recv+0xdb/0x130 [openvswitch]
> kernel: [<ffffffffa04c8330>] nf_conntrack_in+0xf0/0xa80 [nf_conntrack]
> kernel: [<ffffffff81509380>] ? inet_del_offload+0x40/0x40
> kernel: [<ffffffffa049e302>] ipv4_conntrack_in+0x22/0x30 [nf_conntrack_ipv4]
> kernel: [<ffffffff815005ca>] nf_iterate+0xaa/0xc0
> kernel: [<ffffffff81509380>] ? inet_del_offload+0x40/0x40
> kernel: [<ffffffff81500664>] nf_hook_slow+0x84/0x140
> kernel: [<ffffffff81509380>] ? inet_del_offload+0x40/0x40
> kernel: [<ffffffff81509dd4>] ip_rcv+0x344/0x380

> Hardware verifies IP & tcp/udp header checksum but does not provide payload
> checksum, use CHECKSUM_UNNECESSARY. Set it only if its valid IP tcp/udp packet.

> Cc: Jiri Benc <jbenc@redhat.com>
> Cc: Stefan Assmann <sassmann@redhat.com>
> Reported-by: Sunil Choudhary <schoudha@redhat.com>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>   drivers/net/ethernet/cisco/enic/enic_main.c | 12 ++++++++----
>   1 file changed, 8 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 868d0f6..705f334 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -1060,10 +1060,14 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
>   				     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
>   		}
>
> -		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
> -			skb->csum = htons(checksum);
> -			skb->ip_summed = CHECKSUM_COMPLETE;
> -		}
> +		/* Hardware does not provide whole packet checksum. It only
> +		 * provides pseudo checksum. Since hw validates the packet
> +		 * checksum but not provide us the checksum value. use

    s/not/doesn't/, s/value./value,/.

[...]

WBR, Sergei
