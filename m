From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] kmod: don't load module unless req process has
 CAP_SYS_MODULE
Date: Mon, 15 May 2017 08:10:59 +0200
Message-ID: <20170515061059.GB28741@kroah.com>
References: <20170512232259.10820-1-mahesh@bandewar.net>
 <20170514104537.GA29323@kroah.com>
 <87d1bbo81d.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Ingo Molnar <mingo@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:60372 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752184AbdEOGLJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 02:11:09 -0400
Content-Disposition: inline
In-Reply-To: <87d1bbo81d.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 14, 2017 at 08:57:34AM -0500, Eric W. Biederman wrote:
> Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:
> 
> > On Fri, May 12, 2017 at 04:22:59PM -0700, Mahesh Bandewar wrote:
> >> From: Mahesh Bandewar <maheshb@google.com>
> >> 
> >> A process inside random user-ns should not load a module, which is
> >> currently possible. As demonstrated in following scenario -
> >> 
> >>   Create namespaces; especially a user-ns and become root inside.
> >>   $ unshare -rfUp -- unshare -unm -- bash
> >> 
> >>   Try to load the bridge module. It should fail and this is expected!
> >>   #  modprobe bridge
> >>   WARNING: Error inserting stp (/lib/modules/4.11.0-smp-DEV/kernel/net/802/stp.ko): Operation not permitted
> >>   FATAL: Error inserting bridge (/lib/modules/4.11.0-smp-DEV/kernel/net/bridge/bridge.ko): Operation not permitted
> >> 
> >>   Verify bridge module is not loaded.
> >>   # lsmod | grep bridge
> >>   #
> >> 
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
> >> 
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
> >>  #define MAX_KMOD_CONCURRENT 50	/* Completely arbitrary value - KAO */
> >>  	static int kmod_loop_msg;
> >>  
> >> +	if (!capable(CAP_SYS_MODULE))
> >> +		return -EPERM;
> >
> > At first glance this looks right, but I'm worried what this will break
> > that currently relies on this.  There might be lots of systems that are
> > used to this being the method that the needed module is requested.  What
> > about when userspace asks for a random char device and that module is
> > then loaded?  Does this patch break that functionality?
> 
> For the specific example give I think we would be better served by
> adding a capability check at the call site.  In this case CAP_NET_ADMIN
> as those are the capabilities iproute traditionally has.
> 
> We have something similar in dev_load in already in the networking code.
> 
> This limits the people who can't load modules to root user in user
> namespaces.  I would be fine with any other code paths in a user
> namespace getting a similar treatment.
> 
> Eric
> 
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index bcb0f610ee42..6b72528a4636 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2595,7 +2595,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
>  
>                 if (!ops) {
>  #ifdef CONFIG_MODULES
> -                       if (kind[0]) {
> +                       if (kind[0] && capable(CAP_NET_ADMIN)) {
>                                 __rtnl_unlock();
>                                 request_module("rtnl-link-%s", kind);
>                                 rtnl_lock();

I don't object to this if the networking developers don't mind the
change in functionality.  They can handle the fallout :)

thanks,

greg k-h
