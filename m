From: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 4/7] openvswitch: add ipv6 'set'
	action
Date: Tue, 11 Dec 2012 19:14:32 -0800
Message-ID: <CA+mtBx-Zf9FNf11H9RM12etHnJ1bPpM_Eyc4mR7E6xsb7sUP2Q@mail.gmail.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
	<1354214149-33651-5-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1354214149-33651-5-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

> This patch adds ipv6 set action functionality. It allows to change
> traffic class, flow label, hop-limit, ipv6 source and destination
> address fields.
>
I have to wonder about these patches and the underlying design
direction.  Aren't these sort of things and more already implemented
by IPtables but in a modular and extensible fashion?  Has there been
any thought into hooking OVS to IP tables to leverage all the existing
functionality?

Thanks,
Tom

> Signed-off-by: Ansis Atteka <aatteka-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> ---
>  net/openvswitch/actions.c  |   93 ++++++++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/datapath.c |   20 ++++++++++
>  2 files changed, 113 insertions(+)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 0811447..a58ed27 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -28,6 +28,7 @@
>  #include <linux/if_arp.h>
>  #include <linux/if_vlan.h>
>  #include <net/ip.h>
> +#include <net/ipv6.h>
>  #include <net/checksum.h>
>  #include <net/dsfield.h>
>
> @@ -162,6 +163,53 @@ static void set_ip_addr(struct sk_buff *skb, struct iphdr *nh,
>         *addr = new_addr;
>  }
>
> +static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
> +                                __be32 addr[4], const __be32 new_addr[4])
> +{
> +       int transport_len = skb->len - skb_transport_offset(skb);
> +
> +       if (l4_proto == IPPROTO_TCP) {
> +               if (likely(transport_len >= sizeof(struct tcphdr)))
> +                       inet_proto_csum_replace16(&tcp_hdr(skb)->check, skb,
> +                                                 addr, new_addr, 1);
> +       } else if (l4_proto == IPPROTO_UDP) {
> +               if (likely(transport_len >= sizeof(struct udphdr))) {
> +                       struct udphdr *uh = udp_hdr(skb);
> +
> +                       if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
> +                               inet_proto_csum_replace16(&uh->check, skb,
> +                                                         addr, new_addr, 1);
> +                               if (!uh->check)
> +                                       uh->check = CSUM_MANGLED_0;
> +                       }
> +               }
> +       }
> +}
> +
> +static void set_ipv6_addr(struct sk_buff *skb, u8 l4_proto,
> +                         __be32 addr[4], const __be32 new_addr[4],
> +                         bool recalculate_csum)
> +{
> +       if (recalculate_csum)
> +               update_ipv6_checksum(skb, l4_proto, addr, new_addr);
> +
> +       skb->rxhash = 0;
> +       memcpy(addr, new_addr, sizeof(__be32[4]));
> +}
> +
> +static void set_ipv6_tc(struct ipv6hdr *nh, u8 tc)
> +{
> +       nh->priority = tc >> 4;
> +       nh->flow_lbl[0] = (nh->flow_lbl[0] & 0x0F) | ((tc & 0x0F) << 4);
> +}
> +
> +static void set_ipv6_fl(struct ipv6hdr *nh, u32 fl)
> +{
> +       nh->flow_lbl[0] = (nh->flow_lbl[0] & 0xF0) | (fl & 0x000F0000) >> 16;
> +       nh->flow_lbl[1] = (fl & 0x0000FF00) >> 8;
> +       nh->flow_lbl[2] = fl & 0x000000FF;
> +}
> +
>  static void set_ip_ttl(struct sk_buff *skb, struct iphdr *nh, u8 new_ttl)
>  {
>         csum_replace2(&nh->check, htons(nh->ttl << 8), htons(new_ttl << 8));
> @@ -195,6 +243,47 @@ static int set_ipv4(struct sk_buff *skb, const struct ovs_key_ipv4 *ipv4_key)
>         return 0;
>  }
>
> +static int set_ipv6(struct sk_buff *skb, const struct ovs_key_ipv6 *ipv6_key)
> +{
> +       struct ipv6hdr *nh;
> +       int err;
> +       __be32 *saddr;
> +       __be32 *daddr;
> +
> +       err = make_writable(skb, skb_network_offset(skb) +
> +                           sizeof(struct ipv6hdr));
> +       if (unlikely(err))
> +               return err;
> +
> +       nh = ipv6_hdr(skb);
> +       saddr = (__be32 *)&nh->saddr;
> +       daddr = (__be32 *)&nh->daddr;
> +
> +       if (memcmp(ipv6_key->ipv6_src, saddr, sizeof(ipv6_key->ipv6_src)))
> +               set_ipv6_addr(skb, ipv6_key->ipv6_proto, saddr,
> +                             ipv6_key->ipv6_src, true);
> +
> +       if (memcmp(ipv6_key->ipv6_dst, daddr, sizeof(ipv6_key->ipv6_dst))) {
> +               unsigned int offset = 0;
> +               int flags = IP6_FH_F_SKIP_RH;
> +               bool recalc_csum = true;
> +
> +               if (ipv6_ext_hdr(nh->nexthdr))
> +                       recalc_csum = ipv6_find_hdr(skb, &offset,
> +                                                   NEXTHDR_ROUTING, NULL,
> +                                                   &flags) != NEXTHDR_ROUTING;
> +
> +               set_ipv6_addr(skb, ipv6_key->ipv6_proto, daddr,
> +                             ipv6_key->ipv6_dst, recalc_csum);
> +       }
> +
> +       set_ipv6_tc(nh, ipv6_key->ipv6_tclass);
> +       set_ipv6_fl(nh, ntohl(ipv6_key->ipv6_label));
> +       nh->hop_limit = ipv6_key->ipv6_hlimit;
> +
> +       return 0;
> +}
> +
>  /* Must follow make_writable() since that can move the skb data. */
>  static void set_tp_port(struct sk_buff *skb, __be16 *port,
>                          __be16 new_port, __sum16 *check)
> @@ -347,6 +436,10 @@ static int execute_set_action(struct sk_buff *skb,
>                 err = set_ipv4(skb, nla_data(nested_attr));
>                 break;
>
> +       case OVS_KEY_ATTR_IPV6:
> +               err = set_ipv6(skb, nla_data(nested_attr));
> +               break;
> +
>         case OVS_KEY_ATTR_TCP:
>                 err = set_tcp(skb, nla_data(nested_attr));
>                 break;
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 4c4b62c..fd4a6a4 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -479,6 +479,7 @@ static int validate_set(const struct nlattr *a,
>
>         switch (key_type) {
>         const struct ovs_key_ipv4 *ipv4_key;
> +       const struct ovs_key_ipv6 *ipv6_key;
>
>         case OVS_KEY_ATTR_PRIORITY:
>         case OVS_KEY_ATTR_ETHERNET:
> @@ -500,6 +501,25 @@ static int validate_set(const struct nlattr *a,
>
>                 break;
>
> +       case OVS_KEY_ATTR_IPV6:
> +               if (flow_key->eth.type != htons(ETH_P_IPV6))
> +                       return -EINVAL;
> +
> +               if (!flow_key->ip.proto)
> +                       return -EINVAL;
> +
> +               ipv6_key = nla_data(ovs_key);
> +               if (ipv6_key->ipv6_proto != flow_key->ip.proto)
> +                       return -EINVAL;
> +
> +               if (ipv6_key->ipv6_frag != flow_key->ip.frag)
> +                       return -EINVAL;
> +
> +               if (ntohl(ipv6_key->ipv6_label) & 0xFFF00000)
> +                       return -EINVAL;
> +
> +               break;
> +
>         case OVS_KEY_ATTR_TCP:
>                 if (flow_key->ip.proto != IPPROTO_TCP)
>                         return -EINVAL;
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
