From: Djalal Harouni <tixxdz@gmail.com>
Subject: Re: [PATCH v4 next 0/3] modules: automatic module
 loading restrictions
Date: Tue, 23 May 2017 15:02:38 +0200
Message-ID: <CAEiveUdW_pRgPcQ0Rotwt+gaNEfoE6FyBp52Rb4TnhccBd1m6Q@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <20170522120848.GA3003@openwall.com> <CAEiveUdqfMk4+vLg6TaEJNSGwoQHxYq0P4aqZoL4i9GgR3Vdtw@mail.gmail.com>
 <20170522164323.GA2048@openwall.com> <CAEiveUdb=yc5Gt_+pU_hfNdoNBP0JsUL1QUydNZgc2tD7n1h1w@mail.gmail.com>
 <CAGXu5jKGnG74KE-k9JPaH1bNqT5nbVioaeu_5sAKQ+4kgp-0Ng@mail.gmail.com> <CALCETrXyf3vM+NdFNcjwaOZs1KFJomuTL0DobXoH9Z68k8dknQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>, Solar Designer <solar@openwall.com>,
	linux-kernel <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>,
	"Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ingo Molnar <mingo@kernel.org>,
	Linux API <linux-api@vger.kernel.org>, Dongsu Park <dpark@posteo.net>,
	Casey Schaufler <casey@schaufler-ca.com>, Jonathan Corbet <corbet@lwn.net>,
To: Andy Lutomirski <luto@kernel.org>
Return-path: <kernel-hardening-return-7996-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXyf3vM+NdFNcjwaOZs1KFJomuTL0DobXoH9Z68k8dknQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 1:38 AM, Andy Lutomirski <luto@kernel.org> wrote:
> On Mon, May 22, 2017 at 4:07 PM, Kees Cook <keescook@chromium.org> wrote:
>> On Mon, May 22, 2017 at 12:55 PM, Djalal Harouni <tixxdz@gmail.com> wrote:
>>> On Mon, May 22, 2017 at 6:43 PM, Solar Designer <solar@openwall.com> wrote:
>>>> On Mon, May 22, 2017 at 03:49:15PM +0200, Djalal Harouni wrote:
>>>>> On Mon, May 22, 2017 at 2:08 PM, Solar Designer <solar@openwall.com> wrote:
>>>>> > On Mon, May 22, 2017 at 01:57:03PM +0200, Djalal Harouni wrote:
>>>>> >> *) When modules_autoload_mode is set to (2), automatic module loading is
>>>>> >> disabled for all. Once set, this value can not be changed.
>>>>> >
>>>>> > What purpose does this securelevel-like property ("Once set, this value
>>>>> > can not be changed.") serve here?  I think this mode 2 is needed, but
>>>>> > without this extra property, which is bypassable by e.g. explicitly
>>>>> > loaded kernel modules anyway (and that's OK).
>>>>>
>>>>> My reasoning about "Once set, this value can not be changed" is mainly for:
>>>>>
>>>>> If you have some systems where modules are not updated for any given
>>>>> reason, then the only one who will be able to load a module is an
>>>>> administrator, basically this is a shortcut for:
>>>>>
>>>>> * Apps/services can run with CAP_NET_ADMIN but they are not allowed to
>>>>> auto-load 'netdev' modules.
>>>>>
>>>>> * Explicitly loading modules can be guarded by seccomp filters *per*
>>>>> app, so even if these apps have
>>>>>   CAP_SYS_MODULE they won't be able to explicitly load modules, one
>>>>> has to remount some sysctl /proc/ entries read-only here and remove
>>>>> CAP_SYS_ADMIN for all apps anyway.
>>>>>
>>>>> This mainly serves the purpose of these systems that do not receive
>>>>> updates, if I don't want to expose those kernel interfaces what should
>>>>> I do ? then if I want to unload old versions and replace them with new
>>>>> ones what operation should be allowed ? and only real root of the
>>>>> system can do it. Hence, the "Once set, this value can not be changed"
>>>>> is more of a shortcut, also the idea was put in my mind based on how
>>>>> "modules_disabled" is disabled forever, and some other interfaces. I
>>>>> would say: it is easy to handle a transition from 1) "hey this system
>>>>> is still up to date, some features should be exposed" to 2) "this
>>>>> system is not up to date anymore, only root should expose some
>>>>> features..."
>>>>>
>>>>> Hmm, I am not sure if this answers your question ? :-)
>>>>
>>>> This answers my question, but in a way that I summarize as "there's no
>>>> good reason to include this securelevel-like property".
>>>>
>>>
>>> Hmm, sorry I did forget to add in my previous comment that with such
>>> systems, CAP_SYS_MODULE can be used to reset the
>>> "modules_autoload_mode" sysctl back from mode 2 to mode 1, even if we
>>> disable it privileged tasks can be triggered to overwrite the sysctl
>>> flag and get it back unless /proc is read-only... that's one of the
>>> points, it should not be so easy to relax it.
>>
>> I'm on the fence. For modules_disabled and Yama, it was tied to
>> CAP_SYS_ADMIN, basically designed to be a at-boot setting that could
>> not later be undone by an attacker gaining that privilege, keeping
>> them out of either kernel memory or existing user process memory.
>> Here, it's CAP_SYS_MODULE... it's hard to imagine the situation where
>> a CAP_SYS_MODULE-capable process could write to this sysctl but NOT
>> issue direct modprobe requests, but it's _possible_ via crazy symlink
>> games to trick capable processes into writing to sysctls. We've seen
>> this multiple times before, and it's a way for attackers to turn a
>> single privileged write into a privileged exec.
>>
>> I might turn the question around, though: why would we want to have it
>> changeable at this setting?
>>
>> I'm fine leaving that piece off, either way.
>
> I think that having the un-resettable mode is unnecessary.  We should
> have option that disables loading modules entirely and cannot be
> unset.  (That means no explicit loads and not implicit loads.)  Maybe
> we already have this.  Otherwise, tightening caps needed for implicit
> loads should just be a normal yes/no setting IMO.

Ok, so as requested by you and Alexander in the other email, I will
remove the un-resettable property, if there is no general agreement,
better leave it for future.

I would have preferred if it is "yes/no" (in systemd the module
protection and other directives are also only 'yes/no').  But 1)
backward compatibility for unprivileged loading, 2) capabilities:
CAP_SYS_MODULE, CAP_NET_ADMIN use cases and exploits against
CAP_NET_ADMIN modules, and finally 3) separate and disable implicit
operation from the explicit one for various reasons that are noted in
the commit log like explicitly load the good module version, concluded
that we need three modes!

Thanks!

-- 
tixxdz
