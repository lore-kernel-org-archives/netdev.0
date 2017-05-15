From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] kmod: don't load module unless req process has
 CAP_SYS_MODULE
Date: Mon, 15 May 2017 08:10:16 +0200
Message-ID: <20170515061016.GA28741@kroah.com>
References: <20170512232259.10820-1-mahesh@bandewar.net>
 <20170514104537.GA29323@kroah.com>
 <CAF2d9jh6zARipRGM92drOjjrpicF6177cnUf=6oHbR9tHX1ObA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Ingo Molnar <mingo@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Kees Cook <keescook@chromium.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar
         =?utf-8?B?KOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL4=?=
         =?utf-8?B?4KSwKQ==?= <maheshb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAF2d9jh6zARipRGM92drOjjrpicF6177cnUf=6oHbR9tHX1ObA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 14, 2017 at 07:42:08PM -0700, Mahesh Bandewar (महेश बंडेवार) wrote:
> On Sun, May 14, 2017 at 3:45 AM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> > On Fri, May 12, 2017 at 04:22:59PM -0700, Mahesh Bandewar wrote:
> >> From: Mahesh Bandewar <maheshb@google.com>
> >>
> [...]
> >>   Now try to create a bridge inside this newly created net-ns which would
> >>   mean bridge module need to be loaded.
> >>   # ip link add br0 type bridge
> >>   # echo $?
> >>   0
> >>   # lsmod | grep bridge
> >>   bridge                110592  0
> >>   stp                    16384  1 bridge
> >>   llc                    16384  2 bridge,stp
> >>   #
> >>
> >>   After this patch -
> >>   # ip link add br0 type bridge
> >>   RTNETLINK answers: Operation not supported
> >>   # echo $?
> >>   2
> >>   # lsmod | grep bridge
> >>   #
> >
> > Well, it only loads this because the kernel asked for it to be loaded,
> > right?
> >
> Yes, kernel asked for it because of a user action.

Which is good, that's the way it is supposed to work.

> >> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> >> ---
> >>  kernel/kmod.c | 3 +++
> >>  1 file changed, 3 insertions(+)
> >>
> >> diff --git a/kernel/kmod.c b/kernel/kmod.c
> >> index 563f97e2be36..ac30157169b7 100644
> >> --- a/kernel/kmod.c
> >> +++ b/kernel/kmod.c
> >> @@ -133,6 +133,9 @@ int __request_module(bool wait, const char *fmt, ...)
> >>  #define MAX_KMOD_CONCURRENT 50       /* Completely arbitrary value - KAO */
> >>       static int kmod_loop_msg;
> >>
> >> +     if (!capable(CAP_SYS_MODULE))
> >> +             return -EPERM;
> >
> > At first glance this looks right, but I'm worried what this will break
> > that currently relies on this.  There might be lots of systems that are
> > used to this being the method that the needed module is requested.  What
> > about when userspace asks for a random char device and that module is
> > then loaded?  Does this patch break that functionality?
> >
> Any module when loaded gets loaded system-wide as we can't allow
> module loading per-ns.

That's the joys of "namespaces" :)

> To validate the behavior I was comparing it
> with insmod/modprobe, if that doesn't allow because of lack of this
> capability in default-ns, then this *indirect* method of loading
> module should not allow the same action and the behavior should be
> consistent. So with that logic if userspace asks for a random
> char-device if insmod/modprobe cannot load it, then this method should
> not load it either for the consistency, right?

No, that would break things that are expecting this type of
functionality, right?

What is the "problem" with loading kernel modules when userspace asks
for the functionality involved in them?  There has been some work with
the LSM interface to disallow this if so desired, why not just use that
instead?

thanks,

greg k-h
