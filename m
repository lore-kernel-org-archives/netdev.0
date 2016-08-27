From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Sat, 27 Aug 2016 00:40:14 -0700
Message-ID: <CALCETrWhzk4ukY7-Ynr5Hb9wHGTpcHUe2TvkVRxgvoU0-esDAA@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
	David Drysdale <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>, James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linux API <linux-api@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-4481-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> Hi,
>
> This series is a proof of concept to fill some missing part of seccomp as=
 the
> ability to check syscall argument pointers or creating more dynamic secur=
ity
> policies. The goal of this new stackable Linux Security Module (LSM) call=
ed
> Landlock is to allow any process, including unprivileged ones, to create
> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or the
> OpenBSD Pledge. This kind of sandbox help to mitigate the security impact=
 of
> bugs or unexpected/malicious behaviors in userland applications.
>
> The first RFC [1] was focused on extending seccomp while staying at the s=
yscall
> level. This brought a working PoC but with some (mitigated) ToCToU race
> conditions due to the seccomp ptrace hole (now fixed) and the non-atomic
> syscall argument evaluation (hence the LSM hooks).
>
>
> # Landlock LSM
>
> This second RFC is a fresh revamp of the code while keeping some working =
ideas.
> This series is mainly focused on LSM hooks, while keeping the possibility=
 to
> tied them to syscalls. This new code removes all race conditions by desig=
n. It
> now use eBPF instead of a subset of cBPF (as used by seccomp-bpf). This a=
llow
> to remove the previous stacked cBPF hack to do complex access checks than=
ks to
> dedicated eBPF functions. An eBPF program is still very limited (i.e. can=
 only
> call a whitelist of functions) and can not do a denial of service (i.e. n=
o
> loop). The other major improvement is the replacement of the previous cus=
tom
> checker groups of syscall arguments with a new dedicated eBPF map to coll=
ect
> and compare Landlock handles with system resources (e.g. files or network
> connections).
>
> The approach taken is to add the minimum amount of code while still allow=
ing
> the userland to create quite complex access rules. A dedicated security p=
olicy
> language such as used by SELinux, AppArmor and other major LSMs is a lot =
of
> code and dedicated to a trusted process (i.e. root/administrator).
>

I think there might be a problem with the current design.  If I add a
seccomp filter that uses RET_LANDLOCK and some landlock filters, what
happens if a second seccomp filter *also* uses RET_LANDLOCK?  I think
they'll interfere with each other.  It might end up being necessary to
require only one landlock seccomp layer at a time or to find a way to
stick all the filters in a layer together with the LSM callbacks or
maybe to just drop RET_LANDLOCK and let the callbacks look at the
syscall args.

BTW, what happens if an LSM hook is called outside a syscall context,
e.g. from a page fault?

>
>
> # Sandbox example with conditional access control depending on cgroup
>
>   $ mkdir /sys/fs/cgroup/sandboxed
>   $ ls /home
>   user1
>   $ LANDLOCK_CGROUPS=3D'/sys/fs/cgroup/sandboxed' \
>       LANDLOCK_ALLOWED=3D'/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>       ./sandbox /bin/sh -i
>   $ ls /home
>   user1
>   $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
>   $ ls /home
>   ls: cannot open directory '/home': Permission denied
>

Something occurs to me that isn't strictly relevant to landlock but
may be relevant to unprivileged cgroups: can you cause trouble by
setting up a nastily-configured cgroup and running a setuid program in
it?
