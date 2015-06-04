From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V10 3/4] 802.1AD: Flow handling, actions and vlan parsing
Date: Thu, 4 Jun 2015 10:45:15 -0700
Message-ID: <CALnjE+p8tuUFoXOFvfrp154rb80o_8XhtJ+Z8RrL1Y67kw12jw@mail.gmail.com>
References: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
	<1433267444-26025-4-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:45540 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752691AbbFDRpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 13:45:16 -0400
Received: by mail-ig0-f176.google.com with SMTP id pi8so143536236igb.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 10:45:15 -0700 (PDT)
In-Reply-To: <1433267444-26025-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 10:50 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/flow.c | 82 ++++++++++++++++++++++++++++++++++++++++++--------
>  net/openvswitch/flow.h |  3 ++
>  2 files changed, 73 insertions(+), 12 deletions(-)
>
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 2dacc7b..9c73a2e 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -298,21 +298,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>  static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>  {
>         struct qtag_prefix {
> -               __be16 eth_type; /* ETH_P_8021Q */
> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>                 __be16 tci;
>         };
> -       struct qtag_prefix *qp;
> +       struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
>
> -       if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
> +       struct qinqtag_prefix {
> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
> +               __be16 tci;
> +               __be16 inner_tpid; /* ETH_P_8021Q */
> +               __be16 ctci;
> +       };
> +
...

>
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index a076e44..fa83c61 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -134,6 +134,9 @@ struct sw_flow_key {
>                 u8     src[ETH_ALEN];   /* Ethernet source address. */
>                 u8     dst[ETH_ALEN];   /* Ethernet destination address. */
>                 __be16 tci;             /* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
> +               __be16 ctci;            /* 0 if no CVLAN, VLAN_TAG_PRESENT set
> +                                        * otherwise.
> +                                        */
>                 __be16 type;            /* Ethernet frame type. */
>         } eth;
>         union {
> --
> 2.1.0
>
Currently you have restricted the datapath implementation to support
only 8021AD. We can extend this to support double tagging by adding
inner_tpid field to struct sw_flow_key. OVS netlink interface already
allows this type of configuration. So is there reason not to do it in
this series?
