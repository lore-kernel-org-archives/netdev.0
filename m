From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command as non-root
Date: Wed, 19 Mar 2008 23:14:21 +0100
Message-ID: <939d53060803191514i4f225043g961d4de932a209ce@mail.gmail.com>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>
	 <47D98510.60801@imap.cc>
	 <939d53060803191052o2f43b75cu426d51f9f24e2a46@mail.gmail.com>
	 <20080319141608.ede86a86.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com, xemul@openvz.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:30580 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935171AbYCSWOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 18:14:22 -0400
Received: by rv-out-0910.google.com with SMTP id k20so326334rvb.1
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 15:14:21 -0700 (PDT)
In-Reply-To: <20080319141608.ede86a86.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2008 at 10:16 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Wed, 19 Mar 2008 18:52:41 +0100
>  "Benjamin Thery" <ben.thery@gmail.com> wrote:
>
>  > Tilman,
>  >
>  > I've finally managed to reproduce your problem with Postfix on one of
>  > my victims.
>  >
>  > Earlier, in the afternoon, I wrote a piece of code that triggered a
>  > similar behaviour,
>  > but I wasn't sure it was exactly the problem you found. So, I've
>  > rebuilt Postfix, added
>  > some traces and, voila, same issue as yours.
>  > (The version of Postfix originally  installed on my machine seems to
>  > have IPv6 disabled)
>  >
>  > I bisected the problem to the commit "[NET]: Make /proc/net a symlink
>  > on /proc/self/net (v3)"
>  >
>  > Here is what happens:
>  >
>  > - Recently /proc/net has been moved to /proc/self/net, and
>  > /proc/self/net is a symlink
>  >   on this directory.
>  > - Before that everybody could access /proc/net and read /proc/net/if_inet6:
>  >    dr-xr-xr-x   6 root      root              0 2008-03-05 15:23 /proc/net
>  >
>  > - Now, /proc/self/net has a more restrictive access mode and ony the
>  > owner of the
>  >   process can enter the directory:
>  >   dr-xr--r-- 5 toto toto 0 Mar 19 17:30 net
>  >
>  >   This is not a problem in most of the cases, but it becomes annoying
>  > when a process
>  >   decides to change its UID or GID. It may loose access to its own
>  > /proc/self/net entries.
>  >
>  > - What happens in the Postfix case is the 'sendmail' process executes the
>  >    '/usr/sbin/postdrop' binary to enqueue the message, but unfortunately
>  >    '/usr/bin/postdrop' has the setgid bit set:
>  >    -rwxr-sr-x 1 root postdrop 479475 Mar 19 17:14 /usr/sbin/postdrop
>  >
>  >    The process egid changes and this seems to be problematic to access
>  >    /proc/self/net/if_inet6. :)
>  >
>  > I've attached a tiny test program that can be used to reproduce the problem
>  > without Postfix.
>  > - Either execute it as root and give it an unprivileged uid in argument
>  >   ./test-proc_net_if_inet6 1001
>  >
>  > - Or change its ownership and access mode to: -rwxr-sr-x root postdrop
>  >   and execute it as a lambda user.
>  >    chown root:postdrop test-proc_net_if_inet6; chmod 2755 test-proc_net_if_inet6
>  >    ./test-proc_net_if_inet6
>  >
>  > I've found the cause but not the fix. :)
>  > (Adding Pavel in cc:)
>  >
>
>  Thanks for that - most useful.
>
>  Although this is advertised as a 2.6.25-rc5-mm1 problem, I assume the
>  regression is also in mainline? 2.6.25-rc6?

Yes, it is in mainline. I reproduced it on 2.6.25-rc5.

Benjamin
