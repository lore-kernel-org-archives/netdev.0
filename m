From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] net: ping: fix build failure
Date: Tue, 17 May 2011 08:41:25 -0700
Message-ID: <20110517084125.77b543c8.randy.dunlap@oracle.com>
References: <20110516151019.be338f1c.sfr@canb.auug.org.au>
	<20110516123534.5d3a51b9.randy.dunlap@oracle.com>
	<20110516.153844.1072050131335197211.davem@davemloft.net>
	<20110517101656.GA28685@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, randy.dunlap@oracle.com,
	sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110517101656.GA28685@albatros>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 May 2011 14:16:56 +0400 Vasiliy Kulikov wrote:

> On Mon, May 16, 2011 at 15:38 -0400, David Miller wrote:
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > Date: Mon, 16 May 2011 12:35:34 -0700
> > 
> > > On Mon, 16 May 2011 15:10:19 +1000 Stephen Rothwell wrote:
> > > when CONFIG_PROC_SYSCTL is not enabled:
> > > 
> > > ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group_range_net'
> > 
> > Vasiliy, please fix this.
> 
> I wonder whether there is any way to test such unusual configurations?
> Only randconfig or are there any (partly-)automated tools for it?
> 
> 
> [PATCH] net: ping: fix build failure
> 
> If CONFIG_PROC_SYSCTL=n the building process fails:
> 
>     ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group_range_net'
> 
> Moved inet_get_ping_group_range_net() to ping.c.
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
>  include/net/ping.h         |    2 --
>  net/ipv4/ping.c            |   13 +++++++++++++
>  net/ipv4/sysctl_net_ipv4.c |   12 ------------
>  3 files changed, 13 insertions(+), 14 deletions(-)
> 
> diff --git a/include/net/ping.h b/include/net/ping.h
> index 23062c3..682b5ae 100644
> --- a/include/net/ping.h
> +++ b/include/net/ping.h
> @@ -44,8 +44,6 @@ extern struct proto ping_prot;
>  extern void ping_rcv(struct sk_buff *);
>  extern void ping_err(struct sk_buff *, u32 info);
>  
> -extern void inet_get_ping_group_range_net(struct net *net, unsigned int *low, unsigned int *high);
> -
>  #ifdef CONFIG_PROC_FS
>  extern int __init ping_proc_init(void);
>  extern void ping_proc_exit(void);
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 7041d09..3635975 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -188,6 +188,19 @@ exit:
>  	return sk;
>  }
>  
> +static void inet_get_ping_group_range_net(struct net *net, gid_t *low, gid_t *high)
> +{
> +	gid_t *data = net->ipv4.sysctl_ping_group_range;
> +	unsigned seq;
> +	do {
> +		seq = read_seqbegin(&sysctl_local_ports.lock);
> +
> +		*low = data[0];
> +		*high = data[1];
> +	} while (read_seqretry(&sysctl_local_ports.lock, seq));
> +}
> +
> +
>  static int ping_init_sock(struct sock *sk)
>  {
>  	struct net *net = sock_net(sk);
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 28e8273..57d0752 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -73,18 +73,6 @@ static int ipv4_local_port_range(ctl_table *table, int write,
>  }
>  
>  
> -void inet_get_ping_group_range_net(struct net *net, gid_t *low, gid_t *high)
> -{
> -	gid_t *data = net->ipv4.sysctl_ping_group_range;
> -	unsigned seq;
> -	do {
> -		seq = read_seqbegin(&sysctl_local_ports.lock);
> -
> -		*low = data[0];
> -		*high = data[1];
> -	} while (read_seqretry(&sysctl_local_ports.lock, seq));
> -}
> -
>  void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low, gid_t *high)
>  {
>  	gid_t *data = table->data;
> -- 
> 1.7.0.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-next" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
