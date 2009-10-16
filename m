From: dann frazier <dannf@hp.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 16 Oct 2009 09:20:54 -0600
Message-ID: <20091016152053.GA9862@ldl.fc.hp.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
 <20091013150839.GD32107@ldl.fc.hp.com>
 <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com>
 <20091013173638.GE1119@ldl.fc.hp.com>
 <20091016003245.GD29672@ldl.fc.hp.com>
 <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Matt_Domsch@Dell.com, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:30467 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759454AbZJPPVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 11:21:31 -0400
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2009 at 07:32:50PM +0530, Narendra_K@Dell.com wrote:
> 
> >On Tue, Oct 13, 2009 at 11:36:38AM -0600, dann frazier wrote:
> >> Right - so any reason this couldn't be implemented completely in 
> >> userspace by having udev manipulate plain text files under say 
> >> /etc/udev/net/?
> >> 
> >> I do agree that it would be nice for admins/installers to tweak/use 
> >> nic names in a similar way to storage names (udev rules), 
> >and it might 
> >> let us take advantage of a lot of the existing udev code.
> >
> >Is there interest in this approach?
> > - modify udev to manage network devices names as regular (non-device)
> >   files (stored in /etc/udev, /dev/netdev, or wherever)
> 
> Yes. Would you elaborate little more on "modify udev to manage network
> devices as regular files".

Sure. We already get an event when netifs get added/removed - udev
just doesn't create a device file for it. And since all we care about
is the file's name (and the symlinks to it), there's really no point
in creating a real device file anyway.

So, instead of 'mknod /dev/netdev/eth0', why not just 'touch
/dev/netdev/eth0'? A file exists, so we can still maintain
aliases as symlinks, we just don't need to modify the kernel.

> Does it mean some custom rules which will
> generate a regular file under, say, /dev/netdev/ or extend udev
> itself ?

I believe we have to extend udev itself. We could probably do this
completely within udev rules by running programs that do the touching
and symlinking, but it would be nicer and more consistent/familiar to
take advantage of the udev syntax (SYMLINK) to do this
natively. Besides, udev already has the logic to know when/how to
instantiate and unlink symlinks, it would suck to duplicate that.

So, udev would need to be modified to know how to go through the
normal "node" creation for net devices, and to call creat() instead of
mknod().

> And how would the regular file look like in terms of holding ifindex of
> the interface, which can be passed to libnetdevname.

I can't think of anything we need to store in the regular file. If we
have the kernel name for the device, we can look up the ifindex in
/sys. Correct me if I'm wrong, but storing it ourselves seems
redundant.

> 
> 
> > - use the existing udev rules to manage symlinks to these files
> > - point libnetdevname at these text files for its name resolution
> >
> >I've started prototyping this, and it certainly looks possible 
> >w/o any kernel changes. However, I could probably use some 
> >advice from a udev person to do a proper implementation.
> 
> With regards,
> Narendra K  

-- 
dann frazier

