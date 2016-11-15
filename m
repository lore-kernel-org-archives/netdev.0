From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6 addrconf: Implemented enhanced DAD (RFC7527)
Date: Tue, 15 Nov 2016 17:00:11 +0100
Message-ID: <1ba995e1-2af9-ce9b-7038-e8463dd2a0a8@stressinduktion.org>
References: <5863cb78-0050-7b7e-f886-d4d6b2186f16@sonic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Erik Nordmark <nordmark@sonic.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43809 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750928AbcKOQAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 11:00:13 -0500
In-Reply-To: <5863cb78-0050-7b7e-f886-d4d6b2186f16@sonic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.11.2016 08:57, Erik Nordmark wrote:
> Implemented RFC7527 Enhanced DAD.
> IPv6 duplicate address detection can fail if there is some temporary
> loopback of Ethernet frames. RFC7527 solves this by including a random
> nonce in the NS messages used for DAD, and if an NS is received with the
> same nonce it is assumed to be a looped back DAD probe and is ignored.
> RFC7527 is disabled by default. Can be enabled by setting either one of
> conf/{all,interface}/ipv6_rfc7527 to non-zero.
> 
> Signed-off-by: Erik Nordmark <nordmark@arista.com>
> 
> Index: linux-stable/Documentation/networking/ip-sysctl.txt
> ===================================================================
> --- linux-stable.orig/Documentation/networking/ip-sysctl.txt
> +++ linux-stable/Documentation/networking/ip-sysctl.txt
> @@ -1713,6 +1713,15 @@ drop_unsolicited_na - BOOLEAN
> 
>      By default this is turned off.
> 
> +ipv6_rfc7527 - BOOLEAN

Could you rename the sysctl to enhanced_dad. As it will anyway show up
in the ipv6/ directory hierarchy you don't need to prefix it with 'ipv6_'

> +    Include a nonce option in the IPv6 neighbor solicitation messages
> used for
> +    duplicate address detection per RFC7527. A received DAD NS will
> only signal
> +    a duplicate address if the nonce is different. This avoids any false
> +    detection of duplicates due to loopback of the NS messages that we
> send.
> +    The nonce option will be sent on an interface if either one of
> +    conf/{all,interface}/ipv6_rfc7527 are TRUE.
> +    Default: FALSE
> +
>  icmp/*:
>  ratelimit - INTEGER
>      Limit the maximal rates for sending ICMPv6 packets.
> Index: linux-stable/include/linux/ipv6.h
> ===================================================================
> --- linux-stable.orig/include/linux/ipv6.h
> +++ linux-stable/include/linux/ipv6.h
> @@ -63,6 +63,7 @@ struct ipv6_devconf {
>      } stable_secret;
>      __s32        use_oif_addrs_only;
>      __s32        keep_addr_on_down;
> +    __u32        ipv6_rfc7527;

Same here, as above.

> 
>      struct ctl_table_header *sysctl_header;
>  };
> Index: linux-stable/include/net/if_inet6.h
> ===================================================================
> --- linux-stable.orig/include/net/if_inet6.h
> +++ linux-stable/include/net/if_inet6.h
> @@ -55,6 +55,7 @@ struct inet6_ifaddr {
>      __u8            stable_privacy_retry;
> 
>      __u16            scope;
> +    __u64            dad_nonce;
> 
>      unsigned long        cstamp;    /* created timestamp */
>      unsigned long        tstamp; /* updated timestamp */
> Index: linux-stable/include/net/ndisc.h
> ===================================================================
> --- linux-stable.orig/include/net/ndisc.h
> +++ linux-stable/include/net/ndisc.h
> @@ -31,6 +31,7 @@ enum {
>      ND_OPT_PREFIX_INFO = 3,        /* RFC2461 */
>      ND_OPT_REDIRECT_HDR = 4,    /* RFC2461 */
>      ND_OPT_MTU = 5,            /* RFC2461 */
> +    ND_OPT_NONCE = 14,              /* RFC7527 */
>      __ND_OPT_ARRAY_MAX,
>      ND_OPT_ROUTE_INFO = 24,        /* RFC4191 */
>      ND_OPT_RDNSS = 25,        /* RFC5006 */
> @@ -121,6 +122,7 @@ struct ndisc_options {
>  #define nd_opts_pi_end nd_opt_array[__ND_OPT_PREFIX_INFO_END]
>  #define nd_opts_rh            nd_opt_array[ND_OPT_REDIRECT_HDR]
>  #define nd_opts_mtu            nd_opt_array[ND_OPT_MTU]
> +#define nd_opts_nonce            nd_opt_array[ND_OPT_NONCE]
>  #define nd_802154_opts_src_lladdr
> nd_802154_opt_array[ND_OPT_SOURCE_LL_ADDR]
>  #define nd_802154_opts_tgt_lladdr
> nd_802154_opt_array[ND_OPT_TARGET_LL_ADDR]
> 
> @@ -398,7 +400,8 @@ void ndisc_cleanup(void);
>  int ndisc_rcv(struct sk_buff *skb);
> 
>  void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
> -           const struct in6_addr *daddr, const struct in6_addr *saddr);
> +           const struct in6_addr *daddr, const struct in6_addr *saddr,
> +           u64 nonce);
> 
>  void ndisc_send_rs(struct net_device *dev,
>             const struct in6_addr *saddr, const struct in6_addr *daddr);
> Index: linux-stable/include/uapi/linux/ipv6.h
> ===================================================================
> --- linux-stable.orig/include/uapi/linux/ipv6.h
> +++ linux-stable/include/uapi/linux/ipv6.h
> @@ -177,6 +177,7 @@ enum {
>      DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
>      DEVCONF_DROP_UNSOLICITED_NA,
>      DEVCONF_KEEP_ADDR_ON_DOWN,
> +    DEVCONF_IPV6_RFC7527,

Ditto.

>      DEVCONF_MAX
>  };
> 
> Index: linux-stable/net/ipv6/addrconf.c
> ===================================================================
> --- linux-stable.orig/net/ipv6/addrconf.c
> +++ linux-stable/net/ipv6/addrconf.c
> @@ -217,6 +217,7 @@ static struct ipv6_devconf ipv6_devconf
>      .use_oif_addrs_only    = 0,
>      .ignore_routes_with_linkdown = 0,
>      .keep_addr_on_down    = 0,
> +    .ipv6_rfc7527           = 0,

