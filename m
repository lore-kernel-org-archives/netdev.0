From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next V2 PATCH 5/5] samples/bpf: add cpumap sample program
 xdp_redirect_cpu
Date: Mon, 2 Oct 2017 12:44:10 -0700
Message-ID: <20171002194408.3o4xoefmlkqvhzoq@ast-mbp.dhcp.thefacebook.com>
References: <150670281423.23765.8984643281418950330.stgit@firesoul>
 <150670287254.23765.608477053861949304.stgit@firesoul>
 <20170930030607.sk2wzjxxlbhkkt7k@ast-mbp>
 <20171002140723.7667a9b4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38011 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751062AbdJBToN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 15:44:13 -0400
Received: by mail-pf0-f194.google.com with SMTP id a7so6660046pfj.5
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 12:44:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171002140723.7667a9b4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 02:07:23PM +0200, Jesper Dangaard Brouer wrote:
> On Fri, 29 Sep 2017 20:06:09 -0700
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > > +/*** Trace point code ***/
> > > +
> > > +/* Tracepoint format: /sys/kernel/debug/tracing/events/xdp/xdp_redirect/format
> > > + * Code in:                kernel/include/trace/events/xdp.h
> > > + */
> > > +struct xdp_redirect_ctx {
> > > +	unsigned short common_type;	//	offset:0;  size:2; signed:0;
> > > +	unsigned char common_flags;	//	offset:2;  size:1; signed:0;
> > > +	unsigned char common_preempt_count;//	offset:3;  size:1; signed:0;
> > > +	int common_pid;			//	offset:4;  size:4; signed:1;  
> > 
> > this part is not right. First 8 bytes are not accessible by bpf code.
> > Please use __u64 pad; or similar here.
> 
> I've corrected this in V3.
> 
> Can you explain why BPF cannot access these (first 8 bytes) struct members?

in the very first patch adding bpf to tracepoint we allowed the access,
but then people complained that common_* stuff is not abi and since it was
slow to populate anyway due to local_save_flags (which is never used by
scripts we had so far) and for pid there was a helper already, I was happy
to get rid of it and save these 8 bytes for future use. which ended up
being used by hidden(inaccessible) pt_regs pointer.
Layout description is in
commit 98b5c2c65c29 ("perf, bpf: allow bpf programs attach to tracepoints")
The work on dynamic bits of tracepoints is still tbd.
