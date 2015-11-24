From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] ip_tunnel: determine tunnel address family
 from the tunnel type
Date: Mon, 23 Nov 2015 16:26:09 -0800
Message-ID: <20151123162609.713e34a1@xeon-e3>
References: <59e83fe5165e4c3698a1caa3950d72a3@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Konstantin Shemyak <konstantin@shemyak.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:32938 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831AbbKXA0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 19:26:03 -0500
In-Reply-To: <59e83fe5165e4c3698a1caa3950d72a3@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2015 21:10:08 +0000
Konstantin Shemyak <konstantin@shemyak.com> wrote:

> When creating an IP tunnel over IPv6, the address family must be passed in
> the option, e.g.
> 
> ip -6 tunnel add mode ip6gre local 1::1 remote 2::2
> 
> This makes it impossible to create both IPv4 and IPv6 tunnels in one batch.
> 
> In fact the address family option is redundant here, as each tunnel mode is
> relevant for only one address family.
> The patch determines whether the applicable address family is AF_INET6
> instead of the default AF_INET and makes the "-6" option unnecessary for
> "ip tunnel add".
> 
> Signed-off-by: Konstantin Shemyak <konstantin@shemyak.com>
> ---
>  ip/iptunnel.c                          | 26 ++++++++++++++++++++++++++
>  testsuite/tests/ip/tunnel/add_tunnel.t | 14 ++++++++++++++
>  2 files changed, 40 insertions(+)
>  create mode 100755 testsuite/tests/ip/tunnel/add_tunnel.t
> 
> diff --git a/ip/iptunnel.c b/ip/iptunnel.c
> index 78fa988..7826a37 100644
> --- a/ip/iptunnel.c
> +++ b/ip/iptunnel.c
> @@ -629,8 +629,34 @@ static int do_6rd(int argc, char **argv)
>         return tnl_6rd_ioctl(cmd, medium, &ip6rd);
>  }
>  
> +static int tunnel_mode_is_ipv6(char *tunnel_mode) {
> +       char *ipv6_modes[] = {
> +               "ipv6/ipv6", "ip6ip6",
> +               "vti6",
> +               "ip/ipv6", "ipv4/ipv6", "ipip6", "ip4ip6",
> +               "ip6gre", "gre/ipv6",
> +               "any/ipv6", "any"
> +       };
> +       int i;
> +
> +       for (i = 0; i < sizeof(ipv6_modes) / sizeof(char *); i++) {
> +               if (strcmp(ipv6_modes[i], tunnel_mode) == 0)
> +                       return 1;
> +       }
> +       return 0;
> +}
> +

The ipv6_modes table should be static const.
Also is it possible to use strstr for ipv6 and ip6 or even strchr(tunnel_mode, '6')
to simplify this?
