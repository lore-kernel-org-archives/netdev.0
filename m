From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Use a bus-global mutex to
 protect VPD operations
Date: Tue, 19 May 2015 16:01:58 -0700
Message-ID: <20150519160158.00002cd6@unknown>
References: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com>
	<555B78F7.60908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark D Rustad <mark.d.rustad@intel.com>, <bhelgaas@google.com>,
	<linux-pci@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>,
	<netdev@vger.kernel.org>, jesse.brandeburg@intel.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <555B78F7.60908@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 May 2015 10:55:03 -0700
Alexander Duyck <alexander.h.duyck@redhat.com> wrote:

> On 05/18/2015 05:00 PM, Mark D Rustad wrote:
> > Some devices have a problem with concurrent VPD access to different
> > functions of the same physical device, so move the protecting mutex
> > from the pci_vpd structure to the pci_bus structure. There are a
> > number of reports on support sites for a variety of devices from
> > various vendors getting the "vpd r/w failed" message. This is likely
> > to at least fix some of them. Thanks to Shannon Nelson for helping
> > to come up with this approach.
> >
> > Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> > Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> > Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Instead of moving the mutex lock around you would be much better served 
> by simply removing the duplicate VPD entries for a given device in a 
> PCIe quirk.  Then you can save yourself the extra pain and effort of 
> having to deal with serialized VPD accesses for a multifunction device.
> 
> The logic for the quirk should be fairly simple.
>    1.  Scan for any other devices with VPD that share the same bus and 
> device number.
>    2.  If bdf is equal to us keep searching.
>    3.  If bdf is less than our bdf we release our VPD area and set VPD 
> pointer to NULL.

But Alex if you do this you're violating the principle of least
surprise, not to mention changing a user-space interface which should
not be done.

Mark's solution is pretty graceful and solves the issue at heart, which
is that
1) several Intel chips have this issue
2) it appears that several other vendor's chips have this issue (or
similar) as well, but even if they don't Mark's fix will not change
their general operation, only make a small serializing effect when
multiple simultaneous reads are made.

This is a reasonably small fix, with a small kernel footprint, which
does not require changing user expectations or violating user-space
semantics that are already established, so I support it as is.
