From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/2] Support outside netns for tunnels.
Date: Mon, 4 Jan 2016 11:47:20 -0800
Message-ID: <CALx6S376Ay70TTP=UwSpo4aieZ3Rp7U4TNmdSCbKSqGDHcw3DA@mail.gmail.com>
References: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Saurabh Mohan <saurabh@cplanenetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35516 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbcADTrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 14:47:20 -0500
Received: by mail-io0-f193.google.com with SMTP id o67so40926185iof.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 11:47:20 -0800 (PST)
In-Reply-To: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 4, 2016 at 10:45 AM, Saurabh Mohan
<saurabh@cplanenetworks.com> wrote:
>
> This patch enchances a tunnel interface, like gre, to have the tunnel
> encap/decap be in the context of a network namespace that is different from
> the namespace of the tunnel interface.
>
> From userspace this feature may be configured using the new 'onetns' keyword:
> ip netns exec custa ip link add dev tun1 type gre local 10.0.0.1 \
>  remote 10.0.0.2 onetns outside
>
> In the above example the tunnel would be in the 'custa' namespace and the
> tunnel endpoints would be in the 'outside' namespace.
>
> Also, proposing the use of netns name 'global' to specify the global namespace.
>
> If this patch set is accepted then I will add support for other tunnels as
> well.
>
This might be interesting. Can you please ad a 0/n patch that
describes the motivation for this, in particular I would like to know
if this has a positive impact on ns performance if somehow we are
eliminating indirection.

Thanks,
Tom

> Signed-off-by: Saurabh Mohan <saurabh@cplanenetworks.com>
> ---
>  include/uapi/linux/if_tunnel.h | 19 +++++++++++++++++++
>  net/ipv4/ip_tunnel.c           | 24 +++++++++++++++++++++---
>  2 files changed, 40 insertions(+), 3 deletions(-)
>
> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
> index af4de90..2e43753 100644
> --- a/include/uapi/linux/if_tunnel.h
> +++ b/include/uapi/linux/if_tunnel.h
> @@ -3,6 +3,7 @@
>
>  #include <linux/types.h>
>  #include <asm/byteorder.h>
> +#include <linux/limits.h>
>
>
>  #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
> @@ -27,6 +28,14 @@
>  #define GRE_FLAGS      __cpu_to_be16(0x00F8)
>  #define GRE_VERSION    __cpu_to_be16(0x0007)
>
> +struct o_netns_parm {
> +       __u8                    o_netns_flag;
> +       __u32                   o_netns_fd;
> +       char                    netns[NAME_MAX];
> +};
> +#define TUNNEL_ONETNS_FLAG_GLOBAL      (1<<0)
> +#define TUNNEL_ONETNS_FLAG_NETNS       (1<<1)
> +
>  struct ip_tunnel_parm {
>         char                    name[IFNAMSIZ];
>         int                     link;
> @@ -35,6 +44,7 @@ struct ip_tunnel_parm {
>         __be32                  i_key;
>         __be32                  o_key;
>         struct iphdr            iph;
> +       struct o_netns_parm     o_net;
>  };
>
>  enum {
> @@ -57,6 +67,9 @@ enum {
>         IFLA_IPTUN_ENCAP_FLAGS,
>         IFLA_IPTUN_ENCAP_SPORT,
>         IFLA_IPTUN_ENCAP_DPORT,
> +       IFLA_IPTUN_ONETNS_FLAGS,
> +       IFLA_IPTUN_ONETNS_FD,
> +       IFLA_IPTUN_ONETNS_NAME,
>         __IFLA_IPTUN_MAX,
>  };
>  #define IFLA_IPTUN_MAX (__IFLA_IPTUN_MAX - 1)
> @@ -113,6 +126,9 @@ enum {
>         IFLA_GRE_ENCAP_SPORT,
>         IFLA_GRE_ENCAP_DPORT,
>         IFLA_GRE_COLLECT_METADATA,
> +       IFLA_GRE_ONETNS_FLAGS,
> +       IFLA_GRE_ONETNS_FD,
> +       IFLA_GRE_ONETNS_NAME,
>         __IFLA_GRE_MAX,
>  };
>
> @@ -128,6 +144,9 @@ enum {
>         IFLA_VTI_OKEY,
>         IFLA_VTI_LOCAL,
>         IFLA_VTI_REMOTE,
> +       IFLA_VTI_ONETNS_FLAGS,
> +       IFLA_VTI_ONETNS_FD,
> +       IFLA_VTI_ONETNS_NAME,
>         __IFLA_VTI_MAX,
>  };
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index c7bd72e..f8dd717 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -259,6 +259,16 @@ static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
>         return &itn->tunnels[h];
>  }
>
> +static struct net *ip_tunnel_get_onet(struct net *inet,
> +                                     struct ip_tunnel_parm *parms)
> +{
> +       if (parms->o_net.o_netns_flag == 0)
> +               return inet;
> +       if (parms->o_net.o_netns_flag & TUNNEL_ONETNS_FLAG_GLOBAL)
> +               return &init_net;
> +       return get_net_ns_by_fd(parms->o_net.o_netns_fd);
> +}
> +
>  static void ip_tunnel_add(struct ip_tunnel_net *itn, struct ip_tunnel *t)
>  {
>         struct hlist_head *head = ip_bucket(itn, &t->parms);
> @@ -330,7 +340,7 @@ static struct net_device *__ip_tunnel_create(struct net *net,
>
>         tunnel = netdev_priv(dev);
>         tunnel->parms = *parms;
> -       tunnel->net = net;
> +       tunnel->net = ip_tunnel_get_onet(net, &tunnel->parms);
>
>         err = register_netdevice(dev);
>         if (err)
> @@ -818,6 +828,14 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
>         t->parms.iph.daddr = p->iph.daddr;
>         t->parms.i_key = p->i_key;
>         t->parms.o_key = p->o_key;
> +       if (strcmp(p->o_net.netns, t->parms.o_net.netns)) {
> +               /* change the itn */
> +               struct net *o_net = ip_tunnel_get_onet(dev_net(dev), p);
> +
> +               itn = net_generic(o_net, t->ip_tnl_net_id);
> +               t->parms.o_net = p->o_net;
> +               t->net = o_net;
> +       }
>         if (dev->type != ARPHRD_ETHER) {
>                 memcpy(dev->dev_addr, &p->iph.saddr, 4);
>                 memcpy(dev->broadcast, &p->iph.daddr, 4);
> @@ -1071,7 +1089,7 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
>                       struct ip_tunnel_parm *p)
>  {
>         struct ip_tunnel *nt;
> -       struct net *net = dev_net(dev);
> +       struct net *net = ip_tunnel_get_onet(dev_net(dev), p);
>         struct ip_tunnel_net *itn;
>         int mtu;
>         int err;
> @@ -1169,7 +1187,7 @@ int ip_tunnel_init(struct net_device *dev)
>         }
>
>         tunnel->dev = dev;
> -       tunnel->net = dev_net(dev);
> +       tunnel->net = ip_tunnel_get_onet(dev_net(dev), &tunnel->parms);
>         strcpy(tunnel->parms.name, dev->name);
>         iph->version            = 4;
>         iph->ihl                = 5;
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