What is your reason to not enable this by default? I haven't fully
studied the RFC, but it seems to be backwards compatible.

>  };
> 
>  static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
> @@ -262,6 +263,7 @@ static struct ipv6_devconf ipv6_devconf_
>      .use_oif_addrs_only    = 0,
>      .ignore_routes_with_linkdown = 0,
>      .keep_addr_on_down    = 0,
> +    .ipv6_rfc7527           = 0,
>  };
> 
>  /* Check if a valid qdisc is available */
> @@ -3722,12 +3724,18 @@ static void addrconf_dad_kick(struct ine
>  {
>      unsigned long rand_num;
>      struct inet6_dev *idev = ifp->idev;
> +    u64 nonce;
> 
>      if (ifp->flags & IFA_F_OPTIMISTIC)
>          rand_num = 0;
>      else
>          rand_num = prandom_u32() % (idev->cnf.rtr_solicit_delay ? : 1);
> 
> +    nonce = 0;
> +    if (ifp->idev->cnf.ipv6_rfc7527 ||
> + dev_net((ifp->idev)->dev)->ipv6.devconf_all->ipv6_rfc7527)

idev should already be in scope, so you can simplify this conditional.


> +        get_random_bytes(&nonce, 6);

Maybe:

do
	get_random_bytes(&nonce, 6);
while (!nonce);

> +    ifp->dad_nonce = nonce;
>      ifp->dad_probes = idev->cnf.dad_transmits;
>      addrconf_mod_dad_work(ifp, rand_num);
>  }
> @@ -3903,7 +3911,8 @@ static void addrconf_dad_work(struct wor
> 
>      /* send a neighbour solicitation for our addr */
>      addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
> -    ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any);
> +    ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any,
> +              ifp->dad_nonce);
>  out:
>      in6_ifa_put(ifp);
>      rtnl_unlock();
> @@ -4937,6 +4946,7 @@ static inline void ipv6_store_devconf(st
>      array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] =
> cnf->drop_unicast_in_l2_multicast;
>      array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
>      array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
> +    array[DEVCONF_IPV6_RFC7527] = cnf->ipv6_rfc7527;
>  }
> 
>  static inline size_t inet6_ifla6_size(void)
> @@ -6027,6 +6037,13 @@ static const struct ctl_table addrconf_s
> 
>      },
>      {
> +        .procname       = "ipv6_rfc7527",
> +        .data           = &ipv6_devconf.ipv6_rfc7527,
> +        .maxlen         = sizeof(int),
> +        .mode           = 0644,
> +        .proc_handler   = proc_dointvec,
> +    },
> +    {
>          /* sentinel */
>      }
>  };
> Index: linux-stable/net/ipv6/ndisc.c
> ===================================================================
> --- linux-stable.orig/net/ipv6/ndisc.c
> +++ linux-stable/net/ipv6/ndisc.c
> @@ -234,6 +234,7 @@ struct ndisc_options *ndisc_parse_option
>          case ND_OPT_SOURCE_LL_ADDR:
>          case ND_OPT_TARGET_LL_ADDR:
>          case ND_OPT_MTU:
> +        case ND_OPT_NONCE:
>          case ND_OPT_REDIRECT_HDR:
>              if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
>                  ND_PRINTK(2, warn,
> @@ -571,7 +572,8 @@ static void ndisc_send_unsol_na(struct n
>  }
> 
>  void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
> -           const struct in6_addr *daddr, const struct in6_addr *saddr)
> +           const struct in6_addr *daddr, const struct in6_addr *saddr,
> +           u64 nonce)
>  {
>      struct sk_buff *skb;
>      struct in6_addr addr_buf;
> @@ -591,6 +593,8 @@ void ndisc_send_ns(struct net_device *de
>      if (inc_opt)
>          optlen += ndisc_opt_addr_space(dev,
>                             NDISC_NEIGHBOUR_SOLICITATION);
> +    if (nonce != 0)
> +        optlen += 8;
> 
>      skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
>      if (!skb)
> @@ -608,6 +612,13 @@ void ndisc_send_ns(struct net_device *de
>          ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
>                         dev->dev_addr,
>                         NDISC_NEIGHBOUR_SOLICITATION);
> +    if (nonce != 0) {
> +        u8 *opt = skb_put(skb, 8);
> +
> +        opt[0] = ND_OPT_NONCE;
> +        opt[1] = 8 >> 3;
> +        memcpy(opt + 2, &nonce, 6);
> +    }
> 
>      ndisc_send_skb(skb, daddr, saddr);
>  }
> @@ -696,12 +707,12 @@ static void ndisc_solicit(struct neighbo
>                    "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
>                    __func__, target);
>          }
> -        ndisc_send_ns(dev, target, target, saddr);
> +        ndisc_send_ns(dev, target, target, saddr, 0);
>      } else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
>          neigh_app_ns(neigh);
>      } else {
>          addrconf_addr_solict_mult(target, &mcaddr);
> -        ndisc_send_ns(dev, target, &mcaddr, saddr);
> +        ndisc_send_ns(dev, target, &mcaddr, saddr, 0);
>      }
>  }
> 
> @@ -745,6 +756,7 @@ static void ndisc_recv_ns(struct sk_buff
>      int dad = ipv6_addr_any(saddr);
>      bool inc;
>      int is_router = -1;
> +    u64 nonce;
> 
>      if (skb->len < sizeof(struct nd_msg)) {
>          ND_PRINTK(2, warn, "NS: packet too short\n");
> @@ -789,6 +801,8 @@ static void ndisc_recv_ns(struct sk_buff
>              return;
>          }
>      }
> +    if (ndopts.nd_opts_nonce)
> +        memcpy(&nonce, (u8 *)(ndopts.nd_opts_nonce + 1), 6);

You only initialize 6 bytes of the nonce, with the other 2 being not
initialized.

> 
>      inc = ipv6_addr_is_multicast(daddr);
> 
> @@ -797,6 +811,16 @@ static void ndisc_recv_ns(struct sk_buff
>  have_ifp:
>          if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>              if (dad) {
> +                if (nonce != 0 && ifp->dad_nonce == nonce) {
> +                    /* Matching nonce if looped back */
> +                    if (net_ratelimit())
> +                        ND_PRINTK(2, notice,
> +                              "%s: IPv6 DAD loopback for address %pI6c
> nonce %llu ignored\n",
> +                               ifp->idev->dev->name,
> +                               &ifp->addr,
> +                               nonce);

If we print the nonce for debugging reasons, we should keep it in
correct endianess on the wire vs. in the debug output.

> +                    goto out;
> +                }
>                  /*
>                   * We are colliding with another node
>                   * who is doing DAD
> 
