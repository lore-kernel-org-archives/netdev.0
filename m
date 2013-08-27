From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: pcie_get_minimum_link returns 0 width
Date: Tue, 27 Aug 2013 10:13:57 -0600
Message-ID: <20130827161357.GA21180@google.com>
References: <20130825100157.GA16500@lb-tlvb-yuvalmin.il.broadcom.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
 <CAErSpo4NmL0RWcBompuweHNYmhNmLXU_21_gvaqfDEzi+HBp5g@mail.gmail.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD13D0C@SJEXCHMB10.corp.ad.broadcom.com>
 <CAErSpo68LaevaBG8rJD0aj+oy-cp_f2ZsQVEhXL=oUyyRiYwZw@mail.gmail.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD13FB9@SJEXCHMB10.corp.ad.broadcom.com>
 <CAErSpo6pCzw6Gjn+SCFhu7PnBpHkUz0oqO+tGmmOH8NxoMiH6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jacob.e.keller@intel.com" <jacob.e.keller@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jiang Liu <jiang.liu@huawei.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAErSpo6pCzw6Gjn+SCFhu7PnBpHkUz0oqO+tGmmOH8NxoMiH6g@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 27, 2013 at 07:57:20AM -0600, Bjorn Helgaas wrote:
> [+cc Jiang]
> 
> On Tue, Aug 27, 2013 at 1:40 AM, Yuval Mintz <yuvalmin@broadcom.com> wrote:
> >> On Mon, Aug 26, 2013 at 5:36 PM, Yuval Mintz <yuvalmin@broadcom.com>
> >> wrote:
> >> >> > Hi,
> >> >> >
> >> >> > I tried adding support for the newly added 'pcie_get_minimum_link' into
> >> >> the
> >> >> > bnx2x driver, but found out the some of my devices started showing
> >> width
> >> >> x0.
> >> >> >
> >> >> > By adding debug prints, I've found out there were devices up the chain
> >> that
> >> >> > Showed 0 when their PCI_EXP_LNKSTA was read by said function.
> >> >> > However, when I tried looking via lspci the output claimed the width was
> >> >> x4.
> >> Looking at its implementation, one obvious difference is that
> >> pcie_get_minimum_link() traverses up the hierarchy and keeps track of
> >> the minimum values it finds.  lspci, on the other hand, just reads
> >> PCI_EXP_LNKSTA from a single device and decodes it.
> >>
> >> You said lspci reports x4 for every device from the Root Port all the
> >> way down to your NIC, so I would think the minimum from
> >> pcie_get_minimum_link() would be x4.  But apparently it's not.  Maybe
> >> there's a bug in it.  Can you post the complete "lspci -vv" output
> >> along with your debug patch and output?
> >>
> >> Bjorn
> >
> > Here's the patch:
> > ---
> >  drivers/pci/pci.c |    8 +++++++-
> >  1 files changed, 7 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> > index c71e78c..72cb87b 100644
> > --- a/drivers/pci/pci.c
> > +++ b/drivers/pci/pci.c
> > @@ -3601,13 +3601,19 @@ int pcie_get_minimum_link(struct pci_dev *dev, enum pci_bus_speed *speed,
> >                 enum pcie_link_width next_width;
> >
> >                 ret = pcie_capability_read_word(dev, PCI_EXP_LNKSTA, &lnksta);
> > -               if (ret)
> > +               if (ret) {
> > +                       printk(KERN_ERR "Failed to Read LNKSTA\n");
> >                         return ret;
> > +               }
> >
> >                 next_speed = pcie_link_speed[lnksta & PCI_EXP_LNKSTA_CLS];
> >                 next_width = (lnksta & PCI_EXP_LNKSTA_NLW) >>
> >                         PCI_EXP_LNKSTA_NLW_SHIFT;
> >
> > +               printk(KERN_ERR "LnkSta %04x [%04x:%02x.%02x]\n",
> > +                      lnksta, dev->bus->number, PCI_SLOT(dev->devfn),
> > +                      PCI_FUNC(dev->devfn));
> 
> I think pcie_cap_has_lnkctl() is incorrect: it currently thinks only
> Root Ports, Endpoints, and Legacy Endpoints have link registers.  But
> I think switch ports (Upstream Ports and Downstream Ports) also have
> link registers (PCIe spec r3.0, sec 7.8).  Jiang?

Yuval, can you try the patch below?


PCI: Allow access to link-related registers for switch and bridge ports

From: Bjorn Helgaas <bhelgaas@google.com>

Every PCIe device has a link, except Root Complex Integrated Endpoints
and Root Complex Event Collectors.  Previously we didn't give access
to PCIe capability link-related registers for Upstream Ports, Downstream
Ports, and bridges, so attempts to read PCI_EXP_LNKCTL returned zero.
See PCIe spec r3.0, sec 7.8 and 1.3.2.3.

Reported-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/access.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/pci/access.c b/drivers/pci/access.c
index 1cc2366..46dd5ad 100644
--- a/drivers/pci/access.c
+++ b/drivers/pci/access.c
@@ -485,9 +485,8 @@ static inline bool pcie_cap_has_lnkctl(const struct pci_dev *dev)
 	int type = pci_pcie_type(dev);
 
 	return pcie_cap_version(dev) > 1 ||
-	       type == PCI_EXP_TYPE_ROOT_PORT ||
-	       type == PCI_EXP_TYPE_ENDPOINT ||
-	       type == PCI_EXP_TYPE_LEG_END;
+	       !(type == PCI_EXP_TYPE_RC_END ||
+	         type == PCI_EXP_TYPE_RC_EC);
 }
 
 static inline bool pcie_cap_has_sltctl(const struct pci_dev *dev)
