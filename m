From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [git pull] VFS patches, the first series
Date: Sat, 23 Aug 2008 04:33:28 +0100
Message-ID: <20080823033328.GH28946@ZenIV.linux.org.uk>
References: <20080727012212.GW28946@ZenIV.linux.org.uk> <m1d4k2zui4.fsf@frodo.ebiederm.org> <m1od3mthma.fsf@frodo.ebiederm.org> <m1iqttnc7a.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41683 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbYHWDde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 23:33:34 -0400
Content-Disposition: inline
In-Reply-To: <m1iqttnc7a.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 05:08:25PM -0700, Eric W. Biederman wrote:

> I'm not certain what to do about it.  The semantics of the how the
> sysctl tables are access have changed significantly.  Now the first 
> sysctl table to describe a directory must remain until there are no
> other tables that have entries in that directory and a sysctl table
> must have a pure path of directories for any portion of the address
> space it shares with an earlier sysctl table.  This is noticeably
> different from the union mount semantics we have had previously for
> the sysctl tables.

Note that the old semantics had a lovely inherent problem (leaving aside
the utterly insane amount of walking and re-walking the trees, as you've
found out the hard way - don't tell me you hadn't cursed it when writing
the previous version of proc_sysctl.c): there's redundancy between the
trees.  At the very least, just what are we supposed to get when the
stems do not match each other - either in permissions or in ctl_name?

> If it doesn't look to bad to maintain the new semantics it looks like
> the right thing to do is to add some additional checks so we get more
> precise warnings (who knows what out of tree sysctl code will do) and
> to find someplace I can insert a net/ipv4/neigh sysctl directory into
> (ipv4_net_table looks like it will work) to keep the network namespace
> code working safely.
> 
> Al btw nice trick using compare to keep the dentries separate allowing
> us to cache everything in /proc.  I feel silly for missing that one.
> Want to get together in the next couple of weeks and build a tree that
> updates the sysctls infrastructure to suck less?

Fine by me...  BTW, fixing that particular crap is not hard - you need
to have the entry in question show up before either interface, that's all.
I missed that part of ordering mess, to be honest.  I'll look into that,
hopefully will post the fix later tonight.

FWIW, I'd very much prefer ->d_compare() trick to the horrors you guys
are doing around sysfs; it might or might not be feasible depending on
what visibility rules you end up with there, but if it's feasible at all
I'd rather go for it and avoid the entire 'separate backing store' mess.
IIRC, I had described that scheme to you quite a few months ago in sysfs
context; got no response back then...
