From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v6] Netfilter ring buffer support
Date: Mon, 12 Mar 2012 14:08:03 +0100
Message-ID: <20120312130803.GA31865@1984>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
 <20120308012849.GA9164@1984>
 <4F5875B5.1090802@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38141 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755360Ab2CLNIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 09:08:11 -0400
Content-Disposition: inline
In-Reply-To: <4F5875B5.1090802@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

On Thu, Mar 08, 2012 at 10:02:45AM +0100, Richard Weinberger wrote:
> On 08.03.2012 02:28, Pablo Neira Ayuso wrote:
> >On Tue, Mar 06, 2012 at 12:19:42AM +0100, Richard Weinberger wrote:
> >>This patch set merges ipt_LOG and ip6t_LOG and adds ring buffer support
> >>to xt_LOG.
> >>
> >>Using "--ring" an user can create LOG rules which log messages into
> >>one or more ring buffers.
> >>Each ring buffer is represented as pipe-like file in
> >>/proc/net/netfilter/nf_log_ring/.
> >
> >I've spent part of the evening testing this and checking its
> >possibilities, the drawbacks that I see for this contribution are:
> >
> >* it uses the /proc entry, we have rejected similar add-ons in the
> >   past that have used these interfaces.
> 
> My fist implementation used sysfs/debug.
> I've switched to /proc/net/netfilter/ to make it consistent to the other
> netfilter stuff...
>
> Moving back to sysfs/debug/whatever can be done within minutes.
>
> >* one single reader can be reading at a time.
> 
> In which use-cache you need two _consuming_ readers?

One scenario in which two sysadmins are checking the logs to debug
some issues seems reasonable to me.

Anyway, my main points after testing several your buffer-ring things
are at the bottom of this email.

> Steve's ring_buffer supports also concurrent non-consuming reads.
> I can add support for this...
> 
> >Having said that, I still think that the feature that this provides
> >is useful, but I think that implementing this in user-space over
> >nfnetlink_log results in a much more flexible solution.
> >
> >I have made proof-of-concept daemon (it's a quick hack of several
> >hours) that implements the similar feature over nfnetlink_log,
> >advantages are:
> >
> >* You don't need to upgrade your kernel / iptables.
> >* You only need to install libnfnetlink, libnetfilter_log and the
> >   daemon.
> >* It can be extended to support multiple readers.
> >
> >So my conclusion is that you can make this in userspace in a much more
> >flexible way.
> >
> >You can find it here:
> >
> >http://1984.lsi.us.es/git/rlogd/
> >
> >The initial commit provides some description on how to use it:
> >
> >http://1984.lsi.us.es/git/rlogd/commit/?id=ccb88a8dc8ad674b860f2d3edabf07fe4830baf3
> >
> >I don't plan to develop / maintain that software. The last thing I
> >want in my todo list is yet another thing to maintain. If someone is
> >interested, please, feel free to grab it, make a nice website for it
> >and maintain it.
> >
> >The repository also contains an unfinished patch to add LOG format
> >support to libnetfilter_log.
> 
> I really don't like this rlogd thing.
>
> 1. It's yet another random netfilter userspace component.
> Please don't fragment it more.

IMO modularity is a good thing, independent user-space components
allow you to just upgrade the thing that you require.

> Installing iptables/conntrack/ulogd/etc... is already enough PITA
> because not all distros ship all this clustered components.

I think that recompiling your kernel or even wait until your distro
ships the new kernel with new extensions will take longer than packaging
some small user-space software and deploying it. Not talking about
packaging a new iptables package containing support for some new
feature.

This rlogd proof-of-concept thing (and user-space stuff in general)
will:

1) not need any kernel update.
2) be very easy to make a package and to deploy.
3) require no Linux kernel update since NFLOG has been there since
   long time.

> 2. As I described in my very fist RLOG patch, NFLOG does not include
> the same information.
> You cannot derive "PHYSIN" and "PHYSOUT" from the packet header.

Looking at the code, those are included if bridging is enabled.
Otherwise, I'll be happy to take a patch for this.

> 3. rlogd needs NFLOG which copies every packet (header) to userspace.
> What about performance...?

Reliability is also important, running things in user-space means that
bugs will no crash your system. Instead, they may crash your logging
daemon.

What I find hard to justify is that this feature can be implemented in
user-space with the existing netfilter logging interface.
