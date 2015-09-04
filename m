From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Fri, 4 Sep 2015 15:09:18 -0600
Message-ID: <20150904210918.GS26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
 <20150904201743.GA1842@Alexeis-MacBook-Pro-2.local>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150904201743.GA1842@Alexeis-MacBook-Pro-2.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 01:17:47PM -0700, Alexei Starovoitov wrote:
> On Fri, Sep 04, 2015 at 10:04:19AM -0600, Tycho Andersen wrote:
> > seccomp uses eBPF as its underlying storage and execution format, and eBPF
> > has features that seccomp would like to make use of in the future. This
> > patch adds a formal seccomp type to the eBPF verifier.
> > 
> > The current implementation of the seccomp eBPF type is very limited, and
> > doesn't support some interesting features (notably, maps) of eBPF. However,
> > the primary motivation for this patchset is to enable checkpoint/restore
> > for seccomp filters later in the series, to this limited feature set is ok
> > for now.
> 
> yes. good compromise to start.
> 
> > +static const struct bpf_func_proto *
> > +seccomp_func_proto(enum bpf_func_id func_id)
> > +{
> > +	/* Right now seccomp eBPF loading doesn't support maps; seccomp filters
> > +	 * are considered to be read-only after they're installed, so map fds
> > +	 * probably need to be invalidated when a seccomp filter with maps is
> > +	 * installed.
> 
> Just disabling bpf_map_lookup/update() helpers (the way you did here)
> is enough. The prorgram can still have references to maps, but since they
> won't be accessed it's safe.
> 
> > +	 *
> > +	 * The rest of these might be reasonable to call from seccomp, so we
> > +	 * export them.
> > +	 */
> > +	switch (func_id) {
> > +	case BPF_FUNC_ktime_get_ns:
> > +		return &bpf_ktime_get_ns_proto;
> > +	case BPF_FUNC_trace_printk:
> > +		return bpf_get_trace_printk_proto();
> > +	case BPF_FUNC_get_prandom_u32:
> > +		return &bpf_get_prandom_u32_proto;
> > +	case BPF_FUNC_get_smp_processor_id:
> > +		return &bpf_get_smp_processor_id_proto;
> > +	case BPF_FUNC_tail_call:
> > +		return &bpf_tail_call_proto;
> > +	case BPF_FUNC_get_current_pid_tgid:
> > +		return &bpf_get_current_pid_tgid_proto;
> > +	case BPF_FUNC_get_current_uid_gid:
> > +		return &bpf_get_current_uid_gid_proto;
> > +	case BPF_FUNC_get_current_comm:
> > +		return &bpf_get_current_comm_proto;
> 
> the list looks good to start with.
> 
> >  
> > +static u32 seccomp_convert_ctx_access(enum bpf_access_type type, int dst_reg,
> > +				      int src_reg, int ctx_off,
> > +				      struct bpf_insn *insn_buf)
> > +{
> > +	struct bpf_insn *insn = insn_buf;
> > +
> > +	switch (ctx_off) {
> > +	case offsetof(struct seccomp_data, nr):
> 
> the conversion of seccomp_data fields is unnecessary.
> We're doing conversion for sk_buff, because sk_buff and __sk_buff aree two
> different structures. __sk_buff is user ABI with its own fields that losely
> correspond to in-kernel struct sk_buff.
> seccomp_data is already part of user ABI, so it's ok to access as-is.

Ok, I noticed this but somehow didn't put it all together. I'll axe
this for the next version, thanks.

Tycho
