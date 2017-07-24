From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] PCI: Update ACS quirk for more Intel 10G NICs
Date: Mon, 24 Jul 2017 13:01:59 -0600
Message-ID: <20170724130159.309379e8@w520.home>
References: <20170720214101.7449-1-roland@kernel.org>
        <20170720161554.45ce1673@ul30vt.home>
        <CAG4TOxOrF9aLyujrwNmSsxPBWBPTaLx2yXkOJ88gxCj0QUGDow@mail.gmail.com>
        <20170724104505.74c67861@w520.home>
        <CAG4TOxNufQHj0nNwzw_yDMQfp+cAQuiQgEJg6KNX2ebiJDUuUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Emil Tantilov <emil.s.tantilov@intel.com>
To: Roland Dreier <roland.dreier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35900 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754238AbdGXTCB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 15:02:01 -0400
In-Reply-To: <CAG4TOxNufQHj0nNwzw_yDMQfp+cAQuiQgEJg6KNX2ebiJDUuUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Jul 2017 10:18:56 -0700
Roland Dreier <roland.dreier@gmail.com> wrote:

> > I think that the device implementing ACS and not implementing certain
> > features that are "must be implemented if..." is a positive indication
> > that the device does not have that behavior and therefore the ability
> > to control that behavior is unnecessary.  pci_acs_flags_enabled() is
> > coded with this intention:
> >
> > static bool pci_acs_flags_enabled(struct pci_dev *pdev, u16 acs_flags)
> > {
> >         int pos;
> >         u16 cap, ctrl;
> >
> >         pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_ACS);
> >         if (!pos)
> >                 return false;
> >
> >         /*
> >          * Except for egress control, capabilities are either required
> >          * or only required if controllable.  Features missing from the
> >          * capability field can therefore be assumed as hard-wired enabled.
> >          */
> >         pci_read_config_word(pdev, pos + PCI_ACS_CAP, &cap);
> >         acs_flags &= (cap | PCI_ACS_EC);
> >
> > <Remove any requested ACS flags which are not implemented, except EC>
> >
> >         pci_read_config_word(pdev, pos + PCI_ACS_CTRL, &ctrl);
> >         return (ctrl & acs_flags) == acs_flags;
> >
> > <Compare what remains>  
> 
> I'm not sure it makes sense to look for the EC bit in the control register if
> the capability bit says it is not supported.  In fact I think it would
> violate the PCI spec to set the bit in the control register if it is zero in the
> capability register - the spec says:
> 
>   Default value of this bit is 0b. Must be hardwired to 0b if the ACS P2P
>   Egress Control functionality is not implemented.
> 
> I don't understand the reasoning behind forcing the EC bit in commit
> 83db7e0bdb70.
> 
> I think the only reason this works is that nowhere in the kernel uses
> this function to check PCI_ACS_EC.

Is there a misunderstanding of the code flow here?  We're never setting
EC.  In the first code block we're just masking out requested
capabilities where unimplemented capabilities is the same as
implemented + enabled.  We're not adding EC to the request, we're
just not removing it based on the implemented capabilities because we
don't interpret it the same way.  Thus if someone wants to test a
device for EC, it really needs to implement EC, we cannot assume it
based on lack of support for EC in the ACS capability.  As you point
out, nobody really cares about EC yet though.

> > At least that's my interpretation and how I've indicated to folks at
> > Intel how things should work for a device that does not support p2p.
> > Of course this all hinges on having an ACS capability.  Without an ACS
> > capability we must assume any sort of p2p is possible unless we have a
> > quirk to tell us otherwise.  With ACS, the absence of capabilities is a
> > positive indication that those forms of p2p are not possible (depending
> > on the spec wording for that capability).  If the code doesn't behave
> > that way, let's fix it. Thanks,  
> 
> Thanks - I'm looking more closely at what goes wrong with X550, since
> from reading the code it looks like it should work, but people have observed
> that it doesn't on our system.  However the issue might be elsewhere.
> 
> However I'll send a patch removing that "| PCI_ACS_EC" from the check if
> you agree - maybe I'm misunderstanding the logic but I don't see how it
> could work if it ever became relevant.

I don't yet see anything wrong with the EC handling, but please explain
further if I'm just being dense.  Thanks,

Alex
