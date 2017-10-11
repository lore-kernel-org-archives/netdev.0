From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V6 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Wed, 11 Oct 2017 07:36:28 +0200
Message-ID: <20171011073628.0c149ca5@redhat.com>
References: <150763962554.14394.15623435724195136364.stgit@firesoul>
        <150763965869.14394.6619644617101345170.stgit@firesoul>
        <59DD4E48.3060403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37672 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750718AbdJKFgj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 01:36:39 -0400
In-Reply-To: <59DD4E48.3060403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Oct 2017 00:48:40 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 10/10/2017 02:47 PM, Jesper Dangaard Brouer wrote:
> [...]
> > +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> > +{
> > +	struct bpf_cpu_map *cmap;
> > +	int err = -ENOMEM;
> > +	u64 cost;
> > +	int ret;
> > +
> > +	if (!capable(CAP_SYS_ADMIN))
> > +		return ERR_PTR(-EPERM);
> > +
> > +	/* check sanity of attributes */
> > +	if (attr->max_entries == 0 || attr->key_size != 4 ||
> > +	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	cmap = kzalloc(sizeof(*cmap), GFP_USER);
> > +	if (!cmap)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	/* mandatory map attributes */
> > +	cmap->map.map_type = attr->map_type;
> > +	cmap->map.key_size = attr->key_size;
> > +	cmap->map.value_size = attr->value_size;
> > +	cmap->map.max_entries = attr->max_entries;
> > +	cmap->map.map_flags = attr->map_flags;
> > +	cmap->map.numa_node = bpf_map_attr_numa_node(attr);
> > +
> > +	/* Pre-limit array size based on NR_CPUS, not final CPU check */
> > +	if (cmap->map.max_entries > NR_CPUS)
> > +		return ERR_PTR(-E2BIG);  
> 
> We still have a leak here, meaning kfree(cmap) is missing on above error.

Darn... yes, I introduced this in this V6 as I moved the check.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
