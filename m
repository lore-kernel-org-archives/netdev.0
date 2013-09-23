From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] net ipv4: Convert ipv4.ip_local_port_range to
 be per netns
Date: Mon, 23 Sep 2013 15:43:25 +0200
Message-ID: <5240457D.2050101@6wind.com>
References: <87fvswt5m5.fsf@tw-ebiederman.twitter.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34812 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410Ab3IWNn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 09:43:28 -0400
Received: by mail-wg0-f45.google.com with SMTP id y10so3142044wgg.0
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 06:43:27 -0700 (PDT)
In-Reply-To: <87fvswt5m5.fsf@tw-ebiederman.twitter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/09/2013 08:27, Eric W. Biederman a =C3=A9crit :
>
> - Move sysctl_local_ports from a global variable into struct netns_ip=
v4.
> - Modify inet_get_local_port_range to take a struct net.
> - Manually expand inet_get_local_range into ipv4_local_port_range
>    because I do not know the struct net.
> - Move the initialization of sysctl_local_ports into
>    sysctl_net_ipv4.c:ipv4_sysctl_init_net from inet_connection_sock.c
>
> Originally-by: Samya <samya@twitter.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Two minor comments, please see below.
After that: Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> ---
>   drivers/infiniband/core/cma.c   |    2 +-
>   drivers/net/vxlan.c             |    2 +-
>   include/net/ip.h                |    7 +----
>   include/net/netns/ipv4.h        |    6 +++++
>   net/ipv4/inet_connection_sock.c |   20 +++++---------
>   net/ipv4/inet_hashtables.c      |    2 +-
>   net/ipv4/ping.c                 |    4 +--
>   net/ipv4/sysctl_net_ipv4.c      |   57 ++++++++++++++++++++++++++--=
-----------
>   net/ipv4/udp.c                  |    2 +-
>   net/sctp/socket.c               |    2 +-
>   security/selinux/hooks.c        |    3 ++-
>   11 files changed, 61 insertions(+), 46 deletions(-)
>
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/=
cma.c
> index 7c0f953..9627545 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -2302,7 +2302,7 @@ static int cma_alloc_any_port(struct idr *ps, s=
truct rdma_id_private *id_priv)
>   	int low, high, remaining;
>   	unsigned int rover;
>
> -	inet_get_local_port_range(&low, &high);
> +	inet_get_local_port_range(&init_net, &low, &high);
>   	remaining =3D (high - low) + 1;
>   	rover =3D net_random() % remaining + low;
>   retry:
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 767f7af..a105376 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1501,7 +1501,7 @@ static void vxlan_setup(struct net_device *dev)
>   	vxlan->age_timer.function =3D vxlan_cleanup;
>   	vxlan->age_timer.data =3D (unsigned long) vxlan;
>
> -	inet_get_local_port_range(&low, &high);
> +	inet_get_local_port_range(dev_net(net), &low, &high);
>   	vxlan->port_min =3D low;
>   	vxlan->port_max =3D high;
>   	vxlan->dst_port =3D htons(vxlan_port);
> diff --git a/include/net/ip.h b/include/net/ip.h
> index a68f838..5e46435 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -195,12 +195,7 @@ static inline u64 snmp_fold_field64(void __percp=
u *mib[], int offt, size_t syncp
>   #endif
>   extern int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, siz=
e_t align);
>   extern void snmp_mib_free(void __percpu *ptr[2]);
> -
> -extern struct local_ports {
> -	seqlock_t	lock;
> -	int		range[2];
> -} sysctl_local_ports;
> -extern void inet_get_local_port_range(int *low, int *high);
> +extern void inet_get_local_port_range(struct net *net, int *low, int=
 *high);
