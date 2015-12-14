From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 1/2] vlan: Fix untag operations of stacked vlans with
 REORDER_HEADER off
Date: Mon, 14 Dec 2015 15:51:30 +0100
Message-ID: <566ED772.8070600@6wind.com>
References: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
 <1447706625-25979-2-git-send-email-vyasevic@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: phil@nwl.cc, kaber@trash.net,
	Vladislav Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33094 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbbLNOvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 09:51:33 -0500
Received: by mail-wm0-f53.google.com with SMTP id n186so49473475wmn.0
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 06:51:32 -0800 (PST)
In-Reply-To: <1447706625-25979-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/11/2015 21:43, Vladislav Yasevich a =C3=A9crit :
> When we have multiple stacked vlan devices all of which have
> turned off REORDER_HEADER flag, the untag operation does not
> locate the ethernet addresses correctly for nested vlans.
> The reason is that in case of REORDER_HEADER flag being off,
> the outer vlan headers are put back and the mac_len is adjusted
> to account for the presense of the header.  Then, the subsequent
> untag operation, for the next level vlan, always use VLAN_ETH_HLEN
> to locate the begining of the ethernet header and that ends up
> being a multiple of 4 bytes short of the actuall beginning
> of the mac header (the multiple depending on the how many vlan
> encapsulations ethere are).
>
> As a reslult, if there are multiple levles of vlan devices
> with REODER_HEADER being off, the recevied packets end up
> being dropped.
>
> To solve this, we use skb->mac_len as the offset.  The value
> is always set on receive path and starts out as a ETH_HLEN.
> The value is also updated when the vlan header manupations occur
> so we know it will be correct.
>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>   net/core/skbuff.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index fab4599..160193f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4268,7 +4268,8 @@ static struct sk_buff *skb_reorder_vlan_header(=
struct sk_buff *skb)
>   		return NULL;
>   	}
>
> -	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_AL=
EN);
> +	memmove(skb->data - ETH_HLEN, skb->data - skb->mac_len,
> +		2 * ETH_ALEN);
>   	skb->mac_header +=3D VLAN_HLEN;
>   	return skb;
>   }
>
This patch breaks the following test case: a vlan packet is received by=
 an
e1000 interface. Here is the configuration of the interface:
$ ethtool -k ntfp2 | grep "vlan\|offload"
tcp-segmentation-offload: off
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off
tx-vlan-offload: off [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]

The vlan header is not removed by the driver. It calls dev_gro_receive(=
) which
sets the network header to +14, thus mac_len is also sets to 14 and
skb_reorder_vlan_header() do a wrong memmove() (the packet is dropped).
Not sure who is responsible to update mac_len before skb_vlan_untag() i=
s
called. Any suggestions?
