From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V8 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Wed, 18 Oct 2017 10:38:07 +0200
Message-ID: <20171018103807.367e91ee@redhat.com>
References: <150814913767.1806.3470498528707259987.stgit@firesoul>
        <150814916887.1806.4443991765779135803.stgit@firesoul>
        <CAKQ1sVMH-h36UWwuKhcVC=ZN+L=y3y3apayye_yKYKXTbqMGTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Yann Ylavic <ylavic.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934469AbdJRIiR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 04:38:17 -0400
In-Reply-To: <CAKQ1sVMH-h36UWwuKhcVC=ZN+L=y3y3apayye_yKYKXTbqMGTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 16 Oct 2017 12:19:28 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> +{
> +	struct bpf_cpu_map *cmap;
> +	int err = -ENOMEM;

Notice err is set to -ENOMEM.

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
> +	if (cmap->map.max_entries > NR_CPUS) {
> +		err = -E2BIG;
> +		goto free_cmap;
> +	}
> +
> +	/* make sure page count doesn't overflow */
> +	cost = (u64) cmap->map.max_entries * sizeof(struct bpf_cpu_map_entry *);
> +	cost += cpu_map_bitmap_size(attr) * num_possible_cpus();
> +	if (cost >= U32_MAX - PAGE_SIZE)
> +		goto free_cmap;
> +	cmap->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
> +
> +	/* Notice returns -EPERM on if map size is larger than memlock limit */

[... continued below ...]

On Wed, 18 Oct 2017 09:45:59 +0200 Yann Ylavic <ylavic.dev@gmail.com> wrote:

> On Mon, Oct 16, 2017 at 12:19 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > +
> > +       /* Notice returns -EPERM on if map size is larger than memlock limit */
> > +       ret = bpf_map_precharge_memlock(cmap->map.pages);
> > +       if (ret) {
> > +               err = ret;
> > +               goto free_cmap;
> > +       }
> > +
> > +       /* A per cpu bitfield with a bit per possible CPU in map  */
> > +       cmap->flush_needed = __alloc_percpu(cpu_map_bitmap_size(attr),
> > +                                           __alignof__(unsigned long));
> > +       if (!cmap->flush_needed)
> > +               goto free_cmap;
> > +
> > +       /* Alloc array for possible remote "destination" CPUs */
> > +       cmap->cpu_map = bpf_map_area_alloc(cmap->map.max_entries *
> > +                                          sizeof(struct bpf_cpu_map_entry *),
> > +                                          cmap->map.numa_node);
> > +       if (!cmap->cpu_map)  
> 
> ret = -ENOMEM; ?

Did you notice that "err" already is = -ENOMEM at this point?


> > +               goto free_percpu;
> > +
> > +       return &cmap->map;
> > +free_percpu:
> > +       free_percpu(cmap->flush_needed);
> > +free_cmap:
> > +       kfree(cmap);
> > +       return ERR_PTR(err);
> > +}  
> 
> 
> Regards,
> Yann.



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
