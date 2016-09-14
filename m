From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v3 03/22] bpf,landlock: Add a new arraymap type to deal
 with (Landlock) handles
Date: Wed, 14 Sep 2016 16:28:17 -0700
Message-ID: <20160914232815.GE60248@ast-mbp.thefacebook.com>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-4-mic@digikod.net>
 <20160914185157.GA53542@ast-mbp.thefacebook.com>
 <57D9DBC9.2010605@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kern
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57D9DBC9.2010605@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 15, 2016 at 01:22:49AM +0200, Mickaël Salaün wrote:
> 
> On 14/09/2016 20:51, Alexei Starovoitov wrote:
> > On Wed, Sep 14, 2016 at 09:23:56AM +0200, Mickaël Salaün wrote:
> >> This new arraymap looks like a set and brings new properties:
> >> * strong typing of entries: the eBPF functions get the array type of
> >>   elements instead of CONST_PTR_TO_MAP (e.g.
> >>   CONST_PTR_TO_LANDLOCK_HANDLE_FS);
> >> * force sequential filling (i.e. replace or append-only update), which
> >>   allow quick browsing of all entries.
> >>
> >> This strong typing is useful to statically check if the content of a map
> >> can be passed to an eBPF function. For example, Landlock use it to store
> >> and manage kernel objects (e.g. struct file) instead of dealing with
> >> userland raw data. This improve efficiency and ensure that an eBPF
> >> program can only call functions with the right high-level arguments.
> >>
> >> The enum bpf_map_handle_type list low-level types (e.g.
> >> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
> >> updating a map entry (handle). This handle types are used to infer a
> >> high-level arraymap type which are listed in enum bpf_map_array_type
> >> (e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).
> >>
> >> For now, this new arraymap is only used by Landlock LSM (cf. next
> >> commits) but it could be useful for other needs.
> >>
> >> Changes since v2:
> >> * add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
> >>   handle entries (suggested by Andy Lutomirski)
> >> * remove useless checks
> >>
> >> Changes since v1:
> >> * arraymap of handles replace custom checker groups
> >> * simpler userland API
> >>
> >> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> >> Cc: Alexei Starovoitov <ast@kernel.org>
> >> Cc: Andy Lutomirski <luto@amacapital.net>
> >> Cc: Daniel Borkmann <daniel@iogearbox.net>
> >> Cc: David S. Miller <davem@davemloft.net>
> >> Cc: Kees Cook <keescook@chromium.org>
> >> Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com
> >> ---
> >>  include/linux/bpf.h      |  14 ++++
> >>  include/uapi/linux/bpf.h |  18 +++++
> >>  kernel/bpf/arraymap.c    | 203 +++++++++++++++++++++++++++++++++++++++++++++++
> >>  kernel/bpf/verifier.c    |  12 ++-
> >>  4 files changed, 246 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> >> index fa9a988400d9..eae4ce4542c1 100644
> >> --- a/include/linux/bpf.h
> >> +++ b/include/linux/bpf.h
> >> @@ -13,6 +13,10 @@
> >>  #include <linux/percpu.h>
> >>  #include <linux/err.h>
> >>  
> >> +#ifdef CONFIG_SECURITY_LANDLOCK
> >> +#include <linux/fs.h> /* struct file */
> >> +#endif /* CONFIG_SECURITY_LANDLOCK */
> >> +
> >>  struct perf_event;
> >>  struct bpf_map;
> >>  
> >> @@ -38,6 +42,7 @@ struct bpf_map_ops {
> >>  struct bpf_map {
> >>  	atomic_t refcnt;
> >>  	enum bpf_map_type map_type;
> >> +	enum bpf_map_array_type map_array_type;
> >>  	u32 key_size;
> >>  	u32 value_size;
> >>  	u32 max_entries;
> >> @@ -187,6 +192,9 @@ struct bpf_array {
> >>  	 */
> >>  	enum bpf_prog_type owner_prog_type;
> >>  	bool owner_jited;
> >> +#ifdef CONFIG_SECURITY_LANDLOCK
> >> +	u32 n_entries;	/* number of entries in a handle array */
> >> +#endif /* CONFIG_SECURITY_LANDLOCK */
> >>  	union {
> >>  		char value[0] __aligned(8);
> >>  		void *ptrs[0] __aligned(8);
> >> @@ -194,6 +202,12 @@ struct bpf_array {
> >>  	};
> >>  };
> >>  
> >> +#ifdef CONFIG_SECURITY_LANDLOCK
> >> +struct map_landlock_handle {
> >> +	u32 type; /* enum bpf_map_handle_type */
> >> +};
> >> +#endif /* CONFIG_SECURITY_LANDLOCK */
> >> +
> >>  #define MAX_TAIL_CALL_CNT 32
> >>  
> >>  struct bpf_event_entry {
> >> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> >> index 7cd36166f9b7..b68de57f7ab8 100644
> >> --- a/include/uapi/linux/bpf.h
> >> +++ b/include/uapi/linux/bpf.h
> >> @@ -87,6 +87,15 @@ enum bpf_map_type {
> >>  	BPF_MAP_TYPE_PERCPU_ARRAY,
> >>  	BPF_MAP_TYPE_STACK_TRACE,P_TYPE_CGROUP_ARRAY
> >>  	BPF_MAP_TYPE_CGROUP_ARRAY,
> >> +	BPF_MAP_TYPE_LANDLOCK_ARRAY,
> >> +};
> >> +
> >> +enum bpf_map_array_type {
> >> +	BPF_MAP_ARRAY_TYPE_UNSPEC,
> >> +};
> >> +
> >> +enum bpf_map_handle_type {
> >> +	BPF_MAP_HANDLE_TYPE_UNSPEC,
> >>  };
> > 
> > missing something. why it has to be special to have it's own
> > fd array implementation?
> > Please take a look how BPF_MAP_TYPE_PERF_EVENT_ARRAY, 
> > BPF_MAP_TYPE_CGROUP_ARRAY and BPF_MAP_TYPE_PROG_ARRAY are done.
> > The all store objects into array map that user space passes via FD.
> > I think the same model should apply here.
> 
> The idea is to have multiple way for userland to describe a resource
> (e.g. an open file descriptor, a path or a glob pattern). The kernel
> representation could then be a "struct path *" or dedicated types (e.g.
> custom glob).

hmm. I think user space api should only deal with FD. Everything
else is user space job to encapsulate/hide.

> Another interesting point (that could replace
> check_map_func_compatibility()) is that BPF_MAP_TYPE_LANDLOCK_ARRAY
> translate to dedicated (abstract) types (instead of CONST_PTR_TO_MAP)
> thanks to bpf_reg_type_from_map(). This is useful to abstract userland
> (map) interface with kernel object(s) dealing with that type.

I probably missing something. If user space interface is FD,
to the kernel they're different object types. Nothing else.

> A third point is that BPF_MAP_TYPE_LANDLOCK_ARRAY is a kind of set. It
> is optimized to quickly walk through all the elements in a sequential way.

why set is any faster to walk vs array?

