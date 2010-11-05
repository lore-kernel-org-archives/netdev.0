From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to start_udev
Date: Thu, 4 Nov 2010 21:58:48 -0500
Message-ID: <20101105025848.GA14021@pws490.domsch.com>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>
 <20101103180500.GA7441@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "K, Narendra" <Narendra_K@Dell.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101103180500.GA7441@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 03, 2010 at 11:05:00AM -0700, Greg KH wrote:
> On Wed, Nov 03, 2010 at 10:25:25PM +0530, Narendra_K@Dell.com wrote:
> > Hello,
> > 
> > This patch allows users to specify if they want the onboard network
> > interfaces to be renamed to lomN by implementing a command line param
> > 'udevlom'.
> 
> Ick ick ick.
> 
> Why not do this in some other configuration file?  Don't rely on udev
> being started with a different option, that is only ripe for abuse by
> everyone else who wants their pet-project to get into the udev
> environment.
> 
> Please, surely there's a different way to do this.

At Linux Plumbers Conference today, this problem space was discussed
once again, and I believe concensus on approach was reached.  Here
goes:

* If a 70-persistent-net.rules file sets a name, honor that.  This
  preserves existing installs.

* If BIOS provides indexes for onboard devices, honor that.
** Rename onboard NICs "lom[1-N]" as BIOS reports (# matches chassis labels)
** No rename for all others "ethX" (no change for NICs in PCI slots/USB/others)

* If neither are true, do not rename at all.

* Implementation will be:
** Udev rules to be included in upstream udev will read the index
   value from sysfs (provided by SMBIOS 2.6 info on kernels >= 2.6.36,
   PCI DSM info at some future point) if present, and rename LOMs
   based on that index value.  Distros will use these rules by default
   (Ubuntu and Fedora maintainers on board with the concept; I have
   not spoken with other distros yet.)
** Legacy distros with older udev rules will invoke biosdevname on
   kernels < 2.6.36 to get the same information, if present, and will
   rename LOMs based on index value.

** Installers will use the above udev rules by default.  If there is
   outcry during the distros beta testing periods, a way to disable
   these renames may be implemented.

* NetworkManager to display BIOS-provided labels as informational text


As such, biosdevname will be packaged and included in Debian and
Ubuntu (thanks to Colin Watson) to facilitate use in the udev rules.
Colin also suggested that any string used in Fedora kickstart files to
enable/disable this feature will also be used to enable/disable this
feature in the Debian & Ubuntu installers.  Given today's discussion
that the feature be enabled by default, this flag, if needed at all,
will be to disable the feature.

Does this seem sane to everyone?  Next step is to integrate
biosdevname into udev rules in a sane manner.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
