From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred
	probefrom init
Date: Wed, 30 Jul 2014 02:14:34 +0200
Message-ID: <20140730001434.GS21930@wotan.suse.de>
References: <20140728234644.GA18729@kroah.com> <CAB=NE6UzK1ZEzm+54dwSyPwHGrAWCPtiNtxwhQuJF6tM9NbnYw@mail.gmail.com> <20140729003501.GA17020@kroah.com> <CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com> <53D744E3.10500@suse.de> <201407292107.EGB64066.OOQMFSHLJVtFFO@I-love.SAKURA.ne.jp> <20140729222529.GC21140@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hare@suse.de,
	gregkh@linuxfoundation.org, santosh@chelsio.com,
	hariprasad@chelsio.com, tiwai@suse.de,
	linux-kernel@vger.kernel.org, joseph.salisbury@canonical.com,
	kay@vrfy.org, gnomes@lxorguk.ukuu.org.uk,
	tim.gardner@canonical.com, pierre-fersing@pierref.org,
	akpm@linux-foundation.org, oleg@redhat.com,
	nagalakshmi.nandigama@avagotech.com,
	praveen.krishnamoorthy@avagotech.com,
	sreekanth.reddy@avagotech.com, abhijit.mahajan@avagotech.com,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140729222529.GC21140@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 29, 2014 at 03:25:29PM -0700, Benjamin Poirier wrote:
> On 2014/07/29 21:07, Tetsuo Handa wrote:
> > Luis R. Rodriguez wrote:
> > > On Mon, Jul 28, 2014 at 5:35 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > > > On Mon, Jul 28, 2014 at 05:26:34PM -0700, Luis R. Rodriguez wrote:
> > > >> To ignore SIGKILL ?
> > > >
> > > > Sorry, I thought this was a userspace change that caused this.
> > > >
> > > > As it's a kernel change, well, maybe that patch should be reverted...
> > > 
> > > That's certainly viable. Oleg?
> > 
> > I don't want to revert that patch.
> 
> I agree that 786235ee should not be reverted to fix the problem of
> modules that receive sigkill from udev while they are initializing. In
> fact, while it may fix the case that was reported with mptsas, it would
> not fix cxgb4 because there are other code paths that check for pending
> signals and that abort (ex. pci_vpd_pci22_wait()).
> 
> Reverting 786235ee effectively works around the problem by making
> modprobe unkillable. The proper solution would be to make sure that udev
> does not send sigkill to modprobe in the first place, either by making
> the timeout longer or by making the module probe faster.

Hannes sent a patch for systemd that enables a kernel command line override
for the timeout, this however still means some drivers can fail and distros
would have to use the longest known timeout for the supported kernel.

http://lists.freedesktop.org/archives/systemd-devel/2014-July/021601.html

Tetsuo is it possible / desirable to allow tasks to not kill unless the
reason is OOM ? Its unclear if this was discussed before, sorry if it was,
have just been a bit busy today to review the archive / discussions on this.

To *fatally* kill a module if it does not reach a time limit is rather harsh
without properly thinking about the entire picture of possible issues and 
reasons for the timeout and also consequences of the kill, essentially
what has happened is we are breaking ome boots on at least storage drivers
that take long, and now networking on one driver at least. I think we all
agree these drivers need fixing, there is no one arguing over that.
but to allow a timeout to fatally kill the damn system seems rather
stupid too if what we want to do is to get drivers fixed. It is both *hard
to debug* (see the bug reports) and simply just irritating to users.

The original commit on systemd that introduced the timeout is commit
e64fae55 but the purpose of that commit was to send to hell drivers
that are not using asynch firmware loading, but this is not the only
reason why some drivers would hit the timeout limit. As Benjamin notes
the cxgb4 driver issue is a bit more complex than that, as I've noted
I've sent some initial patches to help with asynch firmware but proper
integration is a bit more complex and even if we remove firmware out
of the picture (this was tried) the driver *still* takes more than
30 seconds to load and fails as Benjamin indicated. As Greg notes a bus
driver stub can be written -- but this will take a bit of time folks,
even if its a day or two, or a week or to just test things. In the
meantime we simply have broken systems / networking as collateral to
a CVE patch that in turn allowed systemd to also kill drivers on a
30 second timeout under the assumption it was all asynch firmware
loading. Collateral should not be the way to introduce new driver
requirements, specially if its breaking boots. All I'm saying is we
should just try to warn here, and not be fatal.

Hannes' patch will allow us to override the timeout through the comand
line but we're essentially still killing drivers that don't meet the new
implicit rules. This doesn't seem optimal and hence the discussion.

  Luis
