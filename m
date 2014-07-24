From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 2/9] gue: Support for Generic UDP Encapsulation
 RX path
Date: Thu, 24 Jul 2014 10:07:39 +0300
Message-ID: <CAJZOPZLLFjv6t-cz7EF9pg55VtVETQxXqbELBwkb9-=e56HCqg@mail.gmail.com>
References: <alpine.DEB.2.02.1407162058200.2128@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:49114 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934061AbaGXHHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 03:07:40 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so2527155qaq.1
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 00:07:39 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1407162058200.2128@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 7:14 AM, Tom Herbert <therbert@google.com> wrote:
> This patch provides a Generic UDP Encapsulation receive path
> using the XFRM framework (udp_encap_rcv).
>
> This adds support for both direct encapsulation of IP protocols over
> UDP. The bound destination port is used to map to an IP protocol.
> This should support GRE over UDP encapsulation, see
> http://tools.ietf.org/html/draft-yong-tsvwg-gre-in-udp-encap-02,
> as will as the other IP tunneling protocols (IPIP, SIT).
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/net/gue.h |  49 +++++++++++++++++
>  net/ipv4/Kconfig  |  10 ++++
>  net/ipv4/Makefile |   1 +
>  net/ipv4/gue.c    | 159 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 219 insertions(+)
>  create mode 100644 include/net/gue.h
>  create mode 100644 net/ipv4/gue.c
>
> diff --git a/include/net/gue.h b/include/net/gue.h
> new file mode 100644
> index 0000000..86b91bc
> --- /dev/null
> +++ b/include/net/gue.h
> @@ -0,0 +1,49 @@
> +#ifndef __NET_GUE_H
> +#define __NET_GUE_H
> +
> +#if defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE)
> +
> +#include <net/udp_tunnel.h>
> +
> +struct gue_port_cfg {
> +       u8                      protocol;
> +       struct udp_port_cfg     udp_config;
> +};
> +
> +int gue_port_create(struct net *net, struct gue_port_cfg *cfg,
> +                   struct socket **sockp);
> +int gue_open_direct_port(unsigned short port, unsigned char proto,
> +                        struct socket **sockp);
> +void gue_close_port(struct socket *sock);
> +
> +/* Tunnel protocols can use GUE_TUNNEL_PARMS to set up per module static
> + * variables that are used with the common GUE functions (open_gue_port,
> + * close_gue_port).
> + */
> +#define GUE_TUNNEL_PARMS(name, default_port)                   \
> +static int gue_udp_port = default_port;                                \
> +module_param(gue_udp_port, int, 0);                            \
> +MODULE_PARM_DESC(gue_udp_port, name "/UDP port");              \
> +static struct socket *gue_sock;
> +
> +#define open_gue_port(proto)                                   \
> +       (gue_udp_port ?                                         \
> +        gue_open_direct_port(gue_udp_port, proto, &gue_sock) : \
> +        0)
> +
> +#define close_gue_port() do {                                  \
> +       if (gue_sock) {                                         \
> +               gue_close_port(gue_sock);                       \
> +               gue_sock = NULL;                                \
> +       }                                                       \
> +} while (0)
> +

Hi Tom,

So this is probably a similar feedback to the ioctls vs netlink
comment from Dave...

I guess we agree that module params should be avoided when possible, right? so
this even goes further to a template in a header file used by the
caller modules to define
their own module param...  should be (a non academic, I read your other comment)
alternative here, I hope.

Or.

> +#else /* defined(CONFIG_NET_GUE) || defined(CONFIG_NET_GUE_MODULE) */
> +
> +#define GUE_TUNNEL_PARMS(name, default_port)
> +#define open_gue_port(proto) (0)
> +#define close_gue_port()
> +
> +#endif
> +
> +#endif
