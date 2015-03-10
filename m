From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] tipc: fix undefined __ipv6_sock_mc_join
 compile error
Date: Tue, 10 Mar 2015 11:41:03 -0400
Message-ID: <CA+FuTSdxmae0DnNnQdCgCdaThVtZ1raqEg9z6XpHE5N9u5MCfw@mail.gmail.com>
References: <1425976885-18258-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	Fengguang Wu <fengguang.wu@intel.com>,
	Network Development <netdev@vger.kernel.org>,
	tipc-discussion@lists.sourceforge.net, kbuild-all@01.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:38141 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbCJPld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 11:41:33 -0400
Received: by oiax69 with SMTP id x69so2260289oia.5
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 08:41:33 -0700 (PDT)
In-Reply-To: <1425976885-18258-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 4:41 AM, Ying Xue <ying.xue@windriver.com> wrote:
> When CONFIG_IPV6 option is disabled, below error will appear while
> building TIPC module:
>
> ERROR: "__ipv6_sock_mc_join" [net/tipc/tipc.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [net/tipc/tipc.ko] Error 1
>
> This is because we don't check whether or not the CONFIG_IPV6 is
> enabled when calling __ipv6_sock_mc_join().
>
> In addition, especially when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m, TIPC
> module is also unable to be successfully built. Therefore, we add a
> dependency condition like (IPV6 || IPV6=n) to avoid the error.
>
> Fixes: d0f91938bede ("tipc: add ip/udp media type")
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Kbuild test robot <kbuild-all@01.org>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> ---
> v2:
>  Fix another compile error when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m
>
>  net/tipc/Kconfig     |    1 +
>  net/tipc/udp_media.c |    2 ++
>  2 files changed, 3 insertions(+)
>
> diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
> index c25a3a1..6f217ba 100644
> --- a/net/tipc/Kconfig
> +++ b/net/tipc/Kconfig
> @@ -5,6 +5,7 @@
>  menuconfig TIPC
>         tristate "The TIPC Protocol"
>         depends on INET
> +       depends on (IPV6 || IPV6=n)

Should this be limited to TIPC_MEDIA_UDP?

>         ---help---
>           The Transparent Inter Process Communication (TIPC) protocol is
>           specially designed for intra cluster communication. This protocol
> diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
> index fc2fb11..6763002 100644
> --- a/net/tipc/udp_media.c
> +++ b/net/tipc/udp_media.c
> @@ -247,10 +247,12 @@ static int enable_mcast(struct udp_bearer *ub, struct udp_media_addr *remote)


>                 mreqn.imr_multiaddr = remote->ipv4;
>                 mreqn.imr_ifindex = ub->ifindex;
>                 err = __ip_mc_join_group(sk, &mreqn);
> +#if IS_ENABLED(CONFIG_IPV6)
>         } else {
>                 if (!ipv6_addr_is_multicast(&remote->ipv6))
>                         return 0;
>                 err = __ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
> +#endif
>         }
>         return err;

It may also be prudent to initialize err to -EAFNOSUPPORT instead of
0. This function is currently only called when the protocol family has
been checked, but relying on that is a bit fragile.
