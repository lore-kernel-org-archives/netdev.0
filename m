From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v3 2/3] cxgb4: use
	module_long_probe_init()
Date: Thu, 14 Aug 2014 21:53:22 +0200
Message-ID: <20140814195321.GO21930@wotan.suse.de>
References: <525DB349B3FB5444AE057A887CB2A8D85A0977@nice.asicdesigners.com>
 <53ECE709.5030008@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 "tiwai@suse.de" <tiwai@suse.de>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
 Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
 "MPT-FusionLinux.pdl@avagotech.com" <MPT-FusionLinux.pdl@avagotech.com>,
 Tim Gardner <tim.gardner@canonical.com>, Benjamin Poirier <bpoirier@suse.de>,
 Santosh Rastapur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>,
 Pierre Fersing <pierre-fersing@pierref.org>, Anish Bhatt <anish@chelsio.com>,
 Oleg Nesterov <oleg@redhat.com>,
 Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
 systemd-devel@lists.freedesktop.org,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux
To: Casey Leedom <leedom@chelsio.com>,
 Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay@vrfy.org>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <53ECE709.5030008@chelsio.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: systemd-devel-bounces@lists.freedesktop.org
Sender: "systemd-devel" <systemd-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2014 at 09:42:49AM -0700, Casey Leedom wrote:
>
> On 08/13/2014 04:33 PM, Anish Bhatt wrote:
>> Adding Casey who's actually incharge of this code and missing from the CC list
>
>   Thanks Anish!
>
>   As I mentioned to Anish, there are fundamentally two problems here in the 
> time being consumed by the cxgb4 PCI probe() function:
>
>  1. When various firmware files aren't present, request_firmware()
>     can take a very long time.  This is easily solved by using
>     request_firmware_direct() and I certainly have no objection to that.

I sent a patch for this a while ago, since there is no objection if
you'd like to apply the patch:

http://patchwork.ozlabs.org/patch/363756/

Apart from that you also want to use asynch firmware loading but
to use that properly (I also had sent some basic initial patches
for asynch firmware loading but without moving out other logic
yet) you want to also let driver initalization complete
asynchronously later.

>  2. When there are multiple adapters present in a system which
>     need firmware downloaded, each one individually may not take
>     a ton of time but together they can exceed simple Module Load
>     Timeouts.  There's not a simple answer here.

I had originally recommended to write your own platform driver for
this and have each port probe but Greg has provided the last advice
for this on the patch I sent to add deferred probe support from
init, his recommendation was for you to write your own bus code for
the driver:

http://www.spinics.net/lists/linux-scsi/msg76695.html

>   Part of the problem here is that it's a Module Load Timeout instead of a 
> per-device Probe Timeout.

Seems like you can fix this with a bus driver.

>   Part of the problem is that the current 
> architecture has Device Probe happening out of the Module Initialization 
> when we call pci_register_driver() with our PCI Device ID Table.
>
>   Running the Device Probes asynchronously has been discussed but that has 
> the problem that it's then impossible to return the Device Probe Status.  
> This is a problem for Driver Fallback and, if the probe fails, we're not 
> supposed to call the Device Remove function. To make this work, the 
> synchronous/asynchronous boundary would really need to be up in the PCI 
> Infrastructure layer so the Device Probe status could be captured in the 
> normal logic.  This would be a moderately large change there ...

Some maintainers consider most of the work to get what you need done
simple, I've tried to explain it ain't so, so glad you provided a bit
of details here. To be clear its not just about asynch firmware loading,
you need a bit more work. Can you evaluate using a bus driver?

>   Deferring the Device Initialization till the first "ifup" has also been 
> discussed and is certainly possible, though a moderately large 
> architectural change to every driver which needs it.  It also has the 
> unfortunate effect of introducing random large delays directly on user 
> commands.  From a User Experience perspective I would tend to want such 
> large delays in the Device Probe

You should just use asynch firmware loading there and only once your
driver is done loading firmware start exposing the device(s) as you
see fit with your bus driver.

>.  But that's something that really 
> deserves a real User Interaction study rather than throwing a dart.
>
>   On the whole, I think that introducing these Module Load Timeouts hasn't 
> been well thought out with respect to the repercussions and I'd be more 
> inclined to back that out till a well thought out design is developed.  But 
> I'm here for the discussion.

The way that the 30 second timeout was introduced as a new driver
initialization requirement was certainly not ideal specially since
the respective systemd patch that intended to trigger the SIGKILL on
kmod module loading only took effect once kernel commit 786235ee
went in about a year later, and since the original systemd commit
was only addressing asynchronous firmware loading as a possible
issue that drivers may need to fix. The cxgb4 driver is a good
example that needs quite a bit of more work. Regardless systemd
folks are right -- but again, having this be introduced as a new
requirement that otherwise simply kills drivers seems a bit too
aggressive specially if its killing boot on some systems due to
delays on storage drivers. What's done is done -- and we need to
move on. We already reviewed twice now reverting 786235ee and that
won't happen, as a compromise we're looking for an easy agreeable
general driver work around that would both circumvent the issue
and let us easily grep for broken drivers. The deferred probe trick
was the first approach and this series addresses the more agreeable
solution. This 2 line patch then is what we are looking as work
around until your driver gets properly fixed.

Apart from these kernel changes there are systemd changes we've
looked at modifying, Hannes' patch 9719859c07a, now merged upstream on
systemd lets you override the timeout value through the kernel command
line. This will only help for all systems if you use a high enough
large timeout value, or on a case by case basis for each system.
I recently proposed replacing a kill for a warn only for udev
kmod built in commands, that's unacceptable for systemd's architecture
though so the last thing I proposed instead to use *for now* is a
multiplier for each different type of udev built-in command and
for kmod we'd use a high enough value, the timeout therefore would
be really large for module loading for now, but we'd still want to
collect logs of drivers taking long to probe. That's still being
discussed [0] but my hope is that with this series and that other
systemd discussion we'll have covered both areas affected and have
a good strategy to move forward with this new driver requirement.

[0] http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/21689

  Luis
