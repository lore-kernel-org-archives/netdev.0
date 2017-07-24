From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] PCI: Update ACS quirk for more Intel 10G NICs
Date: Mon, 24 Jul 2017 10:45:05 -0600
Message-ID: <20170724104505.74c67861@w520.home>
References: <20170720214101.7449-1-roland@kernel.org>
        <20170720161554.45ce1673@ul30vt.home>
        <CAG4TOxOrF9aLyujrwNmSsxPBWBPTaLx2yXkOJ88gxCj0QUGDow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Emil Tantilov <emil.s.tantilov@intel.com>
To: Roland Dreier <roland.dreier@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAG4TOxOrF9aLyujrwNmSsxPBWBPTaLx2yXkOJ88gxCj0QUGDow@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Jul 2017 15:53:04 -0700
Roland Dreier <roland.dreier@gmail.com> wrote:

> On Thu, Jul 20, 2017 at 3:15 PM, Alex Williamson
> <alex.williamson@redhat.com> wrote:
> 
> > Most of the ACS capabilities are worded as "Must be implemented by
> > devices that implement ..."  Shouldn't a hard-wired ACS capability
> > sufficiently describe that, or is there something wrong with how
> > they're hard wired?  
> 
> Interesting question.  I just looked at what the PCI spec says about
> the various bits for ACS functions in multi-function devices.  Many of
> the functions are "must not be implemented."  Of the ones that are
> "must be implemented if..." the key is that the if is for devices that
> support peer-to-peer traffic.
> 
> I think the Intel NICs are compliant with the spec - they don't
> support any ACS mechanisms for controlling peer-to-peer traffic, but
> they also don't implement peer-to-peer traffic.  This means that the
> PCI standard way of knowing that it is safe to assign individual
> functions does not prove it is safe - but with device-specific
> knowledge we do know it is safe.  Hence a quirk to give that
> device-specific information to the kernel.

I think that the device implementing ACS and not implementing certain
features that are "must be implemented if..." is a positive indication
that the device does not have that behavior and therefore the ability
to control that behavior is unnecessary.  pci_acs_flags_enabled() is
coded with this intention:

static bool pci_acs_flags_enabled(struct pci_dev *pdev, u16 acs_flags)
{
        int pos;
        u16 cap, ctrl;

        pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_ACS);
        if (!pos)
                return false;

        /*
         * Except for egress control, capabilities are either required
         * or only required if controllable.  Features missing from the
         * capability field can therefore be assumed as hard-wired enabled.
         */
        pci_read_config_word(pdev, pos + PCI_ACS_CAP, &cap);
        acs_flags &= (cap | PCI_ACS_EC);

<Remove any requested ACS flags which are not implemented, except EC>

        pci_read_config_word(pdev, pos + PCI_ACS_CTRL, &ctrl);
        return (ctrl & acs_flags) == acs_flags;

<Compare what remains>
}

For example, from the spec (rev 3.1a 6.12.1.2):

  ACS P2P Request Redirect: must be implemented by Functions that
  support peer-to-peer traffic with other Functions.

<Therefore if this capability within ACS is not implemented, p2p is not
supported.>

  When ACS P2P Request Redirect is enabled in a multi-Function device,
  peer-to-peer Requests (between Functions of the device) must be
  redirected Upstream towards the RC.

<If p2p is not supported, there's no need to control this, the behavior
is the same is if p2p were supported and this control bit is enabled>

At least that's my interpretation and how I've indicated to folks at
Intel how things should work for a device that does not support p2p.
Of course this all hinges on having an ACS capability.  Without an ACS
capability we must assume any sort of p2p is possible unless we have a
quirk to tell us otherwise.  With ACS, the absence of capabilities is a
positive indication that those forms of p2p are not possible (depending
on the spec wording for that capability).  If the code doesn't behave
that way, let's fix it. Thanks,

Alex
