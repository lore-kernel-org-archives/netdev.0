From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [patch net-next v3 8/9] net: move vlan pop/push functions into
 common code
Date: Wed, 19 Nov 2014 00:06:19 -0800
Message-ID: <CALnjE+rJEtyL-QDrp0x+N_pCxDuR6soHkaY-OrswWrdZwfE2sQ@mail.gmail.com>
References: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
	<1416346664-9290-9-git-send-email-jiri@resnulli.us>
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
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:33808 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755221AbaKSIGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 03:06:20 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so50211ieb.26
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 00:06:19 -0800 (PST)
In-Reply-To: <1416346664-9290-9-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 1:37 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> So it can be used from out of openvswitch code.
> Did couple of cosmetic changes on the way, namely variable naming and
> adding support for 8021AD proto.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>
> v2->v3
> - used previously introduced __vlan_insert_tag helper
> - used skb_push/pull to get skb->data into needed point
> - fixed skb->mac_len computation in skb_vlan_push pointed out by Pravin
> v1->v2:
> - adjusted to fix recent ovs changes
> - included change to use make_writable suggested by Eric
>
>  include/linux/skbuff.h    |  2 +
>  net/core/skbuff.c         | 95 +++++++++++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/actions.c | 88 ++++++-------------------------------------
>  3 files changed, 109 insertions(+), 76 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index e045516..78c299f 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2679,6 +2679,8 @@ unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
>  struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
>  struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
>  int skb_ensure_writable(struct sk_buff *skb, int write_len);
> +int skb_vlan_pop(struct sk_buff *skb);
> +int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
>
>  struct skb_checksum_ops {
>         __wsum (*update)(const void *mem, int len, __wsum wsum);
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d11bbe0..2f72e62 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4163,6 +4163,101 @@ int skb_ensure_writable(struct sk_buff *skb, int write_len)
>  }
>  EXPORT_SYMBOL(skb_ensure_writable);
>
> +/* remove VLAN header from packet and update csum accordingly. */
> +static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
> +{
> +       struct vlan_hdr *vhdr;
> +       unsigned int offset = skb->data - skb_mac_header(skb);
> +       int err;
> +
> +       __skb_push(skb, offset);
> +       err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
> +       if (unlikely(err))
> +               goto pull;
> +
> +       skb_postpull_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
> +
> +       vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
> +       *vlan_tci = ntohs(vhdr->h_vlan_TCI);
> +
> +       memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
> +       __skb_pull(skb, VLAN_HLEN);
> +
> +       vlan_set_encap_proto(skb, vhdr);
> +       skb->mac_header += VLAN_HLEN;
> +
> +       if (skb_network_offset(skb) < ETH_HLEN)
> +               skb_set_network_header(skb, ETH_HLEN);
> +
> +       skb_reset_mac_len(skb);

skb_reset_mac_len() sets length according to ethernet and network
offsets, but mpls expects mac-length to be offset to mpls header (ref.
skb_mpls_header()). Therefore rather than reset we need to subtract
VLAN_HLEN from mac_len. Same goes for vlan-push(), we can add
VLAN_HLEN.

> +pull:
> +       __skb_pull(skb, offset);
> +
> +       return err;
> +}
> +
> +int skb_vlan_pop(struct sk_buff *skb)
> +{
> +       u16 vlan_tci;
> +       __be16 vlan_proto;
> +       int err;
> +
> +       if (likely(vlan_tx_tag_present(skb))) {
> +               skb->vlan_tci = 0;
> +       } else {
> +               if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
> +                             skb->protocol != htons(ETH_P_8021AD)) ||
> +                            skb->len < VLAN_ETH_HLEN))
> +                       return 0;
> +
> +               err = __skb_vlan_pop(skb, &vlan_tci);
> +               if (err)
> +                       return err;
> +       }
> +       /* move next vlan tag to hw accel tag */
> +       if (likely((skb->protocol != htons(ETH_P_8021Q) &&
> +                   skb->protocol != htons(ETH_P_8021AD)) ||
> +                  skb->len < VLAN_ETH_HLEN))
> +               return 0;
> +
> +       vlan_proto = skb->protocol;
> +       err = __skb_vlan_pop(skb, &vlan_tci);
> +       if (unlikely(err))
> +               return err;
> +
> +       __vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
> +       return 0;
> +}
> +EXPORT_SYMBOL(skb_vlan_pop);
> +
> +int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
> +{
> +       if (vlan_tx_tag_present(skb)) {
> +               unsigned int offset = skb->data - skb_mac_header(skb);
> +               int err;
> +
> +               /* __vlan_insert_tag expect skb->data pointing to mac header.
> +                * So change skb->data before calling it and change back to
> +                * original position later
> +                */
> +               __skb_push(skb, offset);
> +               err = __vlan_insert_tag(skb, skb->vlan_proto,
> +                                       vlan_tx_tag_get(skb));
> +               if (err)
> +                       return err;
> +               skb->protocol = skb->vlan_proto;
> +               skb_reset_mac_len(skb);
> +               __skb_pull(skb, offset);
> +
> +               if (skb->ip_summed == CHECKSUM_COMPLETE)
> +                       skb->csum = csum_add(skb->csum, csum_partial(skb->data
> +                                       + (2 * ETH_ALEN), VLAN_HLEN, 0));
> +       }
> +       __vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
> +       return 0;
> +}
> +EXPORT_SYMBOL(skb_vlan_push);
> +
>  /**
>   * alloc_skb_with_frags - allocate skb with page frags
>   *
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 7ffa377..ae7e1b2 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -206,93 +206,27 @@ static int set_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>         return 0;
>  }
>
> -/* remove VLAN header from packet and update csum accordingly. */
> -static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
> -{
> -       struct vlan_hdr *vhdr;
> -       int err;
> -
> -       err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
> -       if (unlikely(err))
> -               return err;
> -
> -       skb_postpull_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
> -
> -       vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
> -       *current_tci = vhdr->h_vlan_TCI;
> -
> -       memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
> -       __skb_pull(skb, VLAN_HLEN);
> -
> -       vlan_set_encap_proto(skb, vhdr);
> -       skb->mac_header += VLAN_HLEN;
> -
> -       if (skb_network_offset(skb) < ETH_HLEN)
> -               skb_set_network_header(skb, ETH_HLEN);
> -
> -       /* Update mac_len for subsequent MPLS actions */
> -       skb_reset_mac_len(skb);
> -       return 0;
> -}
> -
>  static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>  {
> -       __be16 tci;
>         int err;
>
> -       if (likely(vlan_tx_tag_present(skb))) {
> -               skb->vlan_tci = 0;
> -       } else {
> -               if (unlikely(skb->protocol != htons(ETH_P_8021Q) ||
> -                            skb->len < VLAN_ETH_HLEN))
> -                       return 0;
> -
> -               err = __pop_vlan_tci(skb, &tci);
> -               if (err)
> -                       return err;
> -       }
> -       /* move next vlan tag to hw accel tag */
> -       if (likely(skb->protocol != htons(ETH_P_8021Q) ||
> -                  skb->len < VLAN_ETH_HLEN)) {
> +       err = skb_vlan_pop(skb);
> +       if (vlan_tx_tag_present(skb))
> +               invalidate_flow_key(key);
> +       else
>                 key->eth.tci = 0;
> -               return 0;
> -       }
> -
> -       invalidate_flow_key(key);
> -       err = __pop_vlan_tci(skb, &tci);
> -       if (unlikely(err))
> -               return err;
> -
> -       __vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(tci));
> -       return 0;
> +       return err;
>  }
>
>  static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
>                      const struct ovs_action_push_vlan *vlan)
>  {
> -       if (unlikely(vlan_tx_tag_present(skb))) {
> -               u16 current_tag;
> -
> -               /* push down current VLAN tag */
> -               current_tag = vlan_tx_tag_get(skb);
> -
> -               skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
> -                                               current_tag);
> -               if (!skb)
> -                       return -ENOMEM;
> -               /* Update mac_len for subsequent MPLS actions */
> -               skb->mac_len += VLAN_HLEN;
> -
> -               if (skb->ip_summed == CHECKSUM_COMPLETE)
> -                       skb->csum = csum_add(skb->csum, csum_partial(skb->data
> -                                       + (2 * ETH_ALEN), VLAN_HLEN, 0));
> -
> +       if (vlan_tx_tag_present(skb))
>                 invalidate_flow_key(key);
> -       } else {
> +       else
>                 key->eth.tci = vlan->vlan_tci;
> -       }
> -       __vlan_hwaccel_put_tag(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
> -       return 0;
> +       return skb_vlan_push(skb, vlan->vlan_tpid,
> +                            ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
>  }
>
>  static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *key,
> @@ -858,8 +792,10 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>
>                 case OVS_ACTION_ATTR_PUSH_VLAN:
>                         err = push_vlan(skb, key, nla_data(a));
> -                       if (unlikely(err)) /* skb already freed. */
> +                       if (unlikely(err)) {
> +                               dev_kfree_skb_any(skb);
>                                 return err;
> +                       }
There is no need to check for error. Just break is sufficient. Error
checking is done after switch case.
>                         break;
>
>                 case OVS_ACTION_ATTR_POP_VLAN:
> --
> 1.9.3
>
