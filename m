From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V5 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Mon, 9 Oct 2017 19:59:24 +0200
Message-ID: <20171009195924.662f1586@redhat.com>
References: <150730632837.22839.11804085686478888137.stgit@firesoul>
        <150730636196.22839.17119032803741721925.stgit@firesoul>
        <59DB7A29.5050906@iogearbox.net>
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
Received: from mx1.redhat.com ([209.132.183.28]:38522 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754356AbdJIR7i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 13:59:38 -0400
In-Reply-To: <59DB7A29.5050906@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 Oct 2017 15:31:21 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 10/06/2017 06:12 PM, Jesper Dangaard Brouer wrote:
> [...]
> > +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> > +{
> > +	struct bpf_cpu_map *cmap;
> > +	int err = -ENOMEM;  
> 
> err init here is basically not needed since overriden later anyway
> w/o being read, but ...

Thank you for catching this! Guess, I'll send a V6 tomorrow.

[...]
> > +	/* Notice returns -EPERM on if map size is larger than memlock limit */
> > +	err = bpf_map_precharge_memlock(cmap->map.pages);
> > +	if (err)
> > +		goto free_cmap;  
> 
> ... here, you need to set err = -ENOMEM.

Yes, I see my mistake of assigning "err" here.

[...]
> > +static void *cpu_map_lookup_elem(struct bpf_map *map, void *key)
> > +{
> > +	struct bpf_cpu_map_entry *rcpu =
> > +		__cpu_map_lookup_elem(map, *(u32 *)key);
> > +
> > +	return rcpu ? &rcpu->qsize : NULL;  
> 
> I still think from my prior email/comment that we should use per-cpu
> scratch buffer here. Would be nice to keep the guarantee that noone
> can modify it, it's just a tiny change.

Well, it's no-longer really needed, right(?), as this patchset update,
change that bpf-side cannot invoke this.  The userspace-side reading
this will get a copy.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
