From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Thu, 17 Apr 2014 09:05:32 -0700
Message-ID: <CALCETrXwq5JaLXeofmcDfE_0if75uhTUevJqTtthSJZEBTUAcA@mail.gmail.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <20140416180642.GG31074@redhat.com> <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
 <20140416185936.GJ31074@redhat.com> <534FF61B.4010901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vivek Goyal <vgoyal@redhat.com>, Simo Sorce <ssorce@redhat.com>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:36226 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbaDQQFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 12:05:55 -0400
Received: by mail-la0-f53.google.com with SMTP id b8so552851lan.12
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 09:05:53 -0700 (PDT)
In-Reply-To: <534FF61B.4010901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 17, 2014 at 8:41 AM, Daniel J Walsh <dwalsh@redhat.com> wrote:
>
> On 04/16/2014 11:59 AM, Vivek Goyal wrote:
> The two use cases for this patch are:
>
> 1 Logging, to make sure the cgroup information gets correctly attributed
> to the caller.
>

I think that the cgroup information of the opener of the socket should
be used to avoid a whole class of issues where the opener gets someone
else to call write(2).

> 2 Potentially reveal different information to the caller based on the
> cgroup information.
>
> Imagine you want to set up an apache web server that is going to use
> sssd for authentication data.  You might want to reveal a limited set of
> users to the apache service process based on the fact that it is running
> in the apache.service.slice.  If the apache service does the equivalent
> of getent passwd I want to give it different information then say sshd
> did the same calls.

This sounds like it's asking for trouble.  cgroups are not a security
boundary.  ptrace, /proc, existing setuid programs, etc do not respect
cgroups.

In this regard, cgroups are a lot like seccomp.  You can *use* them to
block certain actions, just like you can use seccomp to block
essentially anything.  But I hope that no one ever tries to reveal
different getent information based on which seccomp filter is applied
to a process, and, similarly, it seems extremely risky to reveal
different getent information based on which cgroup is in use.

Cgroups may be even worse here, since the actual cgroup names may
change as systemd and whatever competing managers exist come up with
new and varied ways to use cgroups.

If you want to turn cgroups into a security boundary, it may be
possible to do so.  But I don't see the point.  We have user
namespaces and uids for *exactly* this reason.  User namespaces come
with mount and network namespaces, both of which can be used to
identify who connected to a socket by using different sockets.  User
namespaces also allow using uids for this.

If using different sockets has scaling problems, them having a way to
use cmsg or some similar mechanism to identify your network namespace
seems reasonable, too.

--Andy

P.S. I can flat-out guarantee that anything you do with cgroups will
fsck up completely on my production server, because I use my own
cgroup policy.  Some day I may have to reconcile my policy with
systemd (damn it single-hierarchy people and systemd people, you
should have an option that will make systemd stay the f*ck away from
the unified hierarchy; I *like* systemd in general, but this may be a
show-stopper), but I really don't think that SSSD should be hardcoding
assumptions about the cgroup hierarchy, unless those assumptions are
easily reconfigurable.
