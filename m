From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Fri, 4 Sep 2015 14:42:07 -0600
Message-ID: <20150904204207.GN26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
 <20150904202703.GB1842@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36412 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933671AbbIDUmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 16:42:10 -0400
Received: by ioii196 with SMTP id i196so36792036ioi.3
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 13:42:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150904202703.GB1842@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

On Fri, Sep 04, 2015 at 01:27:05PM -0700, Alexei Starovoitov wrote:
> On Fri, Sep 04, 2015 at 10:04:21AM -0600, Tycho Andersen wrote:
> > This commit adds a way to dump eBPF programs. The initial implementation
> > doesn't support maps, and therefore only allows dumping seccomp ebpf
> > programs which themselves don't currently support maps.
> > 
> > 
> > Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
> > CC: Kees Cook <keescook@chromium.org>
> > CC: Will Drewry <wad@chromium.org>
> > CC: Oleg Nesterov <oleg@redhat.com>
> > CC: Andy Lutomirski <luto@amacapital.net>
> > CC: Pavel Emelyanov <xemul@parallels.com>
> > CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> > CC: Alexei Starovoitov <ast@kernel.org>
> > CC: Daniel Borkmann <daniel@iogearbox.net>
> > ---
> >  include/uapi/linux/bpf.h | 15 +++++++++++++++
> >  kernel/bpf/syscall.c     | 44 ++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 59 insertions(+)
> > 
> > diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> > index 79b825a..c5d8dc2 100644
> > --- a/include/uapi/linux/bpf.h
> > +++ b/include/uapi/linux/bpf.h
> > @@ -107,6 +107,13 @@ enum bpf_cmd {
> >  	 * returns fd or negative error
> >  	 */
> >  	BPF_PROG_LOAD,
> > +
> > +	/* dump an existing bpf
> > +	 * err = bpf(BPF_PROG_DUMP, union bpf_attr *attr, u32 size)
> > +	 * Using attr->prog_fd, attr->dump_insn_cnt, attr->dump_insns
> > +	 * returns zero or negative error
> > +	 */
> > +	BPF_PROG_DUMP,
> >  };
> >  
> >  enum bpf_map_type {
> > @@ -160,6 +167,14 @@ union bpf_attr {
> >  		__aligned_u64	log_buf;	/* user supplied buffer */
> >  		__u32		kern_version;	/* checked when prog_type=kprobe */
> >  	};
> > +
> > +	struct { /* anonymous struct used by BPF_PROG_DUMP command */
> > +		__u32		prog_fd;
> > +		__u32		dump_insn_cnt;
> > +		__aligned_u64	dump_insns;	/* user supplied buffer */
> > +		__u8		gpl_compatible;
> > +		__u64		prog_id;	/* unique id for this prog */
> > +	};
> 
> my first reaction was to may be reuse existing struct used to load,
> but I guess it's actually cleaner to have a new one like you did.
> though prog_fd looks redundant and prog_id is ...

prog_fd is input here, the rest are outputs.

> > +	if (put_user((u64) prog, &uattr->prog_id))
> > +		goto out;
> 
> .. is definitely not secure.
> 
> > We export the GPL bit as well as a unique ID for the program so that
> > userspace can detect when two seccomp filters were inherited from each
> > other and clone the filter tree accordingly.
> 
> you mean that in-kernel prog pointer is the same?
> I think user space can memcmp insns of programs instead?
> Are you trying to solve the case when parent has an FD for bpf program
> and child has another FD that points to the same program, and both
> doing dump and need to coordinate?

Yes, exactly. If we just do a memcmp(), two users can install the same
filter and have a different inheritance model on checkpoint vs
restore. This means that a checkpoint/restore'd process may see
different behavior when using SECCOMP_FILTER_FLAG_TSYNC in the future.

I'm not entirely clear on how much of a problem this actually is, and
perhaps it is too small to be worth worry about, but if there was
another way to export some unique id, that would be dandy.

Tycho
