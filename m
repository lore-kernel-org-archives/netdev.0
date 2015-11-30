From: Jason Baron <jbaron-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 09/13] mm: memcontrol: generalize the socket accounting
 jump label
Date: Mon, 30 Nov 2015 16:08:18 -0500
Message-ID: <565CBAC2.3080804@akamai.com>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	"peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448401925-22501-10-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 11/24/2015 04:52 PM, Johannes Weiner wrote:
> The unified hierarchy memory controller is going to use this jump
> label as well to control the networking callbacks. Move it to the
> memory controller code and give it a more generic name.
> 
> Signed-off-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Acked-by: Michal Hocko <mhocko-IBi9RG/b67k@public.gmane.org>
> Reviewed-by: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
> ---
>  include/linux/memcontrol.h | 4 ++++
>  include/net/sock.h         | 7 -------
>  mm/memcontrol.c            | 3 +++
>  net/core/sock.c            | 5 -----
>  net/ipv4/tcp_memcontrol.c  | 4 ++--
>  5 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d99fefe..dad56ef 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -681,6 +681,8 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
>  
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  struct sock;
> +extern struct static_key memcg_sockets_enabled_key;
> +#define mem_cgroup_sockets_enabled static_key_false(&memcg_sockets_enabled_key)


We're trying to move to the updated API, so this should be:
static_branch_unlikely(&memcg_sockets_enabled_key)

see: include/linux/jump_label.h for details.


>  void sock_update_memcg(struct sock *sk);
>  void sock_release_memcg(struct sock *sk);
>  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
> @@ -689,6 +691,8 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
>  {
>  	return memcg->tcp_mem.memory_pressure;
>  }
> +#else
> +#define mem_cgroup_sockets_enabled 0
>  #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
>  
>  #ifdef CONFIG_MEMCG_KMEM
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 1a94b85..fcc9442 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1065,13 +1065,6 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
>  #define sk_refcnt_debug_release(sk) do { } while (0)
>  #endif /* SOCK_REFCNT_DEBUG */
>  
> -#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_NET)
> -extern struct static_key memcg_socket_limit_enabled;
> -#define mem_cgroup_sockets_enabled static_key_false(&memcg_socket_limit_enabled)
> -#else
> -#define mem_cgroup_sockets_enabled 0
> -#endif
> -
>  static inline bool sk_stream_memory_free(const struct sock *sk)
>  {
>  	if (sk->sk_wmem_queued >= sk->sk_sndbuf)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 68d67fc..0602bee 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -291,6 +291,9 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
> +struct static_key memcg_sockets_enabled_key;


And this would be:

static DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);


>  void sock_update_memcg(struct sock *sk)
>  {
>  	struct mem_cgroup *memcg;
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 6486b0d..c5435b5 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -201,11 +201,6 @@ EXPORT_SYMBOL(sk_net_capable);
>  static struct lock_class_key af_family_keys[AF_MAX];
>  static struct lock_class_key af_family_slock_keys[AF_MAX];
>  
> -#if defined(CONFIG_MEMCG_KMEM)
> -struct static_key memcg_socket_limit_enabled;
> -EXPORT_SYMBOL(memcg_socket_limit_enabled);
> -#endif
> -
>  /*
>   * Make lock validator output more readable. (we pre-construct these
>   * strings build-time, so that runtime initialization of socket
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index e507825..9a22e2d 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -34,7 +34,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
>  		return;
>  
>  	if (memcg->tcp_mem.active)
> -		static_key_slow_dec(&memcg_socket_limit_enabled);
> +		static_key_slow_dec(&memcg_sockets_enabled_key);
>  

static_branch_dec(&memcg_sockets_enabled_key);

}
>  
>  static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
> @@ -65,7 +65,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
>  		 * because when this value change, the code to process it is not
>  		 * patched in yet.
>  		 */
> -		static_key_slow_inc(&memcg_socket_limit_enabled);
> +		static_key_slow_inc(&memcg_sockets_enabled_key);
>  		memcg->tcp_mem.active = true;
>  	}
>  
> 

static_branch_inc(&memcg_sockets_enabled_key);

Thanks,

-Jason
