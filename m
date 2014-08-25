From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH v2 8/8] qlge: Fix TSO for non-accelerated vlan traffic
Date: Mon, 25 Aug 2014 14:52:22 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4701CC51@avmb2.qlogic.org>
References: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
 <1408977295-9162-9-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
To: Vladislav Yasevich <vyasevich@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:4864 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932958AbaHYOw2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 10:52:28 -0400
In-Reply-To: <1408977295-9162-9-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Vladislav Yasevich [mailto:vyasevich@gmail.com]
> Sent: Monday, August 25, 2014 8:05 PM
> To: netdev
> Cc: Vladislav Yasevich; Shahed Shaikh; zz-930533; Ron Mercer; Dept-Eng Linux
> Driver
> Subject: [PATCH v2 8/8] qlge: Fix TSO for non-accelerated vlan traffic
>
> This device claims TSO support for vlans.  It also allows a user to control vlan
> acceleration offloading.  As such, it is possible to turn off vlan acceleration
> and configure a vlan which will continue to send TSO traffic.
>
> In such situation the packet passed down the the device will contain a vlan
> header and skb->protocol will be set to ETH_P_8021Q.
> The device assumes that skb->protocol contains network protocol value and
> uses that value to set up TSO information.
> This results in corrupted frames sent on the wire.
>
> This patch extracts the protocol value correctly by using a
> vlan_get_protocol() helper and corrects corrupt TSO frames.
>
> CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
> CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> CC: Ron Mercer <ron.mercer@qlogic.com>
> CC: linux-driver@qlogic.com
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks,
Shahed
> ---
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> index 188626e..3e96f26 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> @@ -2556,6 +2556,7 @@ static int ql_tso(struct sk_buff *skb, struct
> ob_mac_tso_iocb_req *mac_iocb_ptr)
>
>       if (skb_is_gso(skb)) {
>               int err;
> +             __be16 l3_proto = vlan_get_protocol(skb);
>
>               err = skb_cow_head(skb, 0);
>               if (err < 0)
> @@ -2572,7 +2573,7 @@ static int ql_tso(struct sk_buff *skb, struct
> ob_mac_tso_iocb_req *mac_iocb_ptr)
>                               << OB_MAC_TRANSPORT_HDR_SHIFT);
>               mac_iocb_ptr->mss = cpu_to_le16(skb_shinfo(skb)-
> >gso_size);
>               mac_iocb_ptr->flags2 |= OB_MAC_TSO_IOCB_LSO;
> -             if (likely(skb->protocol == htons(ETH_P_IP))) {
> +             if (likely(l3_proto == htons(ETH_P_IP))) {
>                       struct iphdr *iph = ip_hdr(skb);
>                       iph->check = 0;
>                       mac_iocb_ptr->flags1 |= OB_MAC_TSO_IOCB_IP4;
> @@ -2580,7 +2581,7 @@ static int ql_tso(struct sk_buff *skb, struct
> ob_mac_tso_iocb_req *mac_iocb_ptr)
>                                                                iph->daddr,
> 0,
>
> IPPROTO_TCP,
>                                                                0);
> -             } else if (skb->protocol == htons(ETH_P_IPV6)) {
> +             } else if (l3_proto == htons(ETH_P_IPV6)) {
>                       mac_iocb_ptr->flags1 |= OB_MAC_TSO_IOCB_IP6;
>                       tcp_hdr(skb)->check =
>                           ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> --
> 1.9.3


________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
