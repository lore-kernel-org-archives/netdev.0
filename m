From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/3] security: bpf: Add eBPF LSM hooks and security field
 to eBPF map
Date: Fri, 01 Sep 2017 00:38:40 +0200
Message-ID: <59A88FF0.9010605@iogearbox.net>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com> <20170831205635.80256-3-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46189 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdHaWio (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:38:44 -0400
In-Reply-To: <20170831205635.80256-3-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 10:56 PM, Chenbo Feng wrote:
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

Against which tree is this by the way, net-next? There are
changes here which require a rebase of your set.

> ---
>   include/linux/bpf.h  |  3 +++
>   kernel/bpf/syscall.c | 28 ++++++++++++++++++++++++++++
>   2 files changed, 31 insertions(+)
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index b69e7a5869ff..ca3e6ff7091d 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -53,6 +53,9 @@ struct bpf_map {
>   	struct work_struct work;
>   	atomic_t usercnt;
>   	struct bpf_map *inner_map_meta;
> +#ifdef CONFIG_SECURITY
> +	void *security;
> +#endif
>   };
>
>   /* function argument constraints */
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 045646da97cc..b15580bcf3b1 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -279,6 +279,10 @@ static int map_create(union bpf_attr *attr)
>   	if (err)
>   		return -EINVAL;
>
> +	err = security_map_create();

Seems a bit limited to me, don't you want to be able to
also differentiate between different map types? Same goes
for security_prog_load() wrt prog types, no?

> +	if (err)
> +		return -EACCES;
> +
>   	/* find map type and init map: hashtable vs rbtree vs bloom vs ... */
>   	map = find_and_alloc_map(attr);
>   	if (IS_ERR(map))
> @@ -291,6 +295,10 @@ static int map_create(union bpf_attr *attr)
>   	if (err)
>   		goto free_map_nouncharge;
>
> +	err = security_post_create(map);
> +	if (err < 0)
> +		goto free_map;
> +

So the hook you implement in patch 3/3 does:

+static int selinux_bpf_post_create(struct bpf_map *map)
+{
+	struct bpf_security_struct *bpfsec;
+
+	bpfsec = kzalloc(sizeof(*bpfsec), GFP_KERNEL);
+	if (!bpfsec)
+		return -ENOMEM;
+
+	bpfsec->sid = current_sid();
+	map->security = bpfsec;
+
+	return 0;
+}

Where do you kfree() bpfsec when the map gets released
normally or in error path?

>   	err = bpf_map_alloc_id(map);
>   	if (err)
>   		goto free_map;
> @@ -410,6 +418,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>   	if (IS_ERR(map))
>   		return PTR_ERR(map);
>
> +	err = security_map_read(map);
> +	if (err)
> +		return -EACCES;

How about actually dropping ref?

> +
>   	key = memdup_user(ukey, map->key_size);
>   	if (IS_ERR(key)) {
>   		err = PTR_ERR(key);
> @@ -490,6 +502,10 @@ static int map_update_elem(union bpf_attr *attr)
>   	if (IS_ERR(map))
>   		return PTR_ERR(map);
>
> +	err = security_map_modify(map);
> +	if (err)
> +		return -EACCES;

Ditto ...

>   	key = memdup_user(ukey, map->key_size);
>   	if (IS_ERR(key)) {
>   		err = PTR_ERR(key);
> @@ -573,6 +589,10 @@ static int map_delete_elem(union bpf_attr *attr)
>   	if (IS_ERR(map))
>   		return PTR_ERR(map);
>
> +	err = security_map_modify(map);
> +	if (err)
> +		return -EACCES;

Ditto ...

>   	key = memdup_user(ukey, map->key_size);
>   	if (IS_ERR(key)) {
>   		err = PTR_ERR(key);
> @@ -616,6 +636,10 @@ static int map_get_next_key(union bpf_attr *attr)
>   	if (IS_ERR(map))
>   		return PTR_ERR(map);
>
> +	err = security_map_read(map);
> +	if (err)
> +		return -EACCES;

And once again here ... :(

>   	if (ukey) {
>   		key = memdup_user(ukey, map->key_size);
>   		if (IS_ERR(key)) {
> @@ -935,6 +959,10 @@ static int bpf_prog_load(union bpf_attr *attr)
>   	if (CHECK_ATTR(BPF_PROG_LOAD))
>   		return -EINVAL;
>
> +	err = security_prog_load();
> +	if (err)
> +		return -EACCES;
> +
>   	if (attr->prog_flags & ~BPF_F_STRICT_ALIGNMENT)
>   		return -EINVAL;
>
>
