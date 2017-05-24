From: Djalal Harouni <tixxdz@gmail.com>
Subject: Re: [PATCH v4 next 0/3] modules: automatic module
 loading restrictions
Date: Wed, 24 May 2017 20:06:43 +0200
Message-ID: <CAEiveUfpoFhhADtLWFoZR53PBABCqhMrKoDZPNF_h5sQ3OL8KQ@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <20170522120848.GA3003@openwall.com> <CAEiveUdqfMk4+vLg6TaEJNSGwoQHxYq0P4aqZoL4i9GgR3Vdtw@mail.gmail.com>
 <20170522164323.GA2048@openwall.com> <CAEiveUdb=yc5Gt_+pU_hfNdoNBP0JsUL1QUydNZgc2tD7n1h1w@mail.gmail.com>
 <CAGXu5jKGnG74KE-k9JPaH1bNqT5nbVioaeu_5sAKQ+4kgp-0Ng@mail.gmail.com> <20170523074808.GA4562@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>, linux-kernel <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andy Lutomirski <luto@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>,
	"Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ingo Molnar <mingo@kernel.org>,
	Linux API <linux-api@vger.kernel.org>, Dongsu Park <dpark@posteo.net>,
	Casey Schaufler <casey@schaufler-ca.com>, Jonathan Corbet <corbet@lwn.net>,
	Arn
To: Solar Designer <solar@openwall.com>
Return-path: <kernel-hardening-return-8025-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170523074808.GA4562@openwall.com>
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 9:48 AM, Solar Designer <solar@openwall.com> wrote:
>> >>> On Mon, May 22, 2017 at 2:08 PM, Solar Designer <solar@openwall.com> wrote:
>> >>> > On Mon, May 22, 2017 at 01:57:03PM +0200, Djalal Harouni wrote:
>> >>> >> *) When modules_autoload_mode is set to (2), automatic module loading is
>> >>> >> disabled for all. Once set, this value can not be changed.
>> >>> >
>> >>> > What purpose does this securelevel-like property ("Once set, this value
>> >>> > can not be changed.") serve here?  I think this mode 2 is needed, but
>> >>> > without this extra property, which is bypassable by e.g. explicitly
>> >>> > loaded kernel modules anyway (and that's OK).
>
> On Mon, May 22, 2017 at 04:07:56PM -0700, Kees Cook wrote:
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
>
> OK, tricking a process via crazy symlink games is finally a potentially
> valid reason.  The question then becomes: are there perhaps so many
> other important sysctl's, disk files, etc. (which the vulnerable capable
> process could similarly be tricked into writing) so that specifically
> resetting modules_autoload_mode isn't particularly lucrative?  I think
> that the answer to that is usually yes.  Another related question: do we
> really want to inconsistently single out a handful of sysctl's for this
> kind of extra protection?  I think not.
>
> I agree there are some other settings where being unable to reset them
> makes sense, but I think this isn't one of those.
>

Alright, I already replied to Andy, since it was requested I will drop
it. I definitely prefer that we have something merged and usable ;-)


>> I might turn the question around, though: why would we want to have it
>> changeable at this setting?
>
> Convenience for the sysadmin - being able to correct one's error (e.g.,
> wrong order of shell commands), respond to new findings (thought module
> autoloading was unneeded after some point, then found out some software
> relies on it), change one's mind, reuse a system differently than
> originally intended without a forced reboot.
>
>> I'm fine leaving that piece off, either way.
>
> I'm also fine with either decision.  I just thought I'd point out what
> looked weird to me.
>
> I think this is an important patch that should get in, but primarily
> for modules_autoload_mode=1, which many distros could make the default
> (and maybe the kernel eventually should?)

I do not think that desktop, or interactive systems will set it.
Ubuntu has snaps for their app store, and they can use the per-task
flag and other vendors too Flatpak, etc.


> For modules_autoload_mode=2, we already seem to have the equivalent of
> modprobe=/bin/true (or does it differ subtly, maybe in return values?),
> which I already use at startup on a GPU box like this (preloading
> modules so that the OpenCL backends wouldn't need the autoloading):
>
> nvidia-smi
> nvidia-modprobe -u -c=0
> #modprobe nvidia_uvm
> #modprobe fglrx
>
> sysctl -w kernel.modprobe=/bin/true
> sysctl -w kernel.hotplug=/bin/true
>
> but it's good to also have this supported more explicitly and more
> consistently through modules_autoload_mode=2 while we're at it.  So I
> support having this mode as well.  I just question the need to have it
> non-resettable.
>

Ok, yes with mode=2 it is clear interface, it logs what was denied, it
is consistent with the per-task flag that we want for sandboxes and
desktop, it will work with CONFIG_STATIC_USERMODEHELPER, more
importantly it will avoid doing the usermod upcall, even if one day
the kernel support upcall into namespaces, I'm pretty sure that no one
will like the idea of namespaced modprobe paths, modules are global
anyway, this allows to say we are safe by default from any future
change that may make an upcall into the wrong context, we just avoid
that.


-- 
tixxdz
