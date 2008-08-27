From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Wed, 27 Aug 2008 09:41:04 -0700
Message-ID: <20080827094104.63375aa5@extreme>
References: <48B5815D.4010005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37424 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282AbYH0QlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 12:41:05 -0400
In-Reply-To: <48B5815D.4010005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008 20:31:25 +0400
Pavel Emelyanov <xemul@openvz.org> wrote:

> After turning IP_XXX_STATS, TCP_XXX_STATS and NET_XXX_STATS from
> macros into functions the net/ipv4/built-in.o shrank significantly:
> 
> add/remove: 14/0 grow/shrink: 0/67 up/down: 482/-2246 (-1764)
> 
> Turning the CONFIG_NET_NS option on makes this shrink even larger:
> 
> add/remove: 14/0 grow/shrink: 0/67 up/down: 478/-2646 (-2168)
> 
> So the question is - what was the reason to keep those as macros?
> I thought about the possible performance questions, but netperf
> didn't show any (I admit I just cannot cook it properly).
> 
> The sample patch is here, but it's not good (EXPORTs for ipv6
> and a better place for functions rather than net/ipv4/af_inet.c
> are required).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 250e6ef..ad8ef7b 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -156,14 +156,16 @@ struct ipv4_config
>  };
>  
>  extern struct ipv4_config ipv4_config;
> -#define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statistics, field)
> -#define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field)
> -#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val)
> -#define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
> -#define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
> -#define NET_INC_STATS_USER(net, field) 	SNMP_INC_STATS_USER((net)->mib.net_statistics, field)
> -#define NET_ADD_STATS_BH(net, field, adnd) SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd)
> -#define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
> +
> +void IP_INC_STATS(struct net *net, int field);
> +void IP_INC_STATS_BH(struct net *net, int field);
> +void IP_ADD_STATS_BH(struct net *net, int field, int val);
> +
> +void NET_INC_STATS(struct net *net, int field);
> +void NET_INC_STATS_BH(struct net *net, int field);
> +void NET_INC_STATS_USER(struct net *net, int field);
> +void NET_ADD_STATS_BH(struct net *net, int field, int val);
> +void NET_ADD_STATS_USER(struct net *net, int field, int val);
>  
>  extern unsigned long snmp_fold_field(void *mib[], int offt);
>  extern int snmp_mib_init(void *ptr[2], size_t mibsize);
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 8983386..b973e68 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -267,10 +267,10 @@ static inline int tcp_too_many_orphans(struct sock *sk, int num)
>  
>  extern struct proto tcp_prot;
>  
> -#define TCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.tcp_statistics, field)
> -#define TCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field)
> -#define TCP_DEC_STATS(net, field)	SNMP_DEC_STATS((net)->mib.tcp_statistics, field)
> -#define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
> +void TCP_INC_STATS(struct net *net, int field);
> +void TCP_INC_STATS_BH(struct net *net, int field);
> +void TCP_DEC_STATS(struct net *net, int field);
> +void TCP_ADD_STATS_USER(struct net *net, int field, int val);
>  
>  extern void			tcp_v4_err(struct sk_buff *skb, u32);
>  
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 8a3ac1f..413adda 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1580,3 +1580,63 @@ EXPORT_SYMBOL(inet_stream_connect);
>  EXPORT_SYMBOL(inet_stream_ops);
>  EXPORT_SYMBOL(inet_unregister_protosw);
>  EXPORT_SYMBOL(sysctl_ip_nonlocal_bind);
> +
> +void NET_INC_STATS(struct net *net, int field)
> +{
> +	SNMP_INC_STATS((net)->mib.net_statistics, field);
> +}
> +
> +void NET_INC_STATS_BH(struct net *net, int field)
> +{
> +	SNMP_INC_STATS_BH((net)->mib.net_statistics, field);
> +}
> +
> +void NET_INC_STATS_USER(struct net *net, int field)
> +{
> +	SNMP_INC_STATS_USER((net)->mib.net_statistics, field);
> +}
> +
> +void NET_ADD_STATS_BH(struct net *net, int field, int adnd)
> +{
> +	SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd);
> +}
> +
> +void NET_ADD_STATS_USER(struct net *net, int field, int adnd)
> +{
> +	SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd);
> +}
> +
> +void IP_INC_STATS(struct net *net, int field)
> +{
> +	SNMP_INC_STATS((net)->mib.ip_statistics, field);
> +}
> +
> +void IP_INC_STATS_BH(struct net *net, int field)
> +{
> +	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field);
> +}
> +
> +void IP_ADD_STATS_BH(struct net *net, int field, int val)
> +{
> +	SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val);
> +}
> +
> +void TCP_INC_STATS(struct net *net, int field)
> +{
> +	SNMP_INC_STATS((net)->mib.tcp_statistics, field);
> +}
> +
> +void TCP_INC_STATS_BH(struct net *net, int field)
> +{
> +	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field);
> +}
> +
> +void TCP_DEC_STATS(struct net *net, int field)
> +{
> +	SNMP_DEC_STATS((net)->mib.tcp_statistics, field);
> +}
> +
> +void TCP_ADD_STATS_USER(struct net *net, int field, int val)
> +{
> +	SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val);

Change function names to lower case please.
