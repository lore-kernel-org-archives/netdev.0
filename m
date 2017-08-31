From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] security: bpf: Add eBPF LSM hooks and security
 field to eBPF map
Date: Thu, 31 Aug 2017 17:17:21 -0400
Message-ID: <1504214241.6901.31.camel@linux.vnet.ibm.com>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
         <20170831205635.80256-3-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20170831205635.80256-3-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-08-31 at 13:56 -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Introduce a pointer into struct bpf_map to hold the security information
> about the map. The actual security struct varies based on the security
> models implemented. Place the LSM hooks before each of the unrestricted
> eBPF operations, the map_update_elem and map_delete_elem operations are
> checked by security_map_modify. The map_lookup_elem and map_get_next_key
> operations are checked by securtiy_map_read.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> ---
>  include/linux/bpf.h  |  3 +++
>  kernel/bpf/syscall.c | 28 ++++++++++++++++++++++++++++
>  2 files changed, 31 insertions(+)
> 
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index b69e7a5869ff..ca3e6ff7091d 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -53,6 +53,9 @@ struct bpf_map {
>  	struct work_struct work;
>  	atomic_t usercnt;
>  	struct bpf_map *inner_map_meta;
> +#ifdef CONFIG_SECURITY
> +	void *security;
> +#endif
>  };
>  
>  /* function argument constraints */
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 045646da97cc..b15580bcf3b1 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -279,6 +279,10 @@ static int map_create(union bpf_attr *attr)
>  	if (err)
>  		return -EINVAL;
>  
> +	err = security_map_create();
> +	if (err)
> +		return -EACCES;

Any reason not to just return err?

Mimi

> +
>  	/* find map type and init map: hashtable vs rbtree vs bloom vs ... */
>  	map = find_and_alloc_map(attr);
>  	if (IS_ERR(map))
> @@ -291,6 +295,10 @@ static int map_create(union bpf_attr *attr)
>  	if (err)
>  		goto free_map_nouncharge;
>  
> +	err = security_post_create(map);
> +	if (err < 0)
> +		goto free_map;
> +
>  	err = bpf_map_alloc_id(map);
>  	if (err)
>  		goto free_map;
> @@ -410,6 +418,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>  	if (IS_ERR(map))
>  		return PTR_ERR(map);
>  
> +	err = security_map_read(map);
> +	if (err)
> +		return -EACCES;
> +
>  	key = memdup_user(ukey, map->key_size);
>  	if (IS_ERR(key)) {
>  		err = PTR_ERR(key);
> @@ -490,6 +502,10 @@ static int map_update_elem(union bpf_attr *attr)
>  	if (IS_ERR(map))
>  		return PTR_ERR(map);
>  
> +	err = security_map_modify(map);
> +	if (err)
> +		return -EACCES;
> +
>  	key = memdup_user(ukey, map->key_size);
>  	if (IS_ERR(key)) {
>  		err = PTR_ERR(key);
> @@ -573,6 +589,10 @@ static int map_delete_elem(union bpf_attr *attr)
>  	if (IS_ERR(map))
>  		return PTR_ERR(map);
>  
> +	err = security_map_modify(map);
> +	if (err)
> +		return -EACCES;
> +
>  	key = memdup_user(ukey, map->key_size);
>  	if (IS_ERR(key)) {
>  		err = PTR_ERR(key);
> @@ -616,6 +636,10 @@ static int map_get_next_key(union bpf_attr *attr)
>  	if (IS_ERR(map))
>  		return PTR_ERR(map);
>  
> +	err = security_map_read(map);
> +	if (err)
> +		return -EACCES;
> +
>  	if (ukey) {
>  		key = memdup_user(ukey, map->key_size);
>  		if (IS_ERR(key)) {
> @@ -935,6 +959,10 @@ static int bpf_prog_load(union bpf_attr *attr)
>  	if (CHECK_ATTR(BPF_PROG_LOAD))
>  		return -EINVAL;
>  
> +	err = security_prog_load();
> +	if (err)
> +		return -EACCES;
> +
>  	if (attr->prog_flags & ~BPF_F_STRICT_ALIGNMENT)
>  		return -EINVAL;
>  

