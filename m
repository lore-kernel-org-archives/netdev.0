From: Roland Dreier <roland.dreier@gmail.com>
Subject: Re: [PATCH] PCI: Update ACS quirk for more Intel 10G NICs
Date: Mon, 24 Jul 2017 10:18:56 -0700
Message-ID: <CAG4TOxNufQHj0nNwzw_yDMQfp+cAQuiQgEJg6KNX2ebiJDUuUw@mail.gmail.com>
References: <20170720214101.7449-1-roland@kernel.org> <20170720161554.45ce1673@ul30vt.home>
 <CAG4TOxOrF9aLyujrwNmSsxPBWBPTaLx2yXkOJ88gxCj0QUGDow@mail.gmail.com> <20170724104505.74c67861@w520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Emil Tantilov <emil.s.tantilov@intel.com>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170724104505.74c67861@w520.home>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think that the device implementing ACS and not implementing certain
> features that are "must be implemented if..." is a positive indication
> that the device does not have that behavior and therefore the ability
> to control that behavior is unnecessary.  pci_acs_flags_enabled() is
> coded with this intention:
>
> static bool pci_acs_flags_enabled(struct pci_dev *pdev, u16 acs_flags)
> {
>         int pos;
>         u16 cap, ctrl;
>
>         pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_ACS);
>         if (!pos)
>                 return false;
>
>         /*
>          * Except for egress control, capabilities are either required
>          * or only required if controllable.  Features missing from the
>          * capability field can therefore be assumed as hard-wired enabled.
>          */
>         pci_read_config_word(pdev, pos + PCI_ACS_CAP, &cap);
>         acs_flags &= (cap | PCI_ACS_EC);
>
> <Remove any requested ACS flags which are not implemented, except EC>
>
>         pci_read_config_word(pdev, pos + PCI_ACS_CTRL, &ctrl);
>         return (ctrl & acs_flags) == acs_flags;
>
> <Compare what remains>

I'm not sure it makes sense to look for the EC bit in the control register if
the capability bit says it is not supported.  In fact I think it would
violate the PCI spec to set the bit in the control register if it is zero in the
capability register - the spec says:

  Default value of this bit is 0b. Must be hardwired to 0b if the ACS P2P
  Egress Control functionality is not implemented.

I don't understand the reasoning behind forcing the EC bit in commit
83db7e0bdb70.

I think the only reason this works is that nowhere in the kernel uses
this function to check PCI_ACS_EC.

> At least that's my interpretation and how I've indicated to folks at
> Intel how things should work for a device that does not support p2p.
> Of course this all hinges on having an ACS capability.  Without an ACS
> capability we must assume any sort of p2p is possible unless we have a
> quirk to tell us otherwise.  With ACS, the absence of capabilities is a
> positive indication that those forms of p2p are not possible (depending
> on the spec wording for that capability).  If the code doesn't behave
> that way, let's fix it. Thanks,

Thanks - I'm looking more closely at what goes wrong with X550, since
from reading the code it looks like it should work, but people have observed
that it doesn't on our system.  However the issue might be elsewhere.

However I'll send a patch removing that "| PCI_ACS_EC" from the check if
you agree - maybe I'm misunderstanding the logic but I don't see how it
could work if it ever became relevant.

 - R.
