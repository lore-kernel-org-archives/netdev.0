From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 3/3] net: reserve ports for applications using
 fixed port numbers
Date: Sat, 20 Feb 2010 16:20:53 +0800
Message-ID: <4B7F9B65.1060309@redhat.com>
References: <1266532210-11536-1-git-send-email-opurdila@ixiacom.com> <1266532210-11536-3-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266532210-11536-3-git-send-email-opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila wrote:
> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
> allows users to reserve ports for third-party applications.
> 
> The reserved ports will not be used by automatic port assignments
> (e.g. when calling connect() or bind() with port number 0). Explicit
> port allocation behavior is unchanged.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  Documentation/networking/ip-sysctl.txt |   14 ++++++++++++++
>  drivers/infiniband/core/cma.c          |    7 ++++++-
>  include/net/ip.h                       |    6 ++++++
>  net/ipv4/af_inet.c                     |    8 +++++++-
>  net/ipv4/inet_connection_sock.c        |    6 ++++++
>  net/ipv4/inet_hashtables.c             |    2 ++
>  net/ipv4/sysctl_net_ipv4.c             |   17 +++++++++++++++++
>  net/ipv4/udp.c                         |    3 ++-
>  net/sctp/socket.c                      |    2 ++
>  9 files changed, 62 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 2dc7a1d..6534ee7 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -564,6 +564,20 @@ ip_local_port_range - 2 INTEGERS
>  	(i.e. by default) range 1024-4999 is enough to issue up to
>  	2000 connections per second to systems supporting timestamps.
>  
> +ip_local_reserved_ports - list of comma separated ranges
> +	Specify the ports which are reserved for known third-party
> +	applications. These ports will not be used by automatic port
> +	assignments (e.g. when calling connect() or bind() with port
> +	number 0). Explicit port allocation behavior is unchanged.
> +
> +	The format used for both input and output is a comma separated
> +	list of ranges (e.g. "1,2-4,10-10" for ports 1, 2, 3, 4 and
> +	10). Writing to the file will clear all previously reserved
> +	ports and update the current list with the one given in the
> +	input.
> +
> +	Default: Empty
> +
>  ip_nonlocal_bind - BOOLEAN
>  	If set, allows processes to bind() to non-local IP addresses,
>  	which can be quite useful - but may break some applications.
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
> index 875e34e..06c9fa5 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -1979,6 +1979,8 @@ retry:
>  	/* FIXME: add proper port randomization per like inet_csk_get_port */
>  	do {
>  		ret = idr_get_new_above(ps, bind_list, next_port, &port);
> +		if (inet_is_reserved_local_port(port))
> +			ret = -EAGAIN;
>  	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
>  
>  	if (ret)
> @@ -2995,10 +2997,13 @@ static int __init cma_init(void)
>  {
>  	int ret, low, high, remaining;
>  
> -	get_random_bytes(&next_port, sizeof next_port);
>  	inet_get_local_port_range(&low, &high);
> +again:
> +	get_random_bytes(&next_port, sizeof next_port);
>  	remaining = (high - low) + 1;
>  	next_port = ((unsigned int) next_port % remaining) + low;
> +	if (inet_is_reserved_local_port(next_port))
> +		goto again;
>  
>  	cma_wq = create_singlethread_workqueue("rdma_cm");
>  	if (!cma_wq)
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 503994a..3da9004 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -184,6 +184,12 @@ extern struct local_ports {
>  } sysctl_local_ports;
>  extern void inet_get_local_port_range(int *low, int *high);
>  
> +extern unsigned long *sysctl_local_reserved_ports;
> +static inline int inet_is_reserved_local_port(int port)
> +{
> +	return test_bit(port, sysctl_local_reserved_ports);
> +}
> +
>  extern int sysctl_ip_default_ttl;
>  extern int sysctl_ip_nonlocal_bind;
>  
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 33b7dff..e283fbe 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1546,9 +1546,13 @@ static int __init inet_init(void)
>  
>  	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));
>  
> +	sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
> +	if (!sysctl_local_reserved_ports)
> +		goto out;
> +
>  	rc = proto_register(&tcp_prot, 1);
>  	if (rc)
> -		goto out;
> +		goto out_free_reserved_ports;
>  
>  	rc = proto_register(&udp_prot, 1);
>  	if (rc)
> @@ -1647,6 +1651,8 @@ out_unregister_udp_proto:
>  	proto_unregister(&udp_prot);
>  out_unregister_tcp_proto:
>  	proto_unregister(&tcp_prot);
> +out_free_reserved_ports:
> +	kfree(sysctl_local_reserved_ports);
>  	goto out;
>  }
>  
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index 8da6429..1acb462 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -37,6 +37,9 @@ struct local_ports sysctl_local_ports __read_mostly = {
>  	.range = { 32768, 61000 },
>  };
>  
> +unsigned long *sysctl_local_reserved_ports;
> +EXPORT_SYMBOL(sysctl_local_reserved_ports);
> +

Sorry, this looks somewhat weird, why not just export
inet_is_reserved_local_port()?
