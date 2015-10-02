From: Kees Cook <keescook@chromium.org>
Subject: Re: v5 of seccomp filter c/r patches
Date: Fri, 2 Oct 2015 14:10:24 -0700
Message-ID: <CAGXu5jJJoM3NdwSmigWy8trTBATsvkGUDmbZ02QOyU=1tD0Y-w@mail.gmail.com>
References: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 2, 2015 at 9:27 AM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> Hi all,
>
> Here's v5 of the seccomp filter c/r set. The individual patch notes have
> changes, but two highlights are:
>
> * This series is now based on http://patchwork.ozlabs.org/patch/525492/ and
>   will need to be built with that patch applied. This gets rid of two incorrect
>   patches in the previous series and is a nicer API.
>
> * I couldn't figure out a nice way to have SECCOMP_GET_FILTER_FD return the
>   same struct file across calls, so we still need a kcmp command. I've narrowed
>   the scope of the one being added to only compare seccomp fds.
>
> Thoughts welcome,

Hi, sorry I've been slow/busy. I'm finally reading through these threads.

Happy bit:
- avoiding eBPF and just saving the original filters makes things much easier.

Sad bit:
- inventing a new interface for seccompfds feels like massive overkill to me.

While Andy has big dreams, we're not presently doing seccompfd
monitoring, etc. There's no driving user for that kind of interface,
and accepting the maintenance burden of it only for CRIU seems unwise.

So, I'll go back to what I originally proposed at LSS (which it looks
like we're half way there now):

- save the original filter (done!)
- extract filters through a single special-purpose interface (looks
like ptrace is the way to go: root-only, stopped process, etc)
- compare filter content and issue TSYNCs to merge detected sibling
threads, since merging things that weren't merged before creates no
problems.

This means the parenting logic is heuristic, but it's entirely in
userspace, so the complexity burden doesn't live in seccomp which we,
by design, want to keep as simple as possible.

-Kees

-- 
Kees Cook
Chrome OS Security
