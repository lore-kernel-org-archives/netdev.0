From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: v2 of seccomp filter c/r patches
Date: Tue, 15 Sep 2015 10:07:38 -0600
Message-ID: <20150915160738.GJ31864@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <CALCETrVYtv1=g-xPjQ-LiX+5GK3xtB6a2hYbat0TuU-Bd4QA6Q@mail.gmail.com>
 <CALCETrWxLMSgdsdT9gTL80LSovONmCcTYjzqrHqF-WdJ4BN1Uw@mail.gmail.com>
 <20150911172806.GA7244@smitten>
 <CALCETrWH0vLZwkOV6JCnC-pLaHe0dboXs5-ETkXFCR9X-aq7qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Oleg Nesterov <oleg@redhat.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Linux API <linux-api@vger.kernel.org>,
	Will Drewry <wad@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWH0vLZwkOV6JCnC-pLaHe0dboXs5-ETkXFCR9X-aq7qw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

On Mon, Sep 14, 2015 at 10:52:46AM -0700, Andy Lutomirski wrote:
>
> I'm not sure I entirely like this solution...

Ok. Since we also aren't going to do all the eBPF stuff now, how about
something that looks like this:

struct seccomp_layer {
  unsigned int size;
  unsigned int type; /* SECCOMP_BPF_CLASSIC or SECCOMP_EBPF or ... */
  bool inherited;
  union {
    unsigned int insn_cnt;
    struct bpf_insn *insns;
  };
};

with a ptrace command:

ptrace(PTRACE_SECCOMP_DUMP_LAYER, pid, i, &layer);

If we save a pointer to the current seccomp filter on fork (if there
is one), then I think the inherited flag is just,

inherited = is_ancestor(child->seccomp.filter, child->seccomp.inherited_filter)

In order to restore this (so it can be checkpointed again), we need a
command that looks like:

seccomp(SECCOMP_INHERIT_FILTER);

which sets the current and inherited filter to that of the parent
process. (Optionally we could have seccomp(SECCOMP_INHERIT_FILTER, i)
to inherit the ith filter from the parent, but we can coordinate this
via userpace so it's not strictly necessary.) So the whole c/r process
looks something like:

--- dump ---

for (i = 0; true; i++) {
  ret = ptrace(PTRACE_SECCOMP_DUMP_FILTER, pid, i, &layer);
  if (ret == -ESRCH)
    break;
  if (ret < 0)
    /* real error */

  /* save the filter if it's not inherited, if it is, mark the filter
   * to be inherited from ppid; note that this index is walking up the
   * tree following filter->prev, and the index we want to reason
   * about on restore is walking down, so we should reverse the whole
   * array.
   */
}

--- restore ---

if (have_inherited_filters) {
  wait_for_ppid_seccomp_restore(n_inherited);
  seccomp(SECCOMP_INHERIT_FILTER);
  signal_done_inheriting();
}

for (i = 0; i < n_filters; i++) {
  seccomp(SECCOMP_SET_MODE_FILTER, ...);
  if (child_inherited_filter(i))
    signal_children_filter(i);
}

I played around with an implementation of SECCOMP_INHERIT_FILTER last
night and I think I have one that might work. Thoughts?

Tycho
