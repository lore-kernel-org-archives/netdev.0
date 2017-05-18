From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 2/4] arp: decompose is_garp logic into a separate
 function
Date: Thu, 18 May 2017 23:49:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705182342140.4645@ja.home.ssi.bg>
References: <cover.1495136258.git.ihrachys@redhat.com> <481737abe7a375a7efe125f4e76a998dd670a2df.1495136258.git.ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ihar Hrachyshka <ihrachys@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54362 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S932157AbdERUuc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 16:50:32 -0400
In-Reply-To: <481737abe7a375a7efe125f4e76a998dd670a2df.1495136258.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 18 May 2017, Ihar Hrachyshka wrote:

> The code is quite involving already to earn a separate function for
> itself. If anything, it helps arp_process readability.
> 
> Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
> ---
>  net/ipv4/arp.c | 35 +++++++++++++++++++++++------------
>  1 file changed, 23 insertions(+), 12 deletions(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 053492a..ca6e1e6 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -641,6 +641,27 @@ void arp_xmit(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(arp_xmit);
>  
> +static bool arp_is_garp(struct net_device *dev, int addr_type,
> +			__be16 ar_op,
> +			__be32 sip, __be32 tip,
> +			unsigned char *sha, unsigned char *tha)
> +{
> +	bool is_garp = tip == sip && addr_type == RTN_UNICAST;
> +
> +	/* Gratuitous ARP _replies_ also require target hwaddr to be
> +	 * the same as source.
> +	 */
> +	if (is_garp && ar_op == htons(ARPOP_REPLY))
> +		is_garp =
> +			/* IPv4 over IEEE 1394 doesn't provide target
> +			 * hardware address field in its ARP payload.
> +			 */
> +			tha &&

	All 4 patches look ok to me with only a small problem
which comes from patch already included in kernel. I see
that GARP replies can not work for 1394, is_garp will be
cleared. May be 'tha' check should be moved in if expression,
for example:

	if (is_garp && ar_op == htons(ARPOP_REPLY) && tha)
		is_garp = !memcmp(tha, sha, dev->addr_len);

> +			!memcmp(tha, sha, dev->addr_len);
> +
> +	return is_garp;
> +}

Regards
