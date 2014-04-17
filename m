From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 17 Apr 2014 12:38:27 -0400
Message-ID: <20140417163827.GA25334@redhat.com>
References: <20140416.085743.1614257692560892039.davem@davemloft.net>
 <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org>
 <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <20140416180642.GG31074@redhat.com>
 <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
 <20140416185936.GJ31074@redhat.com>
 <534FF61B.4010901@redhat.com>
 <1397750674.2628.44.camel@willson.li.ssimo.org>
 <CALCETrUrj2LtAoXp600BD2ANgE2UUEbTYQrK8hHqDR=qpeFPcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simo Sorce <ssorce@redhat.com>, Daniel J Walsh <dwalsh@redhat.com>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923AbaDQQib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2014 12:38:31 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrUrj2LtAoXp600BD2ANgE2UUEbTYQrK8hHqDR=qpeFPcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 17, 2014 at 09:11:11AM -0700, Andy Lutomirski wrote:
> On Thu, Apr 17, 2014 at 9:04 AM, Simo Sorce <ssorce@redhat.com> wrote:
> > On Thu, 2014-04-17 at 08:41 -0700, Daniel J Walsh wrote:
> >> On 04/16/2014 11:59 AM, Vivek Goyal wrote:
> >> > On Wed, Apr 16, 2014 at 11:13:31AM -0700, Andy Lutomirski wrote:
> >> >> On Wed, Apr 16, 2014 at 11:06 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> >> >>> On Wed, Apr 16, 2014 at 09:31:25AM -0700, Andy Lutomirski wrote:
> >> >>> I am not sure how same issue with happen with cgroups. In the case of
> >> >>> socket example, you are forcing a setuid program to write to standard
> >> >>> output and that setuid program will run in same cgroup as caller and
> >> >>> will have same cgroup as caller. So even if somebody was using cgroup
> >> >>> information for authentication, atleast in this particular case it
> >> >>> will not be a problem. Both unpriviliged and priviliged programs has
> >> >>> same cgroups.
> >> >>>
> >> >> I'm not sure that there's an actual attackable program.  But I also
> >> >> see no reason to be convinced that there isn't one, and the problem
> >> >> can easily be avoided by requiring programs to explicitly ask to send
> >> >> their cgroup.
> >> > If you can't prove that there is something fundamentally wrong with
> >> > passing cgroup info to receiver, there is no reason to block these
> >> > patches either.
> >> >
> >> > We can't fix the problems which we can't see. You are saying that I
> >> > don't know what kind of problem can happen due to cgroup passing. Still
> >> > that does not mean none of the problems exist. So let us not pass cgroup
> >> > info by default and ask client to opt in.
> >> >
> >> > I don't think this is a very convincing argument.
> >> >
> >> > To me, if we can't see anything fundamentally wrong with passing cgroup
> >> > info, we should take these patches in. And once we figure out that there
> >> > is are problematic use cases, then implement SO_NOPASSCGROUP and
> >> > SO_NOPEERCRED  and allow problematic clients to opt out.
> >> >
> >> > Thanks
> >> > Vivek
> >> The two use cases for this patch are:
> >
> > Let me add some caveats to explain what is used, as the 2 cases map to
> > the 2 different new options.
> >
> >> 1 Logging, to make sure the cgroup information gets correctly attributed
> >> to the caller.
> >
> > In here the logging system wants to know *who* logged, if the cgroups of
> > the process actually doing the logging changes, that's what the logging
> > system wants to know.
> > If somehow a setuid binary can change the cgroups, then the logging
> > system *wants* to know that these logs are coming from there, because
> > they sure are not coming from the original bounded process anymore.
> >
> > This use case wants to use SO_PASSCGROUP as it wants to know who the
> > current writer is, not who opened the file descriptor.
> 
> No.  The logging daemon thinks it wants to know who the writer is, but
> the logging daemon is wrong.  It actually wants to know who composed a
> log message destined to it.  The caller of write(2) may or may not be
> the same entity.

So say, a process A writes a message, passes that message to process B and
asks process B to send the message to logger daemon. You think logger
deamon is interested in knowing who originally wrote the message (process A)
instead of who sent the message(process B)? I think this is wrong.

Logger daemon is interested in logging who actually *sent* the message
and does not care who originally *wrote* the message.

> 
> If this form of SO_PASSCGROUP somehow makes it into a pull request for
> Linus, I will ask him not to pull it and/or to revert it.  I think
> he'll agree that write(2) MUST NOT care who called it.  Yes, I don't
> see how this is exploitable on my machine, but it's a mistake for the
> same reason that the netlink crap in CVE-2014-0181 is a mistake.

There is no issue with usage of SO_PASSCGROUP information with logger
example. You are assuming that people are going to use SO_PASSCGROUP
for security related stuff.

So to me, argument should be made with systemd or any other application
if they try to use it for any unsafe purposes. Logger is a very valid
use case and for that purpose SO_PASSCGROUP patchset should be go in.

Thanks
Vivek
