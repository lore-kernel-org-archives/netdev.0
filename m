From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Fri, 31 Jan 2014 08:17:58 +0800
Message-ID: <CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
References: <20140130211816.GB3787@xanatos>
	<87iot1qgv6.fsf@nemi.mork.no>
	<20140130221511.GD14228@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Nyman, Mathias" <mathias.nyman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140130221511.GD14228@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 31, 2014 at 6:15 AM, Sarah Sharp
<sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> On Thu, Jan 30, 2014 at 10:50:21PM +0100, Bj=F8rn Mork wrote:
>> FWIW, the plan looks fine to me.  Just adding a couple of hints to
>> simplify the implementation.
>>
>> Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> writes:
>>
>> > Let's do this fix the right way, instead of wall papering over the
>> > issue.  Here's what we should do:
>> >
>> > 1. Disable scatter-gather for the ax88179_178a driver when it's un=
der an
>> >    xHCI host.
>>
>> No need to make this conditional.  SG is only enabled in the
>> ax88179_178a driver if udev->bus->no_sg_constraint is true, so it
>> applies only to xHCI hosts in the first place.
>
> Ah, so you're suggesting just reverting commit
> 3804fad45411b48233b48003e33a78f290d227c8 "USBNET: ax88179_178a: enabl=
e
> tso if usb host supports sg dma"?

If I understand the problem correctly, the current issue is that xhci d=
river
doesn't support the arbitrary dma length not well, but per XHCI spec, i=
t
should be supported, right?

If the above is correct, reverting the commit isn't correct since there=
 isn't
any issue about the commit, so I suggest to disable the flag in xhci
for the buggy devices, and it may be enabled again if the problem is fi=
xed.

>
>> > 2. Revert the following commits:
>> >    f2d9b991c549 xhci: Set scatter-gather limit to avoid failed blo=
ck writes.
>> >    d6c9ea9069af xhci: Avoid infinite loop when sg urb requires too=
 many trbs
>> >    35773dac5f86 usb: xhci: Link TRB must not occur within a USB pa=
yload burst
>> >
>> > 3. Dan and Mathias can work together to come up with an overall pl=
an to
>> >    change the xHCI driver architecture to be fully compliant with =
the TD
>> >    fragment rules.  That can be done over the next few kernel rele=
ases.
>> >
>> > The end result is that we don't destabilize storage or break users=
pace
>> > USB drivers, we don't break people's xHCI host controllers,
>> > the ax88179_178a USB ethernet devices still work under xHCI (a bit=
 with
>> > worse performance), and other USB ethernet devices still get the
>> > performance improvement introduced in 3.12.
>>
>> No other usbnet drivers has enabled SG...  Which is why you have onl=
y
>> seen this problem with the ax88179_178a devices.  So there is no
>> performance improvement to keep.

In my test environment, the patch does improve both throughput and
cpu utilization, if you search the previous email for the patch, you ca=
n
see the data.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
