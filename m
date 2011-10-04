From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 6/8] tcp buffer limitation: per-cgroup limit
Date: Tue, 04 Oct 2011 14:48:55 +0200
Message-ID: <1317732535.2440.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1317730680-24352-1-git-send-email-glommer@parallels.com>
	 <1317730680-24352-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com,
  kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com,
 davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org,
 linux-mm@kvack.org,  kirill@shutemov.name, avagin@parallels.com,
 devel@openvz.org
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1317730680-24352-7-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 04 octobre 2011 =C3=A0 16:17 +0400, Glauber Costa a =C3=A9crit :
> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
>=20
> We have to make sure that none of the memory pressure thresholds
> specified in the namespace are bigger than the current cgroup.
>=20
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> ---


> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -256,6 +256,7 @@ extern int sysctl_tcp_thin_dupack;
>  struct mem_cgroup;
>  struct tcp_memcontrol {
>  	/* per-cgroup tcp memory pressure knobs */
> +	int tcp_max_memory;
>  	atomic_long_t tcp_memory_allocated;
>  	struct percpu_counter tcp_sockets_allocated;
>  	/* those two are read-mostly, leave them at the end */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c

So tcp_max_memory is an "int".


> +static u64 tcp_read_limit(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> +	return memcg->tcp.tcp_max_memory << PAGE_SHIFT;
> +}

1) Typical integer overflow here.

You need :

return ((u64)memcg->tcp.tcp_max_memory) << PAGE_SHIFT;


2) Could you add const qualifiers when possible to your pointers ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
