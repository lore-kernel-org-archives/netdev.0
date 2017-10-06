From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V4 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Fri, 6 Oct 2017 17:58:36 +0200
Message-ID: <20171006175836.1d3d7a8a@redhat.com>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
        <150711862505.9499.15042356194495111353.stgit@firesoul>
        <59D5FDFF.5040002@iogearbox.net>
        <20171006125008.676d5eaf@redhat.com>
        <59D798B8.8090101@iogearbox.net>
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
Received: from mx1.redhat.com ([209.132.183.28]:42022 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751525AbdJFP6s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 11:58:48 -0400
In-Reply-To: <59D798B8.8090101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 06 Oct 2017 16:52:40 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 10/06/2017 12:50 PM, Jesper Dangaard Brouer wrote:
> > On Thu, 05 Oct 2017 11:40:15 +0200
> > Daniel Borkmann <daniel@iogearbox.net> wrote:  
> >> On 10/04/2017 02:03 PM, Jesper Dangaard Brouer wrote:
> >> [...]  
> [...]
> >>> +		/* Updating qsize cause re-allocation of bpf_cpu_map_entry */
> >>> +		rcpu = __cpu_map_entry_alloc(qsize, key_cpu, map->id);
> >>> +		if (!rcpu)
> >>> +			return -ENOMEM;
> >>> +	}
> >>> +	rcu_read_lock();
> >>> +	__cpu_map_entry_replace(cmap, key_cpu, rcpu);
> >>> +	rcu_read_unlock();
> >>> +	return 0;  
> >>
> >> You need to update verifier such that this function cannot be called
> >> out of an BPF program,  
> >
> > In the example BPF program, I do a lookup into the map, but only to
> > verify that an entry exist (I don't look at the value).  I would like
> > to support such usage.  
> 
> Ok, put comment below.
> 
> >> otherwise it would be possible under full RCU
> >> read context, which is explicitly avoided here and also it would otherwise
> >> be allowed for other maps of different type as well, which needs to
> >> be avoided.  
> >
> > Sorry, I don't follow this.  
> 
> What I meant is that check_map_func_compatibility() should check for
> BPF_MAP_TYPE_CPUMAP and only allow func_id of BPF_FUNC_redirect_map
> and BPF_FUNC_map_lookup_elem to be used, which I haven't seen the set
> restricting it to. Some of your later patches do this for the helper
> BPF_FUNC_redirect_map but the important point is that map updates
> wouldn't be done out of the BPF program itself, but rather from user
> space control path given they can't be done under full RCU read lock
> context if I read this correctly (which the programs run in though).

Okay, I choose to restrict bpf_prog side in check_map_func_compatibility()
as you describe.  And I changed the user program to keep track of valid
entries via secondary map.  We can always add/allow lookup later if users
request this.

I'll send out V5 shortly...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
