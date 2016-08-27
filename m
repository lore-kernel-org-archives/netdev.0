From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (program types)
Date: Sat, 27 Aug 2016 11:19:41 -0700
Message-ID: <20160827181939.GC38754@ast-mbp.thefacebook.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C1A50F.60605@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Mack <daniel@zonque.org>,
	"David S . Miller" <davem@davemloft.net>,
	Kees Cook <keescook@chromium.org>,
	Sargun Dhillon <sargun@sargun.me>,
	kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-4490-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <57C1A50F.60605@digikod.net>
List-Id: netdev.vger.kernel.org

On Sat, Aug 27, 2016 at 04:34:55PM +0200, Mickaël Salaün wrote:
> 
> On 27/08/2016 01:05, Alexei Starovoitov wrote:
> > On Fri, Aug 26, 2016 at 05:10:40PM +0200, Mickaël Salaün wrote:
> >
> >>> As far as safety and type checking that bpf programs has to do,
> >>> I like the approach of patch 06/10:
> >>> +LANDLOCK_HOOK2(file_open, FILE_OPEN,
> >>> +       PTR_TO_STRUCT_FILE, struct file *, file,
> >>> +       PTR_TO_STRUCT_CRED, const struct cred *, cred
> >>> +)
> >>> teaching verifier to recognize struct file, cred, sockaddr
> >>> will let bpf program access them naturally without any overhead.
> >>> Though:
> >>> @@ -102,6 +102,9 @@ enum bpf_prog_type {
> >>>         BPF_PROG_TYPE_SCHED_CLS,
> >>>         BPF_PROG_TYPE_SCHED_ACT,
> >>>         BPF_PROG_TYPE_TRACEPOINT,
> >>> +       BPF_PROG_TYPE_LANDLOCK_FILE_OPEN,
> >>> +       BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION,
> >>> +       BPF_PROG_TYPE_LANDLOCK_MMAP_FILE,
> >>>  };
> >>> is a bit of overkill.
> >>> I think it would be cleaner to have single
> >>> BPF_PROG_TYPE_LSM and at program load time pass
> >>> lsm_hook_id as well, so that verifier can do safety checks
> >>> based on type info provided in LANDLOCK_HOOKs
> >>
> >> I first started with a unique BPF_PROG_TYPE but, the thing is, the BPF
> >> verifier check programs according to their types. If we need to check
> >> specific context value types (e.g. PTR_TO_STRUCT_FILE), we need a
> >> dedicated program types. I don't see any other way to do it with the
> >> current verifier code. Moreover it's the purpose of program types, right?
> > 
> > Adding new bpf program type for every lsm hook is not acceptable.
> > Either do one new program type + pass lsm_hook_id as suggested
> > or please come up with an alternative approach.
> 
> OK, so we have to modify the verifier to not only rely on the program
> type but on another value to check the context accesses. Do you have a
> hint from where this value could come from? Do we need to add a new bpf
> command to associate a program to a subtype?

It's another field prog_subtype (or prog_hook_id) in union bpf_attr.
Both prog_type and prog_hook_id are used during verification.
prog_type distinguishes the main aspects whereas prog_hook_id selects
which lsm_hook's argument definition to apply.
At the time of attaching to a hook, the prog_hook_id passed at the
load time should match lsm's hook_id.
