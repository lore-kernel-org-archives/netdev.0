From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 1/1] vxlan: insert ipv6 macro
Date: Tue, 11 Oct 2016 16:06:15 +0200
Message-ID: <20161011160615.7f7f7746@griffin>
References: <1476174211-9358-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, daniel@iogearbox.net,
        pshelar@nicira.com, aduyck@mirantis.com,
        hannes@stressinduktion.org, davem@davemloft.net
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752445AbcJKOQp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 10:16:45 -0400
In-Reply-To: <1476174211-9358-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Oct 2016 16:23:31 +0800, zyjzyj2000@gmail.com wrote:
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2647,15 +2647,15 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
>  	int err;
>  
>  	memset(&udp_conf, 0, sizeof(udp_conf));
> -
> +#if IS_ENABLED(CONFIG_IPV6)
>  	if (ipv6) {
>  		udp_conf.family = AF_INET6;
>  		udp_conf.use_udp6_rx_checksums =
>  		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
>  		udp_conf.ipv6_v6only = 1;
> -	} else {
> +	} else 
> +#endif
>  		udp_conf.family = AF_INET;
> -	}

Zhu Yanjun, before posting patches such as the previous ones or
this one, please test whether they make any difference. In this case,
try to compile the code with IPv6 disabled before and after this patch,
disassemble and compare the results. You'll see that this patch is
pointless.

It's pretty obvious from the code but to be really sure, I've just
quickly built the vxlan module with IPv6 disabled. And indeed, as
expected, the compiler just inlined everything into vxlan_open. The
whole chain vxlan_open -> vxlan_sock_add -> __vxlan_sock_add (note that
there's only a single caller of __vxlan_sock_add with IPv6 disabled) ->
vxlan_socket_create -> vxlan_create_sock is inlined.

It also means the code in the "if (ipv6)" branch is completely
eliminated by the compiler even without ugly #ifdefs.

 Jiri
