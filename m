From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 04/13] ip_tunnels: add IPv6 addresses to
 ip_tunnel_key
Date: Tue, 18 Aug 2015 17:36:32 -0700
Message-ID: <20150819003632.GA989@Alexeis-MacBook-Pro-2.local>
References: <cover.1439929916.git.jbenc@redhat.com>
 <199ae8362eabd65661ab145e9bfc281c5f5470ad.1439929916.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36320 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbbHSAgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 20:36:36 -0400
Received: by pawq9 with SMTP id q9so46841845paw.3
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 17:36:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <199ae8362eabd65661ab145e9bfc281c5f5470ad.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 10:33:13PM +0200, Jiri Benc wrote:
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/vxlan.c            |  6 +++---
>  include/net/ip_tunnels.h       | 23 +++++++++++++++++++----
>  net/core/filter.c              |  4 ++--
>  net/ipv4/ip_gre.c              | 10 +++++-----
>  net/ipv4/ip_tunnel_core.c      |  8 ++++----
>  net/openvswitch/flow_netlink.c | 18 +++++++++---------
>  net/openvswitch/flow_table.c   |  2 +-
>  net/openvswitch/vport-geneve.c |  2 +-
>  net/openvswitch/vport.c        |  2 +-
>  net/openvswitch/vport.h        |  4 ++--
>  10 files changed, 47 insertions(+), 32 deletions(-)

please add commit message. +47 -32 cannot be empty.

> +/* Used to memset ipv4 address padding. */
> +#define IP_TUNNEL_KEY_IPV4_PAD	offsetofend(struct ip_tunnel_key, u.ipv4.dst)
> +#define IP_TUNNEL_KEY_IPV4_PAD_LEN				\
> +	(FIELD_SIZEOF(struct ip_tunnel_key, u) - IP_TUNNEL_KEY_IPV4_PAD)
> +
>  struct ip_tunnel_key {
>  	__be64			tun_id;
> -	__be32			ipv4_src;
> -	__be32			ipv4_dst;
> +	union {
> +		struct {
> +			__be32	src;
> +			__be32	dst;
> +		} ipv4;
> +		struct {
> +			struct in6_addr src;
> +			struct in6_addr dst;
> +		} ipv6;
> +	} u;
...
> +	tun_info->key.u.ipv4.src = saddr;
> +	tun_info->key.u.ipv4.dst = daddr;
> +	memset((unsigned char *)&tun_info->key + IP_TUNNEL_KEY_IPV4_PAD,
> +	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);

the math looks wrong.
IP_TUNNEL_KEY_IPV4_PAD_LEN = sizeof(u) - offsetofend(u.ipv4.dst)
8 byte mistake?
