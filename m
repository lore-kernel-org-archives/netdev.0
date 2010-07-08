From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 16257] New: sysfs changes break hwsim and bnep drivers
Date: Thu, 08 Jul 2010 09:55:55 -0700
Message-ID: <m1wrt56hgk.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54756 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab0GHQ4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:56:04 -0400
In-Reply-To: <20100622035631.GA3755@suse.de> (Greg KH's message of "Mon\, 21 Jun 2010 20\:56\:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@suse.de> writes:

> Does this only show up if you enable network namespaces?  Or is it a
> problem with the "normal" kernel configuration of no network namespaces?

It is a problem with the normal kernel configuration.  In that case
we have a single network namespace.  

> The only thing that changed here was your network namespace work, what
> caused this problem to show up?  Was it bisectable down to a single
> patch?

The problem is that when we remove symlinks we look at the target of
the symlink to see which tag to remove it in it's parent directory.
Because the target of the symlink was not in a class directory because
of that crazy class on class stacking exception in get_device_parent
we fail to find the symlink when we attempt to remove it.

My one line patch to get_device_parent really does fix this.  I have
just sent you a patch to prevent the creation of these crazy symlinks
in sysfs, which at least clearly isolates this to a handful of drivers.

> Classes on top of classes should never have originally worked, I guess
> we just let them slide by accident, and we can go and fix them up as
> they are found.  But for now, for .35, it would be good to find the root
> cause of the problem here.  It might be as simple as putting a
> CONFIG_BROKEN on network namespaces until we get this working, right?

Nope, it isn't as simple as disabling network namespaces.

For the mac80211_hwsim we can just remove the device parent, and all will
be well for the moment.

For the bnep code we could also not set the parent but I don't know if
that would have undesirable complications for power management or not.
I don't have a bluetooth attached network device so I don't even know how
to test that code.

My preferred fix is the one liner I set you to get_device_parent.  It
is no worse than the magic device_is_not_partition checks then we
already have in sysfs.  Especially when it is a bug that
get_device_parent does that early return in the first place.  To fix
this we will have to introduce the missing subdirectory one way or
another.

With SYSFS_DEPRECATED enabled I don't believe this problem can actually
happen, as all network devices are placed immediately under
/sys/class/net/ in sysfs.

Eric
