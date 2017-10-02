From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [kernel-hardening] [PATCH 0/2] capability controlled
 user-namespaces
Date: Mon, 2 Oct 2017 12:14:10 -0500
Message-ID: <20171002171410.GA19611@mail.hallyn.com>
References: <20170929230952.29673-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Kernel-hardening <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Mahesh Bandewar <mahesh-bmGAjcP2qsnk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170929230952.29673-1-mahesh-bmGAjcP2qsnk1uMJSBkQmQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Quoting Mahesh Bandewar (mahesh-bmGAjcP2qsnk1uMJSBkQmQ@public.gmane.org):
> From: Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> [Same as the previous RFC series sent on 9/21]
> 
> TL;DR version
> -------------
> Creating a sandbox environment with namespaces is challenging
> considering what these sandboxed processes can engage into. e.g.
> CVE-2017-6074, CVE-2017-7184, CVE-2017-7308 etc. just to name few.
> Current form of user-namespaces, however, if changed a bit can allow
> us to create a sandbox environment without locking down user-
> namespaces.
> 
> Detailed version
> ----------------

Hi,

still struggling with how I feel about the idea in general.

So is the intent mainly that if/when there comes an 0-day which allows
users with CAP_NET_ADMIN in any namespace to gain privilege on the host,
then this can be used as a stop-gap measure until there is a proper fix?

Otherwise, do you have any guidance for how people should use this?

IMO it should be heavily discouraged to use this tool as a regular
day to day configuration, as I'm not sure there is any "educated"
decision to be made, even by those who are in the know, about what
to put in this set.

> Problem
> -------
> User-namespaces in the current form have increased the attack surface as
> any process can acquire capabilities which are not available to them (by
> default) by performing combination of clone()/unshare()/setns() syscalls.
> 
>     #define _GNU_SOURCE
>     #include <stdio.h>
>     #include <sched.h>
>     #include <netinet/in.h>
> 
>     int main(int ac, char **av)
>     {
>         int sock = -1;
> 
>         printf("Attempting to open RAW socket before unshare()...\n");
>         sock = socket(AF_INET6, SOCK_RAW, IPPROTO_RAW);
>         if (sock < 0) {
>             perror("socket() SOCK_RAW failed: ");
>         } else {
>             printf("Successfully opened RAW-Sock before unshare().\n");
>             close(sock);
>             sock = -1;
>         }
> 
>         if (unshare(CLONE_NEWUSER | CLONE_NEWNET) < 0) {
>             perror("unshare() failed: ");
>             return 1;
>         }
> 
>         printf("Attempting to open RAW socket after unshare()...\n");
>         sock = socket(AF_INET6, SOCK_RAW, IPPROTO_RAW);
>         if (sock < 0) {
>             perror("socket() SOCK_RAW failed: ");
>         } else {
>             printf("Successfully opened RAW-Sock after unshare().\n");
>             close(sock);
>             sock = -1;
>         }
> 
>         return 0;
>     }
> 
> The above example shows how easy it is to acquire NET_RAW capabilities
> and once acquired, these processes could take benefit of above mentioned
> or similar issues discovered/undiscovered with malicious intent. Note
> that this is just an example and the problem/solution is not limited
> to NET_RAW capability *only*. 
> 
> The easiest fix one can apply here is to lock-down user-namespaces which
> many of the distros do (i.e. don't allow users to create user namespaces),
> but unfortunately that prevents everyone from using them.
> 
> Approach
> --------
> Introduce a notion of 'controlled' user-namespaces. Every process on
> the host is allowed to create user-namespaces (governed by the limit
> imposed by per-ns sysctl) however, mark user-namespaces created by
> sandboxed processes as 'controlled'. Use this 'mark' at the time of
> capability check in conjunction with a global capability whitelist.
> If the capability is not whitelisted, processes that belong to 
> controlled user-namespaces will not be allowed.
> 
> Once a user-ns is marked as 'controlled'; all its child user-
> namespaces are marked as 'controlled' too.
> 
> A global whitelist is list of capabilities governed by the
> sysctl which is available to (privileged) user in init-ns to modify
> while it's applicable to all controlled user-namespaces on the host.
> 
> Marking user-namespaces controlled without modifying the whitelist is
> equivalent of the current behavior. The default value of whitelist includes
> all capabilities so that the compatibility is maintained. However it gives
> admins fine-grained ability to control various capabilities system wide
> without locking down user-namespaces.
> 
> Please see individual patches in this series.
> 
> Mahesh Bandewar (2):
>   capability: introduce sysctl for controlled user-ns capability
>     whitelist
>   userns: control capabilities of some user namespaces
> 
>  Documentation/sysctl/kernel.txt | 21 +++++++++++++++++
>  include/linux/capability.h      |  4 ++++
>  include/linux/user_namespace.h  | 20 ++++++++++++++++
>  kernel/capability.c             | 52 +++++++++++++++++++++++++++++++++++++++++
>  kernel/sysctl.c                 |  5 ++++
>  kernel/user_namespace.c         |  3 +++
>  security/commoncap.c            |  8 +++++++
>  7 files changed, 113 insertions(+)
> 
> -- 
> 2.14.2.822.g60be5d43e6-goog
