From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: grab rcu read lock for bpf_percpu_hash_update
Date: Thu, 18 Feb 2016 19:12:20 -0800
Message-ID: <20160219031219.GA86962@ast-mbp.thefacebook.com>
References: <1455850582-9490-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455850582-9490-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 09:56:22PM -0500, Sasha Levin wrote:
> bpf_percpu_hash_update() expects rcu lock to be held and warns if it's not,
> which pointed out a missing rcu read lock.
> 
> Fixes: 15a07b338 ("bpf: add lookup/update support for per-cpu hash and array maps")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  kernel/bpf/syscall.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index c95a753..94324b8 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -348,7 +348,9 @@ static int map_update_elem(union bpf_attr *attr)
>  		goto free_value;
>  
>  	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH) {
> +		rcu_read_lock();
>  		err = bpf_percpu_hash_update(map, key, value, attr->flags);
> +		rcu_read_unlock();

good catch. thanks, but could you add rcu_read_lock/unlock
inside bpf_percpu_hash_update() instead... to match what
bpf_percpu_hash_copy/bpf_percpu_array_update/bpf_percpu_array_copy are doing.
Otherwise it's inconsistent.
