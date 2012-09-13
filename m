From: Sven Ulland <sveniu@opera.com>
Subject: Re: bnx2 cards intermittantly going offline
Date: Thu, 13 Sep 2012 17:45:46 +0200
Message-ID: <5051FFAA.8060501@opera.com>
References: <20120913135108.GC3650@abomination.net.united.domain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Marc A. Donges" <marc.donges@1und1.de>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opera.com ([213.236.208.81]:60010 "EHLO smtp.opera.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab2IMPzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 11:55:41 -0400
In-Reply-To: <20120913135108.GC3650@abomination.net.united.domain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2012 03:51 PM, Marc A. Donges wrote:
> After 55 days of operation the machine (A) suddenly was no longer
> reachable via network. Strangely, a second machine (B) that should
> take over the IP addresses (keepalived) did not take over. Only
> after shutting the switchport to which A is attached did B take
> over.

Hi. We've had the same symptom with our BCM5709S [14e4:163a] on
Debian. Like you, we were on stable's 2.6.32-41squeeze2. Google led us
to many similar issues [1,2,3]. They concluded with the fix being in
mainline commit c441b8d2 [4]: "bnx2: Fix lost MSI-X problem on 5709
NICs".

Broadcom: Can you publish a tool that decodes ethtool -d dumps to make
debugging easier, or do you deem it no longer necessary with the the
register dump commits in 555069da?

Now, Debian's 2.6.32-41squeeze2 is based on longterm release 2.6.32.54
[5]. That version includes commit 0b7817ed [6], which is a backport of
the already mentioned mainline commit c441b8d2.

So we tried digging further and applying some seemingly relevant
commits [7,8] to our 2.6.32, but without any change in behaviour. Our
temporary fix was to run 'ethtool -t ethX' to reset the device every
time it locked up.

This dragged on with various builds, until we ended up on mainline
2.6.38 where we no longer saw any symptoms. I don't know in which
kernel version it was fixed, but we ended up on that one, sort of by
chance. Unfortunately, it had severe issues with kswapd memory
compaction causing CPU soft lockups [9], so we went straight to
squeeze-backports' 3.2.23-1~bpo60+2. We've been happy since then.

> We have five pairs of basically identical machines performing the
> same task (each pair for one site). The error has not occured with
> any other one, but this site is the busiest:

We also saw the issue only at a site with generally higher load
compared to other sites.

I'd love to know exactly which commit fixed the issue, but it's fairly
tricky to reproduce the issue, and the bisect count is fairly high (it
need not be a specific fix for bnx2).

sven


[1]: bnx2 driver crashes under random circumstances
https://bugzilla.redhat.com/show_bug.cgi?id=520888

[2]: Access denied. Come on, Red Hat!
https://bugzilla.redhat.com/show_bug.cgi?id=511368

[3]: NIC doesn't register packets [rhel-5.5.z]
https://bugzilla.redhat.com/show_bug.cgi?id=587799

[4]: bnx2: Fix lost MSI-X problem on 5709 NICs.
http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=object;h=c441b8d2cb2194b05550a558d6d95d8944e56a84

[5]: Debian Changelog linux-2.6 (2.6.32-45)
http://packages.debian.org/changelogs/pool/main/l/linux-2.6/linux-2.6_2.6.32-45/changelog#version2.6.32-41

[6]: bnx2: Fix lost MSI-X problem on 5709 NICs.
http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=commit;h=0b7817edda5e44e5fa769645bd1220f5e7b0beb5

[7]: bnx2: reset_task is crashing the kernel. Fixing it.
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=4529819c45161e4a119134f56ef504e69420bc98

[8]: bnx2: fixing a timout error due not refreshing TX timers correctly
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e6bf95ffa8d6f8f4b7ee33ea01490d95b0bbeb6e

[9]: [PATCH] remove compaction from kswapd
http://thread.gmane.org/gmane.linux.kernel.mm/58962
https://lkml.org/lkml/2011/3/25/664
