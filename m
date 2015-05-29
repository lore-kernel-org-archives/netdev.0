From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: Request for advice on where to put Root Complex "fix up" code for
 downstream device
Date: Fri, 29 May 2015 11:55:31 -0500
Message-ID: <CAErSpo6XAANACecyCrn9XtyAy0-YNto1VK6zRNhLEpGqm2usrQ@mail.gmail.com>
References: <4985EFDD773FCB459EF7915D2A3621ADBC7408@nice.asicdesigners.com>
 <20150507230426.GO24643@google.com> <4985EFDD773FCB459EF7915D2A3621ADBC80D4@nice.asicdesigners.com>
 <20150529162021.GA12733@google.com> <4985EFDD773FCB459EF7915D2A3621ADBDF585@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:35540 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394AbbE2Qzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:55:53 -0400
Received: by qczw4 with SMTP id w4so3932432qcz.2
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 09:55:52 -0700 (PDT)
In-Reply-To: <4985EFDD773FCB459EF7915D2A3621ADBDF585@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 11:46 AM, Casey Leedom <leedom@chelsio.com> wrote:
>   Thanks Bjorn and no issues at all about the delay -- I definitely understand how
> busy we all are.
>
>   I'll go ahead and submit a PCI Quirk.  As part of this, would you like me to
> also commit a new PCI-E routine to find the Root Complex Port for a given
> PCI Device?  It seem like it might prove useful in the future.  Otherwise I'll
> just incorporate that loop in my PCI Quirk.

Sure, I wouldn't mind seeing a new interface for that.

Bjorn

> ________________________________________
> From: Bjorn Helgaas [bhelgaas@google.com]
> Sent: Friday, May 29, 2015 9:20 AM
> To: Casey Leedom
> Cc: netdev@vger.kernel.org; linux-pci@vger.kernel.org
> Subject: Re: Request for advice on where to put Root Complex "fix up" code for downstream device
>
> Hi Casey,
>
> Sorry, this one slipped through and I forgot to respond earlier.
>
> On Thu, May 07, 2015 at 11:31:58PM +0000, Casey Leedom wrote:
>> | From: Bjorn Helgaas [bhelgaas@google.com]
>> | Sent: Thursday, May 07, 2015 4:04 PM
>> |
>> | There are a lot of fixups in drivers/pci/quirks.c.  For things that have to
>> | be worked around either before a driver claims the device or if there is no
>> | driver at all, the fixup *has* to go in drivers/pci/quirks.c
>> |
>> | But for things like this, where the problem can only occur after a driver
>> | claims the device, I think it makes more sense to put the fixup in the
>> | driver itself.  The only wrinkle here is that the fixup has to be done on a
>> | separate device, not the device claimed by the driver.  But I think it
>> | probably still makes sense to put this fixup in the driver.
>>
>>   Okay, the example code that I provided (still quoted below) was indeed
>> done as a fix within the cxgb4 Network Driver.  I've also worked up a
>> version as a PCI Quirk but if you and David Miller agree that the fixup
>> code should go into cxgb4, I'm comfortable with that.  I can also provide
>> the example PCI Quirk code I worked up if you like.
>>
>>   One complication to doing this in cxgb4 is that it attaches to Physical
>> Function 4 of our T5 chip.  Meanwhile, a completely separate storage
>> driver, csiostor, connections to PF5 and PF6 and there's no
>> requirement at all that cxgb4 be loaded.  So if we go down the road of
>> putting the fixup code in the cxgb4 driver, we'll also need to duplicate
>> that code in the csiostor driver.
>
> Sounds simpler to just put the quirk in drivers/pci/quirks.c.
>
>> | > +static void clear_root_complex_tlp_attributes(struct pci_dev *pdev)
>> | > +{
>> | > +     struct pci_bus *bus = pdev->bus;
>> | > +     struct pci_dev *highest_pcie_bridge = NULL;
>> | > +
>> | > +     while (bus) {
>> | > +             struct pci_dev *bridge = bus->self;
>> | > +
>> | > +             if (!bridge || !bridge->pcie_cap)
>> | > +                     break;
>> | > +             highest_pcie_bridge = bridge;
>> | > +             bus = bus->parent;
>> | > +     }
>> |
>> | Can you use pci_upstream_bridge() here?  There are a couple places where we
>> | want to find the Root Port, so we might factor that out someday.  It'll be
>> | easier to find all those places if they use with pci_upstream_bridge().
>>
>> It looks like pci_upstream_bridge() just traverses one like upstream toward the
>> Root Complex?  Or am I misunderstanding that function?
>
> No, you're right.  I was just trying to suggest using pci_upstream_bridge()
> instead of bus->parent->self in your loop.  It wouldn't replace the loop
> completely.
>
> Bjorn
