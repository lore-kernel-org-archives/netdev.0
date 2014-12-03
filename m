From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv11 net-next 1/2] openvswitch: Refactor ovs_nla_fill_match().
Date: Wed, 3 Dec 2014 11:37:55 -0800
Message-ID: <CALnjE+pNbwtGPsHfTJ0FXxdSpXT=AKgtfHPqT5matCx+PGcXbA@mail.gmail.com>
References: <1417575363-13770-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog017.obsmtp.com ([74.125.150.74]:46674 "HELO
	na6sys009bog017.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750862AbaLCTh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 14:37:56 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so17393603igb.11
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 11:37:55 -0800 (PST)
In-Reply-To: <1417575363-13770-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 2, 2014 at 6:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Refactor the ovs_nla_fill_match() function into separate netlink
> serialization functions ovs_nla_put_{unmasked_key,masked_key,mask}().
> Modify ovs_nla_put_flow() to handle attribute nesting and expose the
> 'is_mask' parameter - all callers need to nest the flow, and callers
> have better knowledge about whether it is serializing a mask or not.
> The next patch will be the first user of ovs_nla_put_masked_key().
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Thanks for the refactoring. code looks better now.
> ---
> v11: Shift netlink serialization of key/mask to flow_netlink.c
>      Add put_{unmasked_key,key,mask} helpers.
>      Perform nesting in ovs_nla_put_flow().
> v10: First post.
> ---
>  net/openvswitch/datapath.c     |   41 ++++++------------------------------
>  net/openvswitch/flow_netlink.c |   45 +++++++++++++++++++++++++++++++++++++---
>  net/openvswitch/flow_netlink.h |    8 +++++--
>  3 files changed, 54 insertions(+), 40 deletions(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 332b5a0..b2a3796 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -462,10 +462,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>                              0, upcall_info->cmd);
>         upcall->dp_ifindex = dp_ifindex;
>
> -       nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
> -       err = ovs_nla_put_flow(key, key, user_skb);
> +       err = ovs_nla_put_flow(key, key, OVS_PACKET_ATTR_KEY, false, user_skb);

We need different name here, since it does not operate on flow. maybe
__ovs_nla_put_key(). we can move the function definition to
flow_netlink.h

>         BUG_ON(err);
> -       nla_nest_end(user_skb, nla);
>
>         if (upcall_info->userdata)
>                 __nla_put(user_skb, OVS_PACKET_ATTR_USERDATA,
> @@ -676,37 +674,6 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
>  }
>
>  /* Called with ovs_mutex or RCU read lock. */
> -static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
> -                                  struct sk_buff *skb)
> -{
> -       struct nlattr *nla;
> -       int err;
> -
> -       /* Fill flow key. */
> -       nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
> -       if (!nla)
> -               return -EMSGSIZE;
> -
> -       err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb);
> -       if (err)
> -               return err;
> -
> -       nla_nest_end(skb, nla);
> -
> -       /* Fill flow mask. */
> -       nla = nla_nest_start(skb, OVS_FLOW_ATTR_MASK);
> -       if (!nla)
> -               return -EMSGSIZE;
> -
> -       err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb);
> -       if (err)
> -               return err;
> -
> -       nla_nest_end(skb, nla);
> -       return 0;
> -}
> -
> -/* Called with ovs_mutex or RCU read lock. */
>  static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
>                                    struct sk_buff *skb)
>  {
> @@ -787,7 +754,11 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
>
>         ovs_header->dp_ifindex = dp_ifindex;
>
> -       err = ovs_flow_cmd_fill_match(flow, skb);
> +       err = ovs_nla_put_unmasked_key(flow, skb);
> +       if (err)
> +               goto error;
> +
> +       err = ovs_nla_put_mask(flow, skb);
>         if (err)
>                 goto error;
>
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index df3c7f2..7bb571f 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -1131,12 +1131,12 @@ int ovs_nla_get_flow_metadata(const struct nlattr *attr,
>         return metadata_from_nlattrs(&match, &attrs, a, false, log);
>  }
>
> -int ovs_nla_put_flow(const struct sw_flow_key *swkey,
> -                    const struct sw_flow_key *output, struct sk_buff *skb)
> +int __ovs_nla_put_flow(const struct sw_flow_key *swkey,
> +                      const struct sw_flow_key *output, bool is_mask,
> +                      struct sk_buff *skb)
>  {
>         struct ovs_key_ethernet *eth_key;
>         struct nlattr *nla, *encap;
> -       bool is_mask = (swkey != output);
>
>         if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
>                 goto nla_put_failure;
> @@ -1346,6 +1346,45 @@ nla_put_failure:
>         return -EMSGSIZE;
>  }
>
> +int ovs_nla_put_flow(const struct sw_flow_key *swkey,
> +                    const struct sw_flow_key *output, int attr, bool is_mask,
> +                    struct sk_buff *skb)
> +{
> +       int err;
> +       struct nlattr *nla;
> +
> +       nla = nla_nest_start(skb, attr);
> +       if (!nla)
> +               return -EMSGSIZE;
> +       err = __ovs_nla_put_flow(swkey, output, is_mask, skb);
> +       if (err)
> +               return err;
> +       nla_nest_end(skb, nla);
> +
> +       return 0;
> +}
> +
> +/* Called with ovs_mutex or RCU read lock. */
> +int ovs_nla_put_unmasked_key(const struct sw_flow *flow, struct sk_buff *skb)
> +{
> +       return ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key,
> +                               OVS_FLOW_ATTR_KEY, false, skb);
> +}
> +
> +/* Called with ovs_mutex or RCU read lock. */
> +int ovs_nla_put_masked_key(const struct sw_flow *flow, struct sk_buff *skb)
> +{
> +       return ovs_nla_put_flow(&flow->mask->key, &flow->key,
> +                               OVS_FLOW_ATTR_KEY, false, skb);
> +}
> +
> +/* Called with ovs_mutex or RCU read lock. */
> +int ovs_nla_put_mask(const struct sw_flow *flow, struct sk_buff *skb)
> +{
> +       return ovs_nla_put_flow(&flow->key, &flow->mask->key,
> +                               OVS_FLOW_ATTR_MASK, true, skb);
> +}
> +
>  #define MAX_ACTIONS_BUFSIZE    (32 * 1024)
>
>  static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
> diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
> index 577f12b..ea54564 100644
> --- a/net/openvswitch/flow_netlink.h
> +++ b/net/openvswitch/flow_netlink.h
> @@ -43,11 +43,15 @@ size_t ovs_key_attr_size(void);
>  void ovs_match_init(struct sw_flow_match *match,
>                     struct sw_flow_key *key, struct sw_flow_mask *mask);
>
> -int ovs_nla_put_flow(const struct sw_flow_key *,
> -                    const struct sw_flow_key *, struct sk_buff *);
> +int ovs_nla_put_flow(const struct sw_flow_key *, const struct sw_flow_key *,
> +                    int attr, bool is_mask, struct sk_buff *);
>  int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *,
>                               bool log);
>
> +int ovs_nla_put_unmasked_key(const struct sw_flow *flow, struct sk_buff *skb);
> +int ovs_nla_put_masked_key(const struct sw_flow *flow, struct sk_buff *skb);
> +int ovs_nla_put_mask(const struct sw_flow *flow, struct sk_buff *skb);
> +
>  int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
>                       const struct nlattr *mask, bool log);
>  int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
> --
> 1.7.10.4
>
