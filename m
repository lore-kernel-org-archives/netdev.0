From: Joe Stringer <joe@ovn.org>
Subject: Re: [ovs-dev] [PATCH nf-next v7 6/7] openvswitch: Delay conntrack
 helper call for new connections.
Date: Wed, 17 Feb 2016 16:00:27 -0800
Message-ID: <CAPWQB7FrMyad6D-wGyPQow079uW=uhTAW5azjKVTOV378k-TmA@mail.gmail.com>
References: <1454722865-59558-1-git-send-email-jarno@ovn.org> <1454722865-59558-7-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org, ovs dev <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1454722865-59558-7-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5 February 2016 at 17:41, Jarno Rajahalme <jarno@ovn.org> wrote:
> There is no need to help connections that are not confirmed, so we can
> delay helping new connections to the time when they are confirmed.
> This change is needed for NAT support, and having this as a separate
> patch will make the following NAT patch a bit easier to review.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  net/openvswitch/conntrack.c | 20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index fa9ab25..fc0ef11 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -464,6 +464,7 @@ static bool skb_nfct_cached(struct net *net,
>  /* Pass 'skb' through conntrack in 'net', using zone configured in 'info', if
>   * not done already.  Update key with new CT state after passing the packet
>   * through conntrack.
> + * Note that invalid packets are accepted while the skb->nfct remains unset!
>   */
>  static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
>                            const struct ovs_conntrack_info *info,

This seems unrelated to the patch.

I *think* that you're trying to say that 'if the packet is deemed
invalid by conntrack, skb->nfct will be set to NULL and 0 will be
returned.' I think that this is a documentation issue separate from
this patch (Maybe could be combined with one of the earlier fragments
in the series?).

> @@ -474,7 +475,11 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
>          * actually run the packet through conntrack twice unless it's for a
>          * different zone.
>          */
> -       if (!skb_nfct_cached(net, key, info, skb)) {
> +       bool cached = skb_nfct_cached(net, key, info, skb);
> +       enum ip_conntrack_info ctinfo;
> +       struct nf_conn *ct;
> +
> +       if (!cached) {
>                 struct nf_conn *tmpl = info->ct;
>                 int err;
>
> @@ -497,11 +502,16 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
>                         return -ENOENT;
>
>                 ovs_ct_update_key(skb, info, key, true);
> +       }
>
> -               if (ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
> -                       WARN_ONCE(1, "helper rejected packet");
> -                       return -EINVAL;
> -               }
> +       /* Call the helper right after nf_conntrack_in() for confirmed
> +        * connections, but only when commiting for unconfirmed connections.
> +        */
> +       ct = nf_ct_get(skb, &ctinfo);
> +       if (ct && (nf_ct_is_confirmed(ct) ? !cached : info->commit)
> +           && ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
> +               WARN_ONCE(1, "helper rejected packet");
> +               return -EINVAL;
>         }

The comment points out what I think is the more obvious piece here:
that the helper should be executed when the connection is/will be
committed. The piece that I found less obvious was that "cached"
implies that the helper was already executed (and therefore it
shouldn't be run again). I don't know if there's a way to make this
more obvious, for example with a "helper_executed" variable or
similar. Up to you.
