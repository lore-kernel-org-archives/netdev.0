From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: add sysctl allow_so_priority for SO_PRIORITY setsockopt
Date: Sat, 22 Oct 2011 01:27:03 -0700
Message-ID: <CAHo-OoyVSbsxb8U3Y5WCNRsxjr00g1O3HJcT1fmu5cmP5i-JsA@mail.gmail.com>
References: <1319235725-3046-1-git-send-email-zenczykowski@gmail.com>
	<20111022.000406.350185785547409199.davem@davemloft.net>
	<CAHo-OoxtAmzPjr4R7jQOk9GGQo7i-qVmoaY8vTYDQDj1HXsPNA@mail.gmail.com>
	<20111022.025836.1306779710775525629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41235 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab1JVI1D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 04:27:03 -0400
Received: by yxl42 with SMTP id 42so1937865yxl.19
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2011 01:27:03 -0700 (PDT)
In-Reply-To: <20111022.025836.1306779710775525629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I also don't see why we'd want to allow disabling this either.

> I really hate these patches that offer ways to disable things
> that normally work, and thus break apps when the non-default
> is selected.

Well... the purpose of settings like this is precisely to break functio=
nality
when the default is not set ;-)

> I kind of have a feeling the kind of situation you're trying to
> account for, you have some cloud where people run random stuff
> that you don't control.

Yes, I have control of the kernel, I have control of root, I have contr=
ol of
some daemons that are running on the machine, but I don't really have
control of the entirety of userspace, some of it I have source code for
and could audit to guarantee correctness (but I can't really enforce
that on the users, ultimately they can run any binary),
and for some of it I don't even have that.  Either way, it's much
easier to delegate setting policy to
userspace management daemon(s), and leave enforcing it to the kernel.
This is just one more such knob.

> But you didn't specify this, and we just have to guess. =C2=A0Why don=
't you
> describe the specific situation where you want to modify this setting=
?

> Please do this instead of just talking about what the side effects ar=
e
> inside of the kernel. =C2=A0That's much less interesting when it come=
s to
> patches like this.

Very well, that's a good point.

Here's an attempt to provide some insight.

I am attempting to allow not-fully-code-audited nor fully trusted apps =
to run
in a cgroup containerized environment, with many apps in many
containers (not 1:1, has hierarchies) on a single kernel.
The apps are in the believed to not be actively malicious class, but
very likely to be buggy, or written by ill-advised programmers based
on wrong/outdated or otherwise incorrect documentation.  I cannot rely
on unprivileged userspace getting things right.
I have to have some mechanism to grant these apps permissions to
utilize specific levels of network fabric priority.  For this I have
the aforementioned per-cgroup allowed TOS settings.  VLANs are not appr=
opriate
because a client with high priority net privs is allowed to send a
request to a server with no special priority permissions.
(there are further patches to support tcp tos reflection so the server
can automatically respond with the client's priority)

Multiqueue networking combined with hardware priority queues and xps
desires to use skb->priority + active cpu for tx queue selection.
In this particular case TX queue selection should happen based on the
TOS priority.
Setting TOS automatically sets sk_priority (and hence skb->priority).
So all's good, so long as userspace doesn't go and change the
sk_priority field via SO_PRIORITY and break the mapping.

As a further note:

Some of these apps may be a little more special, a little more
audited, and a little more trusted.
Enough so that they might be granted CAP_NET_RAW, but not enough so
that they can get CAP_NET_ADMIN.
Hence the general desire for CAP_NET_ADMIN to control general
machine-global networking state, but not have it control
per-socket or per-packet settings.  ie. bringing up or down an
interface affects everyone (hence must be CAP_NET_ADMIN, and much more
tightly controlled), while spoofing a packet doesn't really negatively
affect anyone (you can't assume the network is trusted, so there can
be
external sources of spoofing or eavesdropping anyway).

---

I could attempt to publish the vast majority of our internal
networking code base (there isn't really anything secret in there),
but it's based on 2.6.34 and even after two years of attempting to
clean it up and refactor it (along with a rebase from 2.6.26, and all
while actively continuing development) I'm still not at the point were
I would consider this to be a particular useful course of action
(there's a lot of bugfixes of bugfixes of crappy patches in there,
plus hacks, plus tons of backports from upstream, and tons of code
which is upstream but slightly differently then we have it internally,
because we had it first, and pushed v2 upstream, etc...).  Instead I'm
trying to get the easy hanging fruit out of the way, rebase our
patches onto probably 3.2 or 3.3, likely sending some more your way
during the process, and see where that leaves us.  Basically trying to
reduce the delta.  We will always have internal only patches, but the
fewer, the less burden for us, hence I'm trying to get the ones I
believe to be potentially useful externally upstreamed.  Obviously
whatever patches you don't accept, we'll still keep around locally.

Maciej
