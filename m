From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Wed, 10 Aug 2016 08:47:41 -0700
Message-ID: <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
 <1452684335-46107-4-git-send-email-hare@suse.de> <20160209210458.GB32530@localhost>
 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru> <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
 <1470787409.3015.81.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	santosh@chelsio.com, Netdev <netdev@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470787409.3015.81.camel@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 9, 2016 at 5:03 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Tue, 2016-08-09 at 11:12 -0700, Alexander Duyck wrote:
>>
>> The PCI spec is what essentially assumes that there is only one block.
>> If I am not mistaken in the case of this device the second block here
>> actually contains device configuration data, not actual VPD data.  The
>> issue here is that the second block is being accessed as VPD when it
>> isn't.
>
> Devices do funny things with config space, film at 11. VFIO trying to
> be the middle man and intercept/interpret things is broken, cannot work,
> will never work, will just results in lots and lots of useless code, but
> I've been singing that song for too long and nobody seems to care...
>
>> > > #0000 Large item 42 bytes; name 0x2 Identifier String
>> > #002d Large item 74 bytes; name 0x10
>> > #007a Small item 1 bytes; name 0xf End Tag
>> > ---
>> > #0c00 Large item 16 bytes; name 0x2 Identifier String
>> > #0c13 Large item 234 bytes; name 0x10
>> > #0d00 Large item 252 bytes; name 0x11
>> > #0dff Small item 0 bytes; name 0xf End Tag
>>
>> The second block here is driver proprietary setup bits.
>
> Right. They happen to be in VPD on this device. They an be elsewhere on
> other devices. In between capabilities on some, in vendor caps on others...
>
>> > > The cxgb3 driver is reading the second bit starting from 0xc00 but since
>> > the size is wrongly detected as 0x7c, VFIO blocks access beyond it and the
>> > guest driver fails to probe.
>> >
>> > I also cannot find a clause in the PCI 3.0 spec saying that there must be
>> > just a single block, is it there?
>>
>> > The problem is we need to be able to parse it.
>
> We can parse the standard part for generic stuff like inventory tools
> or lsvpd, but we shouldn't get in the way of the driver poking at its
> device.

If we add the quirk to the kernel that reports the VPD for this device
is the actual size of both blocks then we wouldn't be blocking the VPD
access like we currently are.

The problem is if we don't do this it becomes possible for a guest to
essentially cripple a device on the host by just accessing VPD regions
that aren't actually viable on many devices.  We are much better off
in terms of security and stability if we restrict access to what
should be accessible.  In this case what has happened is that the
vendor threw in an extra out-of-spec block and just expected it to
work.  In order to work around it we just need to add a small function
to drivers/pci/quirks.c that would update the VPD size reported so
that it matches what the hardware is actually providing instead of
what we can determine based on the VPD layout.

Really working around something like this is not much different than
what we would have to do if the vendor had stuffed the data in some
reserved section of their PCI configuration space.  We end up needing
to add special quirks any time a vendor goes out-of-spec for some
one-off configuration interface that only they are ever going to use.

- Alex
