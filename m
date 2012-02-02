From: Glauber Costa <glommer@parallels.com>
Subject: Re: [v3.3-rc2+ PATCH] tcp: properly initialize tcp memory limits
Date: Thu, 2 Feb 2012 14:39:26 +0400
Message-ID: <4F2A67DE.1000909@parallels.com>
References: <20120202100700.38694.80000.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120202100700.38694.80000.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/02/2012 02:07 PM, Jason Wang wrote:
> Commit 4acb4190 tries to fix the using uninitialized value
> introduced by commit 3dc43e3,  but it would make the
> per-socket memory limits too small.
>
> This patch fixes this and also remove the redundant codes
> introduced in 4acb4190.
>
> Signed-off-by: Jason Wang<jasowang@redhat.com>
Acked-by: Glauber Costa <glommer@parallels.com>

> ---
>   net/ipv4/sysctl_net_ipv4.c |    5 -----
>   net/ipv4/tcp.c             |    4 ++--
>   2 files changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 4cb9cd2..1eb8caa 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -815,11 +815,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
>   	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
>
>   	tcp_init_mem(net);
> -	limit = nr_free_buffer_pages() / 8;
> -	limit = max(limit, 128UL);
> -	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
> -	net->ipv4.sysctl_tcp_mem[1] = limit;
> -	net->ipv4.sysctl_tcp_mem[2] = net->ipv4.sysctl_tcp_mem[0] * 2;
>
>   	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
>   			net_ipv4_ctl_path, table);
Ok, this is indeed a good change, since we avoid initializing it twice.

> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 06373b4..3a7514b 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -3218,7 +3218,6 @@ __setup("thash_entries=", set_thash_entries);
>
>   void tcp_init_mem(struct net *net)
>   {
> -	/* Set per-socket limits to no more than 1/128 the pressure threshold */
>   	unsigned long limit = nr_free_buffer_pages() / 8;
>   	limit = max(limit, 128UL);
>   	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
> @@ -3287,7 +3286,8 @@ void __init tcp_init(void)
>   	sysctl_max_syn_backlog = max(128, cnt / 256);
>
>   	tcp_init_mem(&init_net);
> -	limit = nr_free_buffer_pages() / 8;
> +	/* Set per-socket limits to no more than 1/128 the pressure threshold */
> +	limit = nr_free_buffer_pages()<<  (PAGE_SHIFT - 10);
>   	limit = max(limit, 128UL);
>   	max_share = min(4UL*1024*1024, limit);

Indeed, this ends up influencing the value of max_share used below to 
initialize the other fields.
I like your change because now the limit variable is being set 
independently between the global (now per-cgroup) and the per-socket 
limits. (it previously was limit = sysctl_tcp_mem[1] << (PAGE_SHIFT-7))

So in the end, I personally think this is even clearer than what we had 
before.

Acked-by: Glauber Costa <glommer@parallels.com>
