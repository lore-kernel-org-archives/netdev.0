From: Horms <horms@verge.net.au>
Subject: Re: [PATCH] [IPVS] add a sysctl variable to expire quiescent template
Date: Thu, 2 Dec 2004 13:07:20 +0900
Message-ID: <20041202040717.GF32190@verge.net.au>
References: <Pine.LNX.4.61.0412020045380.1073@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0412020045380.1073@penguin.linux-vs.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 02, 2004 at 12:48:26AM +0800, Wensong Zhang wrote:
> 
> 
> Hi Dave,
> 
> Here is the patch from Horms <horms@vergenet.net> to add a sysctl 
> variable to expire quiescent templat. Please check and apply them to
> kernel 2.4 and 2.6 respectively.
> 
> Thanks,
> 
> Wensong

I can do this too, just in case you need it.

Signed-off-by: Horms <horms@verge.net.au>

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/12/02 00:02:48+08:00 wensong@linux-vs.org 
> #   [IPVS] add a sysctl variable to expire quiescent template
> #   
> #   The patch is from Horms <horms@vergenet.net>
> # 
> # net/ipv4/ipvs/ip_vs_ctl.c
> #   2004/12/02 00:02:38+08:00 wensong@linux-vs.org +4 -0
> #   set sysctl_ip_vs_expire_quiescent_template
> # 
> # net/ipv4/ipvs/ip_vs_conn.c
> #   2004/12/02 00:02:37+08:00 wensong@linux-vs.org +3 -1
> #   don't use quiescent template if the expire_quiescent_template is enabled
> # 
> # include/net/ip_vs.h
> #   2004/12/02 00:02:37+08:00 wensong@linux-vs.org +2 -0
> #   add the sysctl_ip_vs_expire_quiescent_template
> # 
> diff -Nru a/include/net/ip_vs.h b/include/net/ip_vs.h
> --- a/include/net/ip_vs.h	2004-12-02 00:16:36 +08:00
> +++ b/include/net/ip_vs.h	2004-12-02 00:16:36 +08:00
> @@ -317,6 +317,7 @@
>  	NET_IPV4_VS_EXPIRE_NODEST_CONN=23,
>  	NET_IPV4_VS_SYNC_THRESHOLD=24,
>  	NET_IPV4_VS_NAT_ICMP_SEND=25,
> +	NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE=26,
>  	NET_IPV4_VS_LAST
>  };
>  
> @@ -700,6 +701,7 @@
>   */
>  extern int sysctl_ip_vs_cache_bypass;
>  extern int sysctl_ip_vs_expire_nodest_conn;
> +extern int sysctl_ip_vs_expire_quiescent_template;
>  extern int sysctl_ip_vs_sync_threshold;
>  extern int sysctl_ip_vs_nat_icmp_send;
>  extern struct ip_vs_stats ip_vs_stats;
> diff -Nru a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
> --- a/net/ipv4/ipvs/ip_vs_conn.c	2004-12-02 00:16:36 +08:00
> +++ b/net/ipv4/ipvs/ip_vs_conn.c	2004-12-02 00:16:36 +08:00
> @@ -1131,7 +1131,9 @@
>  	 * Checking the dest server status.
>  	 */
>  	if ((dest == NULL) ||
> -	    !(dest->flags & IP_VS_DEST_F_AVAILABLE)) {
> +	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) || 
> +	    (sysctl_ip_vs_expire_quiescent_template && 
> +	     (atomic_read(&dest->weight) == 0))) {
>  		IP_VS_DBG(9, "check_template: dest not available for "
>  			  "protocol %s s:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
>  			  "-> d:%u.%u.%u.%u:%d\n",
> diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> --- a/net/ipv4/ipvs/ip_vs_ctl.c	2004-12-02 00:16:36 +08:00
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c	2004-12-02 00:16:36 +08:00
> @@ -74,6 +74,7 @@
>  static int sysctl_ip_vs_am_droprate = 10;
>  int sysctl_ip_vs_cache_bypass = 0;
>  int sysctl_ip_vs_expire_nodest_conn = 0;
> +int sysctl_ip_vs_expire_quiescent_template = 0;
>  int sysctl_ip_vs_sync_threshold = 3;
>  int sysctl_ip_vs_nat_icmp_send = 0;
>  
> @@ -1439,6 +1440,9 @@
>  	  &proc_dointvec},
>  	 {NET_IPV4_VS_NAT_ICMP_SEND, "nat_icmp_send",
>  	  &sysctl_ip_vs_nat_icmp_send, sizeof(int), 0644, NULL,
> +	  &proc_dointvec},
> +	 {NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE, "expire_quiescent_template",
> +	  &sysctl_ip_vs_expire_quiescent_template, sizeof(int), 0644, NULL,
>  	  &proc_dointvec},
>  	 {0}},
>  	{{NET_IPV4_VS, "vs", NULL, 0, 0555, ipv4_vs_table.vs_vars},

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/12/02 00:42:15+08:00 wensong@linux-vs.org 
> #   [IPVS] add a sysctl variable to expire quiescent template
> #   
> #   The patch is from Horms <horms@vergenet.net>
> # 
> # net/ipv4/ipvs/ip_vs_ctl.c
> #   2004/12/02 00:41:56+08:00 wensong@linux-vs.org +20 -11
> #   set the sysctl_ip_vs_expire_quiescent_template
> # 
> # net/ipv4/ipvs/ip_vs_conn.c
> #   2004/12/02 00:41:56+08:00 wensong@linux-vs.org +3 -1
> #   don't use quiescent template if the expire_quiescent_template is enabled
> # 
> # include/net/ip_vs.h
> #   2004/12/02 00:41:56+08:00 wensong@linux-vs.org +2 -0
> #   add the sysctl_ip_vs_expire_quiescent_template prototype
> # 
> diff -Nru a/include/net/ip_vs.h b/include/net/ip_vs.h
> --- a/include/net/ip_vs.h	2004-12-02 00:43:14 +08:00
> +++ b/include/net/ip_vs.h	2004-12-02 00:43:14 +08:00
> @@ -358,6 +358,7 @@
>  	NET_IPV4_VS_EXPIRE_NODEST_CONN=23,
>  	NET_IPV4_VS_SYNC_THRESHOLD=24,
>  	NET_IPV4_VS_NAT_ICMP_SEND=25,
> +	NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE=26,
>  	NET_IPV4_VS_LAST
>  };
>  
> @@ -879,6 +880,7 @@
>   */
>  extern int sysctl_ip_vs_cache_bypass;
>  extern int sysctl_ip_vs_expire_nodest_conn;
> +extern int sysctl_ip_vs_expire_quiescent_template;
>  extern int sysctl_ip_vs_sync_threshold[2];
>  extern int sysctl_ip_vs_nat_icmp_send;
>  extern struct ip_vs_stats ip_vs_stats;
> diff -Nru a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
> --- a/net/ipv4/ipvs/ip_vs_conn.c	2004-12-02 00:43:14 +08:00
> +++ b/net/ipv4/ipvs/ip_vs_conn.c	2004-12-02 00:43:14 +08:00
> @@ -453,7 +453,9 @@
>  	 * Checking the dest server status.
>  	 */
>  	if ((dest == NULL) ||
> -	    !(dest->flags & IP_VS_DEST_F_AVAILABLE)) {
> +	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) || 
> +	    (sysctl_ip_vs_expire_quiescent_template && 
> +	     (atomic_read(&dest->weight) == 0))) {
>  		IP_VS_DBG(9, "check_template: dest not available for "
>  			  "protocol %s s:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
>  			  "-> d:%u.%u.%u.%u:%d\n",
> diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> --- a/net/ipv4/ipvs/ip_vs_ctl.c	2004-12-02 00:43:14 +08:00
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c	2004-12-02 00:43:14 +08:00
> @@ -75,6 +75,7 @@
>  static int sysctl_ip_vs_am_droprate = 10;
>  int sysctl_ip_vs_cache_bypass = 0;
>  int sysctl_ip_vs_expire_nodest_conn = 0;
> +int sysctl_ip_vs_expire_quiescent_template = 0;
>  int sysctl_ip_vs_sync_threshold[2] = { 3, 50 };
>  int sysctl_ip_vs_nat_icmp_send = 0;
>  
> @@ -1447,9 +1448,9 @@
>  	{
>  		.ctl_name	= NET_IPV4_VS_TO_ES,
>  		.procname	= "timeout_established",
> -	  	.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
> +		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1457,7 +1458,7 @@
>  		.procname	= "timeout_synsent",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_SENT],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1465,7 +1466,7 @@
>  		.procname	= "timeout_synrecv",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_RECV],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1473,7 +1474,7 @@
>  		.procname	= "timeout_finwait",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_FIN_WAIT],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1489,7 +1490,7 @@
>  		.procname	= "timeout_close",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1497,7 +1498,7 @@
>  		.procname	= "timeout_closewait",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE_WAIT],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1505,7 +1506,7 @@
>  		.procname	= "timeout_lastack",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LAST_ACK],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1513,7 +1514,7 @@
>  		.procname	= "timeout_listen",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LISTEN],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1521,7 +1522,7 @@
>  		.procname	= "timeout_synack",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYNACK],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1529,7 +1530,7 @@
>  		.procname	= "timeout_udp",
>  		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_UDP],
>  		.maxlen		= sizeof(int),
> -		.mode		= 0644, 
> +		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  	},
>  	{
> @@ -1553,6 +1554,14 @@
>  		.ctl_name	= NET_IPV4_VS_EXPIRE_NODEST_CONN,
>  		.procname	= "expire_nodest_conn",
>  		.data		= &sysctl_ip_vs_expire_nodest_conn,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec,
> +	},
> +	{
> +		.ctl_name	= NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE,
> +		.procname	= "expire_quiescent_template",
> +		.data		= &sysctl_ip_vs_expire_quiescent_template,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec,


-- 
Horms
