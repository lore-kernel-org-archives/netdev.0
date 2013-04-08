From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] Move execute_set_action to lib/odp-util.c
Date: Mon, 8 Apr 2013 13:29:52 -0700
Message-ID: <CAEP_g=_JYu0m4G01osWCaMhu6ESdiryMQYvikfpuNNYj6dNn_A@mail.gmail.com>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
	<1365403431-18102-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1365403431-18102-3-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> Move execute_set_action from lib/dpif-netedev.c to lib/odp-util.c
>
> This is in preparation for using execute_set_action()
> in lib/odp-util.c to handle recirculation/
>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
>
> ---
>
> packet.c might be a better place for execute_set_action()
> but I'm unsure if accessing struct ovs_key_ethernet would
> lead to a layering violation.

I'd be tempted to just put this in it's own file.  As you say, it
doesn't really fit in either of the two existing ones.

> diff --git a/lib/odp-util.c b/lib/odp-util.c
> index e18e109..ad5873c 100644
> --- a/lib/odp-util.c
> +++ b/lib/odp-util.c
> @@ -2420,3 +2420,79 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
>      commit_set_priority_action(flow, base, odp_actions);
>      commit_set_skb_mark_action(flow, base, odp_actions);
>  }
> +
> +static void
> +dp_netdev_set_dl(struct ofpbuf *packet, const struct ovs_key_ethernet *eth_key)

I think this function should be given a more generic name and possibly
moved to packet.c.

> +void
> +execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
> +                   uint32_t *skb_mark)
> +{
> +    enum ovs_key_attr type = nl_attr_type(a);
> +    const struct ovs_key_ipv4 *ipv4_key;
> +    const struct ovs_key_ipv6 *ipv6_key;
> +    const struct ovs_key_tcp *tcp_key;
> +    const struct ovs_key_udp *udp_key;
> +
> +    switch (type) {
> +    case OVS_KEY_ATTR_PRIORITY:
> +    case OVS_KEY_ATTR_TUNNEL:
> +        /* not implemented */
> +        break;

Don't we need to carry this information along as well similar to skb->mark?

Also, is there a reason to not have the code for push/pop actions here as well?