>
>   extern unsigned long *sysctl_local_reserved_ports;
>   static inline int inet_is_reserved_local_port(int port)
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index 2ba9de8..d685e50 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -15,6 +15,10 @@ struct fib_rules_ops;
>   struct hlist_head;
>   struct fib_table;
>   struct sock;
> +struct local_ports {
> +	seqlock_t	lock;
> +	int		range[2];
> +};
>
>   struct netns_ipv4 {
>   #ifdef CONFIG_SYSCTL
> @@ -62,6 +66,8 @@ struct netns_ipv4 {
>   	int sysctl_icmp_ratemask;
>   	int sysctl_icmp_errors_use_inbound_ifaddr;
>
> +	struct local_ports sysctl_local_ports;
> +
>   	int sysctl_tcp_ecn;
>
>   	kgid_t sysctl_ping_group_range[2];
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 6acb541..7ac7aa1 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -29,27 +29,19 @@ const char inet_csk_timer_bug_msg[] =3D "inet_csk=
 BUG: unknown timer value\n";
>   EXPORT_SYMBOL(inet_csk_timer_bug_msg);
>   #endif
>
> -/*
> - * This struct holds the first and last local port number.
> - */
> -struct local_ports sysctl_local_ports __read_mostly =3D {
> -	.lock =3D __SEQLOCK_UNLOCKED(sysctl_local_ports.lock),
> -	.range =3D { 32768, 61000 },
> -};
> -
>   unsigned long *sysctl_local_reserved_ports;
>   EXPORT_SYMBOL(sysctl_local_reserved_ports);
>
> -void inet_get_local_port_range(int *low, int *high)
> +void inet_get_local_port_range(struct net *net, int *low, int *high)
>   {
>   	unsigned int seq;
>
>   	do {
> -		seq =3D read_seqbegin(&sysctl_local_ports.lock);
> +		seq =3D read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
>
> -		*low =3D sysctl_local_ports.range[0];
> -		*high =3D sysctl_local_ports.range[1];
> -	} while (read_seqretry(&sysctl_local_ports.lock, seq));
> +		*low =3D net->ipv4.sysctl_local_ports.range[0];
> +		*high =3D net->ipv4.sysctl_local_ports.range[1];
> +	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
>   }
>   EXPORT_SYMBOL(inet_get_local_port_range);
>
> @@ -116,7 +108,7 @@ int inet_csk_get_port(struct sock *sk, unsigned s=
hort snum)
>   		int remaining, rover, low, high;
>
>   again:
> -		inet_get_local_port_range(&low, &high);
> +		inet_get_local_port_range(net, &low, &high);
>   		remaining =3D (high - low) + 1;
>   		smallest_rover =3D rover =3D net_random() % remaining + low;
>
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index 7bd8983..2779037 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -494,7 +494,7 @@ int __inet_hash_connect(struct inet_timewait_deat=
h_row *death_row,
>   		u32 offset =3D hint + port_offset;
>   		struct inet_timewait_sock *tw =3D NULL;
>
> -		inet_get_local_port_range(&low, &high);
> +		inet_get_local_port_range(net, &low, &high);
>   		remaining =3D (high - low) + 1;
>
>   		local_bh_disable();
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 746427c..d71ecc4 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -237,11 +237,11 @@ static void inet_get_ping_group_range_net(struc=
t net *net, kgid_t *low,
>   	unsigned int seq;
>
>   	do {
> -		seq =3D read_seqbegin(&sysctl_local_ports.lock);
> +		seq =3D read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
>
>   		*low =3D data[0];
>   		*high =3D data[1];
> -	} while (read_seqretry(&sysctl_local_ports.lock, seq));
> +	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
>   }
>
>
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 610e324..b91f963 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -42,12 +42,12 @@ static int ip_ping_group_range_min[] =3D { 0, 0 }=
;
>   static int ip_ping_group_range_max[] =3D { GID_T_MAX, GID_T_MAX };
>
>   /* Update system visible IP port range */
> -static void set_local_port_range(int range[2])
> +static void set_local_port_range(struct local_ports *ports, int rang=
e[2])
>   {
> -	write_seqlock(&sysctl_local_ports.lock);
> -	sysctl_local_ports.range[0] =3D range[0];
> -	sysctl_local_ports.range[1] =3D range[1];
> -	write_sequnlock(&sysctl_local_ports.lock);
> +	write_seqlock(&ports->lock);
> +	ports->range[0] =3D range[0];
> +	ports->range[1] =3D range[1];
> +	write_sequnlock(&ports->lock);
>   }
>
>   /* Validate changes from /proc interface. */
> @@ -55,6 +55,9 @@ static int ipv4_local_port_range(struct ctl_table *=
table, int write,
>   				 void __user *buffer,
>   				 size_t *lenp, loff_t *ppos)
>   {
> +	struct local_ports *ports =3D
> +		container_of(table->data, struct local_ports, range);
> +	unsigned int seq;
>   	int ret;
>   	int range[2];
>   	struct ctl_table tmp =3D {
> @@ -65,14 +68,19 @@ static int ipv4_local_port_range(struct ctl_table=
 *table, int write,
>   		.extra2 =3D &ip_local_port_range_max,
>   	};
>
> -	inet_get_local_port_range(range, range + 1);
> +	do {
> +		seq =3D read_seqbegin(&ports->lock);
> +		range[0] =3D ports->range[0];
> +		range[1] =3D ports->range[1];
> +	} while (read_seqretry(&ports->lock, seq));
> +
>   	ret =3D proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
>
>   	if (write && ret =3D=3D 0) {
>   		if (range[1] < range[0])
>   			ret =3D -EINVAL;
>   		else
> -			set_local_port_range(range);
> +			set_local_port_range(ports, range);
>   	}
>
>   	return ret;
> @@ -82,23 +90,27 @@ static int ipv4_local_port_range(struct ctl_table=
 *table, int write,
>   static void inet_get_ping_group_range_table(struct ctl_table *table=
, kgid_t *low, kgid_t *high)
>   {
>   	kgid_t *data =3D table->data;
> +        struct netns_ipv4 *ipv4 =3D
There is spaces here instead of tabs.
> +		container_of(table->data, struct netns_ipv4, sysctl_ping_group_ran=
ge);
>   	unsigned int seq;
>   	do {
> -		seq =3D read_seqbegin(&sysctl_local_ports.lock);
> +		seq =3D read_seqbegin(&ipv4->sysctl_local_ports.lock);
>
>   		*low =3D data[0];
>   		*high =3D data[1];
> -	} while (read_seqretry(&sysctl_local_ports.lock, seq));
> +	} while (read_seqretry(&ipv4->sysctl_local_ports.lock, seq));
>   }
>
>   /* Update system visible IP port range */
>   static void set_ping_group_range(struct ctl_table *table, kgid_t lo=
w, kgid_t high)
>   {
>   	kgid_t *data =3D table->data;
> -	write_seqlock(&sysctl_local_ports.lock);
> +        struct netns_ipv4 *ipv4 =3D
Same here.
