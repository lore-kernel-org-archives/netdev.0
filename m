From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Sat, 5 Oct 2013 16:20:55 +0200
Message-ID: <20131005142054.GA11270@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
 <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
 <1380922156.3214.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
        linux-dr
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1380922156.3214.49.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Fri, Oct 04, 2013 at 10:29:16PM +0100, Ben Hutchings wrote:
> On Fri, 2013-10-04 at 10:29 +0200, Alexander Gordeev wrote:
> All I can see there is that Tejun didn't think that the global limits
> and positive return values were implemented by any architecture.

I would say more than just that :) I picked few quotes which in my
reading represent the guys positions:

Tejun Heo: "...do we really
care about possible partial success?  This sort of interface is
unnecessarily complex and actively harmful.  It forces all users to
wonder what could possibly happen and implement all sorts of nutty
fallback logic which is highly likely to be error-prone on both the
software and hardware side.  Seriously, how much testing would such
code path would get both on the driver and firmware sides?"

Bjorn Helgaas: "I agree, that would be much simpler.
I propose that you rework it that way, and at least find out what
(if anything) would break if we do that."

Michael Ellerman: "I really think you're overstating the complexity here.
Functions typically return a boolean   -> nothing to see here
This function returns a tristate value -> brain explosion!";
"All a lot of bother for no real gain IMHO."

> But you have a counter-example, so I'm not sure what your point is.

I concur with Tejun. I think we need to get rid of the loop.

As of the counter-example I think we could honour the pSeries quota by
inroducing an interface to interrogate what you call global limits -
pci_get_msix_limit(), i.e.:

	rc = pci_msix_table_size(pdev, nvec);
	if (rc < 0)
		return rc;

	nvec = min(rc, nvec);

	rc = pci_get_msix_limit(pdev, nvec);
	if (rc < 0)
		return rc;

	nvec = min(rc, nvec);

	for (i = 0; i < nvec; i++)
		msix_entry[i].entry = i;

	rc = pci_enable_msix(pdev, msix_entry, nvec);
	if (rc)
		return rc;

The latest state of those discussion is somewhere around Michael's:
"We could probably make that work." and Tejun's: "Are we talking about
some limited number of device drivers here? Also, is the quota still
necessary for machines in production today?"

So my point is - drivers should first obtain a number of MSIs they *can*
get, then *derive* a number of MSIs the device is fine with and only then
request that number. Not terribly different from memory or any other type
of resource allocation ;)

> It has been quite a while since I saw this happen on x86.  But I just
> checked on a test system running RHEL 5 i386 (Linux 2.6.18).  If I ask
> for 16 MSI-X vectors on a device that supports 1024, the return value is
> 8, and indeed I can then successfully allocate 8.
> 
> Now that's going quite a way back, and it may be that global limits
> aren't a significant problem any more.  With the x86_64 build of RHEL 5
> on an identical system, I can allocate 16 or even 32, so this is
> apparently not a hardware limit in this case.

Well, I do not know how to comment here. 2.6.18 has a significantly
different codebase wrt MSIs. What about a recent version?

> Most drivers seem to either:
> (a) require exactly a certain number of MSI vectors, or
> (b) require a minimum number of MSI vectors, usually want to allocate
> more, and work with any number in between
> 
> We can support drivers in both classes by adding new allocation
> functions that allow specifying a minimum (required) and maximum
> (wanted) number of MSI vectors.  Those in class (a) would just specify
> the same value for both.  These new functions can take account of any
> global limit or allocation policy without any further changes to the
> drivers that use them.

I think such interface is redundant wrt the current pci_enable_msix()
implementation.. and you propose to leave it. IMO it unnecessarily blows
the generic MSI API with no demand from drivers.

> The few drivers with more specific requirements would still need to
> implement the currently recommended loop, using the old allocation
> functions.

Although the classes of drivers you specified indeed exist, I do believe
just a single interface is enough to handle them all.

> Ben.

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
