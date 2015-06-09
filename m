From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V10 4/4] 8021AD: Flow key parsing and netlink attributes.
Date: Mon, 8 Jun 2015 20:45:30 -0700
Message-ID: <CALnjE+ocDvv3q4Jx0rc8TCk2TmJkK3cU5EBnZ14T6HSteU1JXQ@mail.gmail.com>
References: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
	<1433267444-26025-5-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:44502 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932101AbbFIDpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 23:45:32 -0400
Received: by iesa3 with SMTP id a3so6437955ies.2
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 20:45:31 -0700 (PDT)
In-Reply-To: <1433267444-26025-5-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 10:50 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad to netlink parsing and flow conversation. Uses
> double nested encap attributes to represent double tagged vlan.
>
This patch needs to be merged with earlier patch since it is part of
qinq support.

> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/flow_netlink.c | 186 ++++++++++++++++++++++++++++++++++-------
>  1 file changed, 157 insertions(+), 29 deletions(-)
>
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c691b1a..8fd4f63 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -771,6 +771,28 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
...
>                 err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
> @@ -1331,6 +1439,25 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>                 encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>                 if (!swkey->eth.tci)
>                         goto unencap;
> +       } else if (swkey->eth.ctci || swkey->eth.type == htons(ETH_P_8021AD)) {
> +               __be16 eth_type;
> +
> +               eth_type = !is_mask ? htons(ETH_P_8021AD) : htons(0xffff);
> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
> +                       goto nla_put_failure;
> +               encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> +               if (!swkey->eth.tci)
> +                       goto unencap;
> +               /* Customer tci is nested but uses same key attribute.
> +                */
> +               eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.ctci))
> +                       goto nla_put_failure;
> +               encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> +               if (!swkey->eth.ctci)
> +                       goto unencap;
>         } else
>                 encap = NULL;
>
For qinq we need to keep track of two encap attributes to finalize
nesting of attributes.
