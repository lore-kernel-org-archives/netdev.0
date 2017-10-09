From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V5 PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Mon, 09 Oct 2017 15:31:21 +0200
Message-ID: <59DB7A29.5050906@iogearbox.net>
References: <150730632837.22839.11804085686478888137.stgit@firesoul> <150730636196.22839.17119032803741721925.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51365 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754176AbdJINbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 09:31:24 -0400
In-Reply-To: <150730636196.22839.17119032803741721925.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2017 06:12 PM, Jesper Dangaard Brouer wrote:
[...]
> +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> +{
> +	struct bpf_cpu_map *cmap;
> +	int err = -ENOMEM;

err init here is basically not needed since overriden later anyway
w/o being read, but ...

> +	u64 cost;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		return ERR_PTR(-EPERM);
> +
> +	/* check sanity of attributes */
> +	if (attr->max_entries == 0 || attr->key_size != 4 ||
> +	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)
> +		return ERR_PTR(-EINVAL);
> +
> +	cmap = kzalloc(sizeof(*cmap), GFP_USER);
> +	if (!cmap)
> +		return ERR_PTR(-ENOMEM);
> +
> +	/* mandatory map attributes */
> +	cmap->map.map_type = attr->map_type;
> +	cmap->map.key_size = attr->key_size;
> +	cmap->map.value_size = attr->value_size;
> +	cmap->map.max_entries = attr->max_entries;
> +	cmap->map.map_flags = attr->map_flags;
> +	cmap->map.numa_node = bpf_map_attr_numa_node(attr);
> +
> +	/* Pre-limit array size based on NR_CPUS, not final CPU check */
> +	if (cmap->map.max_entries > NR_CPUS)

Nit: needs to be >= NR_CPUS.

> +		return ERR_PTR(-E2BIG);
> +
> +	/* make sure page count doesn't overflow */
> +	cost = (u64) cmap->map.max_entries * sizeof(struct bpf_cpu_map_entry *);
> +	cost += cpu_map_bitmap_size(attr) * num_possible_cpus();
> +	if (cost >= U32_MAX - PAGE_SIZE)
> +		goto free_cmap;
> +	cmap->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
> +
> +	/* Notice returns -EPERM on if map size is larger than memlock limit */
> +	err = bpf_map_precharge_memlock(cmap->map.pages);
> +	if (err)
> +		goto free_cmap;

... here, you need to set err = -ENOMEM.

> +	/* A per cpu bitfield with a bit per possible CPU in map  */
> +	cmap->flush_needed = __alloc_percpu(cpu_map_bitmap_size(attr),
> +					    __alignof__(unsigned long));
> +	if (!cmap->flush_needed)
> +		goto free_cmap;

Otherwise when we fail here or in error case for bpf_map_area_alloc()
below, we still return 0 although it's really -ENOMEM. And returning 0,
would mean that find_and_alloc_map() will miss this since it only tests
for IS_ERR(), and we'll crash later on thinking we have a valid map
pointer.

> +	/* Alloc array for possible remote "destination" CPUs */
> +	cmap->cpu_map = bpf_map_area_alloc(cmap->map.max_entries *
> +					   sizeof(struct bpf_cpu_map_entry *),
> +					   cmap->map.numa_node);
> +	if (!cmap->cpu_map)
> +		goto free_cmap;
> +
> +	return &cmap->map;
> +free_cmap:
> +	free_percpu(cmap->flush_needed);
> +	kfree(cmap);
> +	return ERR_PTR(err);
> +}
> +
[...]
> +int cpu_map_update_elem(struct bpf_map *map, void *key, void *value,
> +				u64 map_flags)
> +{
> +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> +	struct bpf_cpu_map_entry *rcpu;
> +
> +	/* Array index key correspond to CPU number */
> +	u32 key_cpu = *(u32 *)key;
> +	/* Value is the queue size */
> +	u32 qsize = *(u32 *)value;
> +
> +	/* Make sure CPU is a valid possible cpu */
> +	if (!cpu_possible(key_cpu))
> +		return -ENODEV;

Nit: cpu_possible() expects that key_cpu < NR_CPUS, otherwise you'd
access the bitmap out of bounds.

Better move the below test for 'key_cpu >= cmap->map.max_entries'
first as on map alloc you enforce upper limit of NR_CPUS on the
max_entries, then above cpu_possible() test will be valid, too.

> +	if (unlikely(map_flags > BPF_EXIST))
> +		return -EINVAL;
> +	if (unlikely(key_cpu >= cmap->map.max_entries))
> +		return -E2BIG;
> +	if (unlikely(map_flags == BPF_NOEXIST))
> +		return -EEXIST;
> +	if (unlikely(qsize > 16384)) /* sanity limit on qsize */
> +		return -EOVERFLOW;
> +
> +	if (qsize == 0) {
> +		rcpu = NULL; /* Same as deleting */
> +	} else {
> +		/* Updating qsize cause re-allocation of bpf_cpu_map_entry */
> +		rcpu = __cpu_map_entry_alloc(qsize, key_cpu, map->id);
> +		if (!rcpu)
> +			return -ENOMEM;
> +	}
> +	rcu_read_lock();
> +	__cpu_map_entry_replace(cmap, key_cpu, rcpu);
> +	rcu_read_unlock();
> +	return 0;
> +}
[...]
> +struct bpf_cpu_map_entry *__cpu_map_lookup_elem(struct bpf_map *map, u32 key)
> +{
> +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> +	struct bpf_cpu_map_entry *rcpu;
> +
> +	if (key >= map->max_entries)
> +		return NULL;
> +
> +	rcpu = READ_ONCE(cmap->cpu_map[key]);
> +	return rcpu;
> +}
> +
> +static void *cpu_map_lookup_elem(struct bpf_map *map, void *key)
> +{
> +	struct bpf_cpu_map_entry *rcpu =
> +		__cpu_map_lookup_elem(map, *(u32 *)key);
> +
> +	return rcpu ? &rcpu->qsize : NULL;

I still think from my prior email/comment that we should use per-cpu
scratch buffer here. Would be nice to keep the guarantee that noone
can modify it, it's just a tiny change.

> +}
> +
> +static int cpu_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
> +{
> +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> +	u32 index = key ? *(u32 *)key : U32_MAX;
> +	u32 *next = next_key;
> +
> +	if (index >= cmap->map.max_entries) {
> +		*next = 0;
> +		return 0;
> +	}
> +
> +	if (index == cmap->map.max_entries - 1)
> +		return -ENOENT;
> +	*next = index + 1;
> +	return 0;
> +}
> +
> +const struct bpf_map_ops cpu_map_ops = {
> +	.map_alloc		= cpu_map_alloc,
> +	.map_free		= cpu_map_free,
> +	.map_delete_elem	= cpu_map_delete_elem,
> +	.map_update_elem	= cpu_map_update_elem,
> +	.map_lookup_elem	= cpu_map_lookup_elem,
> +	.map_get_next_key	= cpu_map_get_next_key,
> +};
