From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] net: l2tp: fix reversed udp6 checksum flags
Date: Thu, 28 Apr 2016 19:46:24 +0100
Message-ID: <CAEwTi7SejvT35H0S0nBArEZFwoFAcCJ5twTKUmTxHcNx8az7Rg@mail.gmail.com>
References: <9A325D67-FED1-4AF6-8ED0-6C93FFE8DC67@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Wang Shanker <shankerwangmiao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40260 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824AbcD1Sqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 14:46:30 -0400
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id D3A918E017
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 19:46:24 +0100 (BST)
Received: by mail-wm0-f42.google.com with SMTP id e201so395454wme.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 11:46:24 -0700 (PDT)
In-Reply-To: <9A325D67-FED1-4AF6-8ED0-6C93FFE8DC67@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some additional background on this: Wang found this when configuring
l2tp tunnels using "ip l2tp" between two systems and then one system
was upgraded. The tunnel failed to pass data because one side had UDP
checksums enabled and the other now had them disabled. It seems kernel
changes related to UDP checksums resulted in a change to the default
UDP checksum setting for L2TP tunnels when using IPv6. Unfortunately,
iproute2 doesn't let the user configure L2TP UDP checksum settings, so
without this fix, some users may see problems depending on the kernel
version differences on the L2TP peers. One for stable?

Acked-by: James Chapman <jchapman@katalix.com>

On 28 April 2016 at 18:29, Wang Shanker <shankerwangmiao@gmail.com> wrote:
> This patch fixes a bug which causes the behavior of whether to ignore
> udp6 checksum of udp6 encapsulated l2tp tunnel contrary to what
> userspace program requests.
>
> When the flag `L2TP_ATTR_UDP_ZERO_CSUM6_RX` is set by userspace, it is
> expected that udp6 checksums of received packets of the l2tp tunnel
> to create should be ignored. In `l2tp_netlink.c`:
> `l2tp_nl_cmd_tunnel_create()`, `cfg.udp6_zero_rx_checksums` is set
> according to the flag, and then passed to `l2tp_core.c`:
> `l2tp_tunnel_create()` and then `l2tp_tunnel_sock_create()`. In
> `l2tp_tunnel_sock_create()`, `udp_conf.use_udp6_rx_checksums` is set
> the same to `cfg.udp6_zero_rx_checksums`. However, if we want the
> checksum to be ignored, `udp_conf.use_udp6_rx_checksums` should be set
> to `false`, i.e. be set to the contrary. Similarly, the same should be
> done to `udp_conf.use_udp6_tx_checksums`.
>
> Signed-off-by: Miao Wang <shankerwangmiao@gmail.com>
> ---
>  net/l2tp/l2tp_core.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index afca2eb..6edfa99 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1376,9 +1376,9 @@ static int l2tp_tunnel_sock_create(struct net *net,
>                         memcpy(&udp_conf.peer_ip6, cfg->peer_ip6,
>                                sizeof(udp_conf.peer_ip6));
>                         udp_conf.use_udp6_tx_checksums =
> -                           cfg->udp6_zero_tx_checksums;
> +                         ! cfg->udp6_zero_tx_checksums;
>                         udp_conf.use_udp6_rx_checksums =
> -                           cfg->udp6_zero_rx_checksums;
> +                         ! cfg->udp6_zero_rx_checksums;
>                 } else
>  #endif
>                 {
> --
> 2.5.2
>
