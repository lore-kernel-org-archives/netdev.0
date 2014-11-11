From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 1/2] net: move vlan pop/push functions into
 common code
Date: Tue, 11 Nov 2014 05:06:21 -0800
Message-ID: <1415711181.9613.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	pshelar@nicira.com, therbert@google.com, edumazet@google.com,
	willemb@google.com, dborkman@redhat.com, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, tgraf@suug.ch
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36111 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbaKKNGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:06:24 -0500
Received: by mail-ie0-f171.google.com with SMTP id x19so11288952ier.2
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 05:06:24 -0800 (PST)
In-Reply-To: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-11 at 11:13 +0100, Jiri Pirko wrote:
> So it can be used from out of openvswitch code.
> Did couple of cosmetic changes on the way, namely variable naming and
> adding support for 8021AD proto.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/skbuff.h    |  2 ++
>  net/core/skbuff.c         | 86 +++++++++++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/actions.c | 76 ++---------------------------------------
>  3 files changed, 90 insertions(+), 74 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 103fbe8..3b0445c 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2673,6 +2673,8 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet);
>  unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
>  struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
>  struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
> +int skb_vlan_pop(struct sk_buff *skb);
> +int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
>  
>  struct skb_checksum_ops {
>  	__wsum (*update)(const void *mem, int len, __wsum wsum);
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 7001896..75e53d4 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4151,6 +4151,92 @@ err_free:
>  }
>  EXPORT_SYMBOL(skb_vlan_untag);
>  
> +/* remove VLAN header from packet and update csum accordingly. */
> +static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
> +{
> +	struct vlan_hdr *vhdr;
> +	int err;
> +



> +	if (!pskb_may_pull(skb, VLAN_ETH_HLEN))
> +		return -ENOMEM;
> +
> +	if (!skb_cloned(skb) || skb_clone_writable(skb, VLAN_ETH_HLEN))
> +		return 0;
> +
> +	err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
> +	if (unlikely(err))
> +		return err;

All this should be a function of its own (OVS calls this
make_writable()).

Its too bad netfilter has a different skb_make_writable()


> +
> +	if (skb->ip_summed == CHECKSUM_COMPLETE)
> +		skb->csum = csum_sub(skb->csum, csum_partial(skb->data
> +					+ (2 * ETH_ALEN), VLAN_HLEN, 0));

This looks like skb_postpull_rcsum()

BTW, calling csum_partial() for 4 bytes is quite expensive.
