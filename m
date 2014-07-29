From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probe
 from init
Date: Mon, 28 Jul 2014 18:13:43 -0700
Message-ID: <CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
 <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com>
 <20140728185538.GB17609@kroah.com> <CAB=NE6VebcR7=UA1n0wNVLr5FFukzq6aW5CkeB3nf5FixV=3cA@mail.gmail.com>
 <CAB=NE6Xmi2zUCis22q+X8_AKRcwMrAtmx-aqSSvTB70Xjet6VQ@mail.gmail.com>
 <20140728234644.GA18729@kroah.com> <CAB=NE6UzK1ZEzm+54dwSyPwHGrAWCPtiNtxwhQuJF6tM9NbnYw@mail.gmail.com>
 <20140729003501.GA17020@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Santosh Rastapur <santosh@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Takashi Iwai <tiwai@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	MPT-FusionLinux.pdl@avagotech.com,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140729003501.GA17020@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 5:35 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Mon, Jul 28, 2014 at 05:26:34PM -0700, Luis R. Rodriguez wrote:
>> On Mon, Jul 28, 2014 at 4:46 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
>> > On Mon, Jul 28, 2014 at 12:48:32PM -0700, Luis R. Rodriguez wrote:
>> >> On Mon, Jul 28, 2014 at 12:04 PM, Luis R. Rodriguez
>> >> <mcgrof@do-not-panic.com> wrote:
>> >> > On Mon, Jul 28, 2014 at 11:55 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
>> >> >> So, what drivers are having problems in their init sequence, and why
>> >> >> aren't they using async firmware loading?
>> >> >
>> >> > Fixing drivers is one thing, fixing drivers *now* because *now*
>> >> > drivers are failing due to a regression is another thing and that's
>> >> > what we have now so lets just be clear on that. The 30 second rule is
>> >> > a major driver requirement change and it should not be taken slightly,
>> >> > all of a sudden this is a new requirement but you won't know that
>> >> > unless you're reading these threads or hit an issue. That's an issue
>> >> > in itself.
>> >
>> > That "regression" is something that userspace has decided to do, not
>> > anything the kernel changed,
>>
>> Actually commit 786235ee seems to have been the one that caused this
>> issue, systemd would just send the SIGKILL and that change forced a
>> bail on probe then hence Canonical's work around to modify
>> kthread_create() to not leave upon SIGKILL:
>>
>> http://thread.gmane.org/gmane.linux.ubuntu.devel.kernel.general/39123
>>
>> > so perhaps you should just patch your
>> > modprobe and be done with it until you can fix up those drivers?
>>
>> To ignore SIGKILL ?
>
> Sorry, I thought this was a userspace change that caused this.
>
> As it's a kernel change, well, maybe that patch should be reverted...

That's certainly viable. Oleg?

If its reverted we won't know which drivers are hitting over the new
30 second limit requirement imposed by userspace, which the culprit
commit forces failure on probe now. This series at least would allow
us to annotate which drivers are brake the 30 second init limit, and
enable a work around alternative if we wish to not revert the commit.
This  series essentially should be considered an alternative solution
to what was proposed initially by Joseph Salisbury, it may not be
perfect but its a proposal. I welcome others.

>> > And putting a horrid hack in the driver core, just because of some
>> > really bad drivers, is not ok, that's an interface _I_ will have to
>> > support for the next few decades.
>>
>> I understand, hence review.
>>
>> > And it's going to take you a while to get something like this ever
>> > merged in anyway, odds are you can fix up the driver faster...
>>
>> That requires quite a bit of changes and commitment and again, there
>> are quite a bit of drivers that we can run into in the community,
>> we've just spotted 2 so far here for now.
>>
>> >> > The cxgb4: driver is an example where although I did propose patches
>> >> > to use asynch firmware loading the entire registration of the
>> >> > netdevice would need to be changed as well in order to get this right.
>> >> > In short we have to scramble now to first identify drivers that have
>> >> > long init sequences and then fix. There's an assumption that we can
>> >> > easily fix drivers, this can take time. This series, although does
>> >> > take advantage of a kernel interface for other uses, lets us identify
>> >> > these drivers on the kernel ring buffer, so we can go and address
>> >> > fixing them with time.
>> >>
>> >> Another thing that came up during asynch firmware review / integration
>> >> on cxgb4 was that it would not be the only thing that would need to be
>> >> fixed, the driver also has a ton of ports and at least as per my
>> >> review the proper fix would be to use platform regiister stuff. It is
>> >> a major rewrite of the driver but an example of a driver that needs
>> >> quite a bit of work to meet this new 30 second driver requirement.
>> >
>> > It shouldn't be using any platform driver stuff, it's a pci device, not
>> > a platform device.
>>
>> The general PCI stuff is already used, the reason for suggesting the
>> platform_device_register_simple() stuff is it has tons of ports and
>> each port will register in turn a new struct netdevice, essentially
>> one device can end up having tons of different network devices, the
>> platform stuff would be to allow handling each netdevice candidate
>> separately as part of the internal driver architecture, right now its
>> some scary loop thing that in my eyes can be very error prone.
>> drivers/net/ethernet/8390/ne.c. This discussion:
>
> No, don't use platform devices as a "catch-all" for when you don't want
> to write your own bus code.  This looks like a device-specific bus,
> great, write the code to do that, it can be done in about 200 lines,
> with comments and whitespace.
>
> Only use platform devices for, wait for it, platform devices.  And even
> then, reconsider and use something else if at all possible.

OK thanks I had asked for advice for this a while back on that old
thread as I wasn't sure if that was the best.

>> > Why not just put the initial "register the device" in a single-shot
>> > workqueue or thread or something like that so that modprobe returns
>> > instantly back with a success and all is fine?
>>
>> That surely is possible but why not a general solution for such kludges?
>
> Because the driver should be fixed.  How hard would it be to do what I
> just suggested here, 20 lines added at most?

I appreciate the feedback, but don't look at me, I'd happy to go nutty
on ripping things apart from hairy drivers, however Chelsie folks
expressed concerns over major rework on the driver... so even if we
did have something I expect things to take a while to bake / gain
confidence from others.

This also just addresses this *one* Ethernet driver, there was that
SCSI driver that created the original report -- Canonical merged
Joseph's fix as a work around, there is no general solution for this
yet, and again with that work around you won't find which drivers run
into this issue. There may be others found later so this is why I
resorted to the deferred workqueue as a solution for now and to enable
us to annotate which drivers need fixing as I expect getting the fix
done / everyone happy can take time.

 Luis
