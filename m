From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Mon, 26 Mar 2012 15:50:30 -0700
Message-ID: <m1mx73rn7t.fsf@fess.ebiederm.org>
References: <20120326222359.GB28123@dztty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org
To: Djalal Harouni <tixxdz@opendz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out07.mta.xmission.com ([166.70.13.237]:45902 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752434Ab2CZWq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 18:46:56 -0400
In-Reply-To: <20120326222359.GB28123@dztty> (Djalal Harouni's message of "Mon,
	26 Mar 2012 23:23:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Djalal Harouni <tixxdz@opendz.org> writes:

> I've been analysing some kmemleak reports of an internal module, and
> found that there are false positive reports of unreferenced objects.
>
> The following patch is just a clean up for one of those false positives,
> this is for the /proc/sys/net/ipv4 sysctl table.
> As I've said there are other reports but don't know if it is worth to
> write patches for them.

So the problem here is that you register a sysctl and don't keep a
pointer to the returned sysctl_header?  So kmemleak complains?

I would expect the other sysctl data structures to have such a pointer,
so I don't know why kmemleak would complain.

Does my recent sysctl rewrite affect when this kmemleak is reported?

Scratching my head to understand what the complain is.

> ---
> From: Djalal Harouni <tixxdz@opendz.org>
> Subject: [PATCH] net: reference the ipv4 sysctl table header
>
> Reference the ipv4 sysctl table header allocated and returned by
> register_sysctl_paths().
>
> Signed-off-by: Djalal Harouni <tixxdz@opendz.org>
> ---
>  include/net/ip.h   |    2 +-
>  net/ipv4/af_inet.c |   12 ++++++++++--
>  net/ipv4/route.c   |   10 ++++++++--
>  3 files changed, 19 insertions(+), 5 deletions(-)
>
> diff --git a/include/net/ip.h b/include/net/ip.h
> index b53d65f..6a12687 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -235,7 +235,7 @@ extern int sysctl_ip_dynaddr;
>  
>  extern void ipfrag_init(void);
>  
> -extern void ip_static_sysctl_init(void);
> +extern int ip_static_sysctl_init(void);
>  
>  static inline bool ip_is_fragment(const struct iphdr *iph)
>  {
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index fdf49fd..340d298 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1666,10 +1666,14 @@ static int __init inet_init(void)
>  	 *	Tell SOCKET that we are alive...
>  	 */
>  
> -	(void)sock_register(&inet_family_ops);
> +	rc = sock_register(&inet_family_ops);
> +	if (rc)
> +		goto out_unregister_ping_prot;
>  
>  #ifdef CONFIG_SYSCTL
> -	ip_static_sysctl_init();
> +	rc = ip_static_sysctl_init();
> +	if (rc)
> +		goto out_unregister_sock;
>  #endif
>  
>  	tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
> @@ -1751,6 +1755,10 @@ static int __init inet_init(void)
>  	rc = 0;
>  out:
>  	return rc;
> +out_unregister_sock:
> +	sock_unregister(PF_INET);
> +out_unregister_ping_prot:
> +	proto_unregister(&ping_prot);
>  out_unregister_raw_proto:
>  	proto_unregister(&raw_prot);
>  out_unregister_udp_proto:
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 12ccf88..bc899f2 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -3500,12 +3500,18 @@ int __init ip_rt_init(void)
>  }
>  
>  #ifdef CONFIG_SYSCTL
> +static struct ctl_table_header *ip4_base;
> +
>  /*
>   * We really need to sanitize the damn ipv4 init order, then all
>   * this nonsense will go away.
>   */
> -void __init ip_static_sysctl_init(void)
> +int __init ip_static_sysctl_init(void)
>  {
> -	register_sysctl_paths(ipv4_path, ipv4_skeleton);
> +	ip4_base = register_sysctl_paths(ipv4_path, ipv4_skeleton);
> +	if (!ip4_base)
> +		return -ENOMEM;
> +
> +	return 0;
>  }
>  #endif
