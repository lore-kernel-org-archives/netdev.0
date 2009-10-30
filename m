From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net interfaces
Date: Fri, 30 Oct 2009 12:10:03 -0500
Message-ID: <20091030171003.GA7523@auslistsprd01.us.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com> <20091029131125.GA13809@auslistsprd01.us.dell.com> <20091029142554.GA16869@kroah.com> <20091029174600.GC3612@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589682@blrx3m08.blr.amer.dell.com> <20091030160845.GA4547@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, greg@kroah.com, kay.sievers@vrfy.org,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com,
	bhutchings@solarflare.com
To: dann frazier <dannf@dannf.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091030160845.GA4547@lackof.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2009 at 10:08:45AM -0600, dann frazier wrote:
> On Fri, Oct 30, 2009 at 08:43:44PM +0530, Narendra_K@Dell.com wrote:
> >  
> > >> This way the kernel has only one name, and so does userspace, and 
> > >> everyone is happy.
> > >
> > >There are two issues, which really seem distinct to me.
> > >
> > >Users expect eth0 to map to first-onboard-nic. That's an 
> > >installer issue (since the BIOS can already export this info) 
> > >and I agree that if we want to "fix" that, we should fix it there.
> > >
> > 
> > I agree that installers have to be fixed in the sense that they can be
> > told to find the right interface. But, they expect determinism and
> > depend on "eth0 to map to first-onboard-nic". Installer is one of the
> > applications that is affected by this and needs user intervention, if it
> > is not told about the right interface. I discussed installer as it is so
> > much part of a user experience.
> 
> Right, but couldn't the installer do the work of scanning the SMBIOS
> to figure out which nics are onboard, and reorder the 'eth*' names
> such that these are first? This state could then be written out as
> udev rules so that they persist across reboots.

No, there is a catch-22.  To be sure you know the "proper" ethN name
to assign a device based on an ordering, you have to know about all
the devices.  When udev runs, one device at a time, it can only see
the current device and all those that have come before it, but it can't know
when all the drivers for all the NICs have been loaded.  And if you
hotplug a device in later, it should presumably just go at the end of
the list, but after a reboot, it'll most likely show up somewhere in
the middle of the list.  SMBIOS is static from boottime, not hotplug
aware. If I add a 4-port NIC in slot 3 after boot, it becomes
ethN..N+3.  After reboot, it may well show up at completely different
places, and even the N..N+3 ordering of individiual ports on the card
aren't guaranteed to be consistent.

ethN is fundamentally a nondeterministic namespace, and trying to
enforce determinism on it is, from all my attempts, impossible.  Hence
the desire to change the namespace.  But there can be many
different naming policies one might want (including the
nondeterministic ethN policy), and for all other types of devices this
isn't a problem - we can have all the policies we want, in parallel.
Only for network devices we can't.

Stephen, I hadn't seen the ifalias field you added.  I can see that
being helpful to a user (some tool can write a more meaningful string
to it), but I can't see it being useful programmatically.  It still
doesn't get me to "ifconfig the NIC in slot 3 port 2" or "ifconfig the
NIC I booted from".

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
