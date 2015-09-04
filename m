From: Kees Cook <keescook@chromium.org>
Subject: Re: eBPF / seccomp globals?
Date: Thu, 3 Sep 2015 21:01:47 -0700
Message-ID: <CAGXu5j+M6nGHaRSb4uxGAcTyWD3SpWRskd89et7yfMnp3cgzgQ@mail.gmail.com>
References: <CAMkWEXPxrth6Bt1X1OhAQYMWPM5XSy2oJEtCkv1grLFNYo5Edg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Michael Tirado <mtirado418@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMkWEXPxrth6Bt1X1OhAQYMWPM5XSy2oJEtCkv1grLFNYo5Edg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2015 at 6:01 PM, Michael Tirado <mtirado418@gmail.com> wrote:
> Hiyall,
>
> I have created a seccomp white list filter for a program that launches
> other less trustworthy programs.  It's working great so far, but I
> have run into a little roadblock.  the launcher program needs to call
> execve as it's final step, but that may not be present in the white
> list.  I am wondering if there is any way to use some sort of global
> variable that will be preserved between syscall filter calls so that I
> can allow only one execve, if not present in white list by
> incrementing a counter variable.
>
> I see that in Documentation/networking/filter.txt one of the registers
> is documented as being a pointer to struct sk_buff, in the seccomp
> context this is a pointer to struct seccomp_data  instead, right?  and
> the line about callee saved registers R6-R9  probably refers to them
> being saved across calls within that filter, and not calls between
> filters?
>
> My apologies if this is not the appropriate place to ask for help, but
> it is difficult to find useful information on how eBPF works, and is a
> bit confusing trying to figure out the differences between seccomp and
> net filters, and the old bpf code kicking around short of spending
> countless hours reading through all of it.  If anybody has a some
> links to share I would be very grateful.  the only way I can think to
> make this work otherwise is to mount everything as MS_NOEXEC in the
> new namespace, but that just feels wrong.

For documentation, there's some great slides on seccomp from Plumber's
this year[1].

At present, there is no variable state beyond the syscall context (PC,
args) available to seccomp filters. The no_new_privs prctl was added
to reduce the risk of including execve in a filter's whitelist, but
that isn't as strong as the "exec once" feature you want.

What we did in Chrome OS was to use the "minijail" tool[2] to
LD_PRELOAD a .so that sets up the seccomp filter after the exec. It's
a bit of a hack, but works in well-defined environments. You are
talking about namespaces, though, so maybe minijail is worth a look?
It does that too and a whole lot more.

As for using maps via eBPF in seccomp, it's on the horizon, but it
comes with a lot exposure that I haven't finished pondering, so I
don't think those features will be added soon.

-Kees

[1] http://man7.org/conf/lpc2015/limiting_kernel_attack_surface_with_seccomp-LPC_2015-Kerrisk.pdf
[2] see subdirectory "minijail" after "git clone
https://chromium.googlesource.com/chromiumos/platform2/"


-- 
Kees Cook
Chrome OS Security
