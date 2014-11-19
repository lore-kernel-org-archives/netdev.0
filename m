From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [patch net-next v3 6/9] vlan: introduce __vlan_insert_tag helper
 which does not free skb
Date: Wed, 19 Nov 2014 00:05:53 -0800
Message-ID: <CALnjE+oX2JJELJNVdO1V2T9jobsgP-+oU-Z7T93Pt6gkhE_cPw@mail.gmail.com>
References: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
	<1416346664-9290-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <cwang@twopensource.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:45273 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755221AbaKSIFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 03:05:53 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so41846iec.38
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 00:05:53 -0800 (PST)
In-Reply-To: <1416346664-9290-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 1:37 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> There's a need for helper which inserts vlan tag but does not free the
> skb in case of an error.
>
> Suggested-by: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  include/linux/if_vlan.h | 45 ++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 34 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 291e670..515a35e 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -282,28 +282,24 @@ static inline bool vlan_hw_offload_capable(netdev_features_t features,
>  }
>
>  /**
> - * vlan_insert_tag - regular VLAN tag inserting
> + * __vlan_insert_tag - regular VLAN tag inserting
>   * @skb: skbuff to tag
>   * @vlan_proto: VLAN encapsulation protocol
>   * @vlan_tci: VLAN TCI to insert
>   *
>   * Inserts the VLAN tag into @skb as part of the payload
> - * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
> - *
> - * Following the skb_unshare() example, in case of error, the calling function
> - * doesn't have to worry about freeing the original skb.
> + * Returns error if skb_cow_head failes.
>   *
>   * Does not change skb->protocol so this function can be used during receive.
>   */
> -static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
> -                                             __be16 vlan_proto, u16 vlan_tci)
> +static inline int __vlan_insert_tag(struct sk_buff *skb,
> +                                   __be16 vlan_proto, u16 vlan_tci)
>  {
>         struct vlan_ethhdr *veth;
>
> -       if (skb_cow_head(skb, VLAN_HLEN) < 0) {
> -               dev_kfree_skb_any(skb);
> -               return NULL;
> -       }
> +       if (skb_cow_head(skb, VLAN_HLEN) < 0)
> +               return -ENOMEM;
> +
>         veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
>
>         /* Move the mac addresses to the beginning of the new header. */
> @@ -316,6 +312,33 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
>         /* now, the TCI */
>         veth->h_vlan_TCI = htons(vlan_tci);
>
> +       return 0;
> +}
> +
> +/**
> + * vlan_insert_tag - regular VLAN tag inserting
> + * @skb: skbuff to tag
> + * @vlan_proto: VLAN encapsulation protocol
> + * @vlan_tci: VLAN TCI to insert
> + *
> + * Inserts the VLAN tag into @skb as part of the payload
> + * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
> + *
> + * Following the skb_unshare() example, in case of error, the calling function
> + * doesn't have to worry about freeing the original skb.
> + *
> + * Does not change skb->protocol so this function can be used during receive.
> + */
> +static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
> +                                             __be16 vlan_proto, u16 vlan_tci)
> +{
> +       int err;
> +
> +       err = __vlan_insert_tag(skb, vlan_proto, vlan_tci);
> +       if (err) {
> +               dev_kfree_skb_any(skb);
> +               return NULL;
> +       }
>         return skb;
>  }
>
> --
> 1.9.3
>
