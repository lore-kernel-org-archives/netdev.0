From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Sat, 1 Feb 2014 15:54:42 +0800
Message-ID: <CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>
References: <20140130211816.GB3787@xanatos>
	<87iot1qgv6.fsf@nemi.mork.no>
	<20140130221511.GD14228@xanatos>
	<CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
	<20140131190035.GB18262@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	David Laight <David.Laight@aculab.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:58570 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbaBAHyp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Feb 2014 02:54:45 -0500
In-Reply-To: <20140131190035.GB18262@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 1, 2014 at 3:00 AM, Sarah Sharp
<sarah.a.sharp@linux.intel.com> wrote:
> On Fri, Jan 31, 2014 at 08:17:58AM +0800, Ming Lei wrote:
>> On Fri, Jan 31, 2014 at 6:15 AM, Sarah Sharp
>> <sarah.a.sharp@linux.intel.com> wrote:
>> > On Thu, Jan 30, 2014 at 10:50:21PM +0100, Bj=F8rn Mork wrote:
>> >> FWIW, the plan looks fine to me.  Just adding a couple of hints t=
o
>> >> simplify the implementation.
>> >>
>> >> Sarah Sharp <sarah.a.sharp@linux.intel.com> writes:
>> >>
>> >> > Let's do this fix the right way, instead of wall papering over =
the
>> >> > issue.  Here's what we should do:
>> >> >
>> >> > 1. Disable scatter-gather for the ax88179_178a driver when it's=
 under an
>> >> >    xHCI host.
>> >>
>> >> No need to make this conditional.  SG is only enabled in the
>> >> ax88179_178a driver if udev->bus->no_sg_constraint is true, so it
>> >> applies only to xHCI hosts in the first place.
>> >
>> > Ah, so you're suggesting just reverting commit
>> > 3804fad45411b48233b48003e33a78f290d227c8 "USBNET: ax88179_178a: en=
able
>> > tso if usb host supports sg dma"?
>>
>> If I understand the problem correctly, the current issue is that xhc=
i driver
>> doesn't support the arbitrary dma length not well, but per XHCI spec=
, it
>> should be supported, right?
>>
>> If the above is correct, reverting the commit isn't correct since th=
ere isn't
>> any issue about the commit, so I suggest to disable the flag in xhci
>> for the buggy devices, and it may be enabled again if the problem is=
 fixed.
>
> Ok, I like that plan, since it means I don't have to touch any
> networking code to fix this. :)
>
> I believe that means we'll have to disable the flag for all 1.0 xHCI
> hosts, since those are the ones that need TD fragments.
>
>> >> > 2. Revert the following commits:
>> >> >    f2d9b991c549 xhci: Set scatter-gather limit to avoid failed =
block writes.
>> >> >    d6c9ea9069af xhci: Avoid infinite loop when sg urb requires =
too many trbs
>> >> >    35773dac5f86 usb: xhci: Link TRB must not occur within a USB=
 payload burst
>> >> >
>> >> > 3. Dan and Mathias can work together to come up with an overall=
 plan to
>> >> >    change the xHCI driver architecture to be fully compliant wi=
th the TD
>> >> >    fragment rules.  That can be done over the next few kernel r=
eleases.
>> >> >
>> >> > The end result is that we don't destabilize storage or break us=
erspace
>> >> > USB drivers, we don't break people's xHCI host controllers,
>> >> > the ax88179_178a USB ethernet devices still work under xHCI (a =
bit with
>> >> > worse performance), and other USB ethernet devices still get th=
e
>> >> > performance improvement introduced in 3.12.
>> >>
>> >> No other usbnet drivers has enabled SG...  Which is why you have =
only
>> >> seen this problem with the ax88179_178a devices.  So there is no
>> >> performance improvement to keep.
>>
>> In my test environment, the patch does improve both throughput and
>> cpu utilization, if you search the previous email for the patch, you=
 can
>> see the data.

With SG enabled, for the iperf client test case, the average urb size
for transmission will be increased from ~1500 to ~20K bytes in my
test case:

   iperf -c $SRV -t 30 -P 4 -w 128K

So I am wondering you guys do not care the improvement, maybe
the CPU is powerful enough to not degrade throughout&cpu
utilization not much, but there is still the potential CPU wakeup issue=
,
which means extra CPU power consumption might be introduced
after disabling SG for usbnet.

>
> Right, I did see the performance improvement note in that commit.  Do
> you know if the ARM A15 dual core board was using a 0.96 xHCI host, o=
r a
> 1.0 host?  You can find out by reloading the xHCI driver with dynamic
> debugging turned on:
>
> # sudo modprobe xhci_hcd dyndbg

Looks I can't find the parameter 'dyndbg' for xhci_hcd.

> and then look for lines like:
>
> [25296.765767] xhci_hcd 0000:00:14.0: HCIVERSION: 0x100

I change xhci_dbg.c manually with below:

diff --git a/drivers/usb/host/xhci-dbg.c b/drivers/usb/host/xhci-dbg.c
index b016d38..1ae1966 100644
--- a/drivers/usb/host/xhci-dbg.c
+++ b/drivers/usb/host/xhci-dbg.c
@@ -66,7 +66,7 @@ static void xhci_print_cap_regs(struct xhci_hcd *xhci=
)
                        (unsigned int) temp);
        xhci_dbg(xhci, "CAPLENGTH: 0x%x\n",
                        (unsigned int) HC_LENGTH(temp));
-       xhci_dbg(xhci, "HCIVERSION: 0x%x\n",
+       dev_info(xhci_to_hcd(xhci)->self.controller, "HCIVERSION: 0x%x\=
n",
                        (unsigned int) HC_VERSION(temp));

and got the below output:

[tom@ming ~]$ dmesg | grep HCIVERSION
xhci-hcd xhci-hcd.2.auto: HCIVERSION: 0x100

Thanks,
--
Ming Lei
