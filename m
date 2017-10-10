From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V6 PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Wed, 11 Oct 2017 00:48:40 +0200
Message-ID: <59DD4E48.3060403@iogearbox.net>
References: <150763962554.14394.15623435724195136364.stgit@firesoul> <150763965869.14394.6619644617101345170.stgit@firesoul>
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
Received: from www62.your-server.de ([213.133.104.62]:33419 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932298AbdJJWsq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 18:48:46 -0400
In-Reply-To: <150763965869.14394.6619644617101345170.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2017 02:47 PM, Jesper Dangaard Brouer wrote:
[...]
> +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> +{
> +	struct bpf_cpu_map *cmap;
> +	int err = -ENOMEM;
> +	u64 cost;
> +	int ret;
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
> +		return ERR_PTR(-E2BIG);

We still have a leak here, meaning kfree(cmap) is missing on above error.

> +
> +	/* make sure page count doesn't overflow */
> +	cost = (u64) cmap->map.max_entries * sizeof(struct bpf_cpu_map_entry *);
> +	cost += cpu_map_bitmap_size(attr) * num_possible_cpus();
> +	if (cost >= U32_MAX - PAGE_SIZE)
> +		goto free_cmap;
> +	cmap->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
> +
> +	/* Notice returns -EPERM on if map size is larger than memlock limit */
> +	ret = bpf_map_precharge_memlock(cmap->map.pages);
> +	if (ret) {
> +		err = ret;
> +		goto free_cmap;
> +	}
> +
> +	/* A per cpu bitfield with a bit per possible CPU in map  */
> +	cmap->flush_needed = __alloc_percpu(cpu_map_bitmap_size(attr),
> +					    __alignof__(unsigned long));
> +	if (!cmap->flush_needed)
> +		goto free_cmap;
> +
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
