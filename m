From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V4 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Fri, 6 Oct 2017 11:03:38 +0200
Message-ID: <20171006110338.21f645b9@redhat.com>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
        <150711862505.9499.15042356194495111353.stgit@firesoul>
        <20171004190201.5no5mrmkko43cvv2@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7484 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753670AbdJFJDt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 05:03:49 -0400
In-Reply-To: <20171004190201.5no5mrmkko43cvv2@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Oct 2017 12:02:02 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Wed, Oct 04, 2017 at 02:03:45PM +0200, Jesper Dangaard Brouer wrote:
> > The 'cpumap' is primary used as a backend map for XDP BPF helper
> > call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
> > 
> > This patch implement the main part of the map.  It is not connected to
> > the XDP redirect system yet, and no SKB allocation are done yet.
> > 
> > The main concern in this patch is to ensure the datapath can run
> > without any locking.  This adds complexity to the setup and tear-down
> > procedure, which assumptions are extra carefully documented in the
> > code comments.
> > 
> > V2:
> >  - make sure array isn't larger than NR_CPUS
> >  - make sure CPUs added is a valid possible CPU
> > 
> > V3: fix nitpicks from Jakub Kicinski <kubakici@wp.pl>
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> ...
> > +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> > +{
> > +	struct bpf_cpu_map *cmap;
> > +	u64 cost;
> > +	int err;
> > +
> > +	/* check sanity of attributes */
> > +	if (attr->max_entries == 0 || attr->key_size != 4 ||
> > +	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	cmap = kzalloc(sizeof(*cmap), GFP_USER);
> > +	if (!cmap)
> > +		return ERR_PTR(-ENOMEM);  
> 
> just noticed that there is nothing here nor in DEVMAP/SOCKMAP
> that prevents unpriv user to create them.
> I'm not sure it was intentional for DEVMAP/SOCKMAP.
> For CPUMAP I'd suggest to restrict it to root, since it
> suppose to operate with XDP only which is root anyway.
> Note, lpm and lru maps are cap_sys_admin only already.

I agree.  Have restricted this in V5

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
