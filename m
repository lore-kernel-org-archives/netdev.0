From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V17 3/3] 802.1AD: Flow handling, actions, vlan
 parsing and netlink attributes
Date: Mon, 19 Oct 2015 11:28:05 -0700
Message-ID: <CALnjE+p1NdBmSZiGoNHw1C_u+D7s1o=7U68WHpx=5t+PQB=92g@mail.gmail.com>
References: <1445130748-27671-1-git-send-email-thomasfherbert@gmail.com>
	<1445130748-27671-4-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36326 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbbJSS2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 14:28:06 -0400
Received: by ioll68 with SMTP id l68so43368140iol.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 11:28:06 -0700 (PDT)
In-Reply-To: <1445130748-27671-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 17, 2015 at 6:12 PM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans. Add support for 802.1ad to netlink parsing and flow
> conversion. Uses double nested encap attributes to represent double
> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/actions.c      |   6 +-
>  net/openvswitch/flow.c         |  76 +++++++++++++-----
>  net/openvswitch/flow.h         |   8 +-
>  net/openvswitch/flow_netlink.c | 172 +++++++++++++++++++++++++++++++++++++----
>  net/openvswitch/vport-netdev.c |   4 +-
>  5 files changed, 227 insertions(+), 39 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 315f533..09cc1c9 100644
...

> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c92d6a2..97a6d12 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
...

> @@ -1320,6 +1443,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>  {
>         struct ovs_key_ethernet *eth_key;
>         struct nlattr *nla, *encap;
> +       struct nlattr *in_encap = NULL;
>
>         if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
>                 goto nla_put_failure;
> @@ -1368,17 +1492,29 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>         ether_addr_copy(eth_key->eth_src, output->eth.src);
>         ether_addr_copy(eth_key->eth_dst, output->eth.dst);
>
> -       if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
> -               __be16 eth_type;
> -               eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
> -               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> -                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
> +       if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
> +                                output->eth.vlan.tpid) ||
> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.vlan.tci))
>                         goto nla_put_failure;
>                 encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> -               if (!swkey->eth.tci)
> +               if (!swkey->eth.vlan.tci)
>                         goto unencap;
> -       } else
> +               if (swkey->eth.cvlan.tci) {
> +                       /* Customer tci is nested but uses same key attribute.
> +                        */
> +                       if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
> +                                        output->eth.cvlan.tpid) ||
> +                           nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
> +                                        output->eth.cvlan.tci))
> +                               goto nla_put_failure;
> +                       in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> +                       if (!swkey->eth.cvlan.tci)
> +                               goto unencap;
> +               }
> +       } else {
>                 encap = NULL;
> +       }
After the vlan parsing changes, we need to encode cvlan in outer
netlink attribute and then encode regular vlan. Currently we are
reversing netlink encoding while sending back the vlan attributes.
cvlan and vlan is independent, therefore we need to check
swkey->eth.cvlan.tc outside of swkey->eth.vlan.tci block. Also
redundant check for swkey->eth.cvlan.tci should be removed.

Can you also post changes for userspace vswitchd so that I can try next patch.
