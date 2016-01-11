From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update
 elem
Date: Mon, 11 Jan 2016 11:02:49 -0800
Message-ID: <20160111190248.GA26495@ast-mbp.thefacebook.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
 <1452527821-12276-6-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452527821-12276-6-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 11:56:57PM +0800, Ming Lei wrote:
> Prepare for supporting percpu map in the following patch.
> 
> Now userspace can lookup/update mapped value in one specific
> CPU in case of percpu map.
> 
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
...
> @@ -265,7 +272,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>  		goto free_key;
>  
>  	rcu_read_lock();
> -	ptr = map->ops->map_lookup_elem(map, key);
> +	if (!percpu)
> +		ptr = map->ops->map_lookup_elem(map, key);
> +	else
> +		ptr = map->ops->map_lookup_elem_percpu(map, key, attr->cpu);

I think this approach is less potent than Martin's for several reasons:
- bpf program shouldn't be supplying bpf_smp_processor_id(), since
  it's error prone and a bit slower than doing it explicitly as in:
  http://patchwork.ozlabs.org/patch/564482/
  although Martin's patch also needs to use this_cpu_ptr() instead
  of per_cpu_ptr(.., smp_processor_id());

- two new bpf helpers are not necessary in Martin's approach.
  regular map_lookup_elem() will work for both per-cpu maps.

- such map_lookup_elem_percpu() from syscall is not accurate.
  Martin's approach via smp_call_function_single() returns precise value,
  whereas here memcpy() will race with other cpus.
 
Overall I think both pre-cpu hash and per-cpu array maps are quite useful.
For this particular set I would suggest to rebase on top of Martin's
to reuse BPF_MAP_LOOKUP_PERCPU_ELEM command that should be applicable
to both per-cpu array and per-cpu hash maps.
and add BPF_MAP_UPDATE_PERCPU_ELEM via smp_call as another patch
that should work for both as well.
