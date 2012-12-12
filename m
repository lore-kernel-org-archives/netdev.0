From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Wed, 12 Dec 2012 11:25:24 -0800
Message-ID: <87fw3boyxn.fsf@xmission.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53586 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab2LLTZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 14:25:36 -0500
In-Reply-To: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
	(Nicolas Dichtel's message of "Wed, 12 Dec 2012 18:17:05 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> The goal of this serie is to ease netns management by daemons. Some systems use
> netns only to virtualize network stack and don't want to multiply userland
> daemons.  These system may have a lot of netns, up to 2000. We don't want to
> launch an instance of each daemons (quagga, strongswan, conntrackd, ...) for
> each netns because it will consume a lot of ressources. Having one daemon that
> manage all netns is more efficient (mainly if there are few objects to manage:
> one or two routes per netns for example).
> Hence, one goal of this serie is to allow, for a daemon, to monitor netns
> activities, thus it can open or close netlink sockets, allocating structures
> needed to manage these netns when they are created or deleted.
> To help to identify a netns, an index has been added to each netns.
>
> A new setsockopt() option is also added, to help daemons to open socket in the
> right netns. For now, a daemon that want to open a socket in a specified netns,
> need to call setns(CLONE_NEWNET) with a fd (not so easy to found), open the
> socket and then call again setns() to go back in the initial netns. Having this
> kind of setsockopt() will simplify operations. Obviously, this setsockopt()
> should be done enough early (is test on sk_state enough?). The first target is
> netlink socket but it can be useful for other kind of socket, it's why a add a
> generic socket option.
>
> As usual, the patch against iproute2 will be sent once the patches are included
> and net-next merged. I can send it on demand.

Short answer you don't need to do any of this.

setns with the namespace files in /proc/<pid>/ns/net gives you more than
enough mechanism to solve this problem.  And iprout2 already supports
all of this.

And your approach creates very serious maintenances problems to the
point I don't even want to read your patches.  What namespace do your
namespace id's live in?

A socketopt to change the namespace of a socket is nasty because sockets
changing which network namespace they are in, leads to races which
aren't worth thinking about writing the code to handle.

Longer answer.

You can bind mount the namespace id's /proc/<pid>/ns/net files to
give you any name you want.  This puts naming policy in userspace
control, and nests just fine.

You can open a socket in any network namespace you want just
by calling setns before socket.  Wrapping this idiom in a library call
or if there is sufficient need in a socketat system call seems
reasonable.

There is a classic question of if two network namespace files refer to
the same network namespace and I have code in linux-next and my pull
request to Linus to give those files a unique inode number.

So please use the facilities already merged into the kernel.

Thank you,
Eric
