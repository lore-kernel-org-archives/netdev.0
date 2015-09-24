From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Thu, 24 Sep 2015 11:31:53 +0100
Message-ID: <20150924103152.GG13823@e104818-lin.cambridge.arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <1443033714.74600.18.camel@infradead.org>
 <560310EA.2070805@intel.com>
 <1443042212.74600.30.camel@infradead.org>
 <56033C10.2040708@linaro.org>
 <1443082579.74600.48.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hanjun Guo <hanjun.guo@linaro.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	steve.glendinning@shawell.net, netdev@vger.kernel.org,
	grant.likely@linaro.org, Suravee.Suthikulpanit@amd.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38008 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259AbbIXKb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 06:31:57 -0400
Content-Disposition: inline
In-Reply-To: <1443082579.74600.48.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Thu, Sep 24, 2015 at 09:16:19AM +0100, David Woodhouse wrote:
> On Wed, 2015-09-23 at 16:56 -0700, Hanjun Guo wrote:
> > It really depends on the people who writing the ASL code (DSDT),
> > I'm not sure if Windows will use _DSD and how to use it, but
> > firmware guys may just use the device ID to make the firmware
> > to be usable both by Linux and Windows, and that's reasonable
> > I think.
> 
> And the ideal way to do that is to add a _CID of "PRP0001" and a
> compatible string, and then Linux doesn't need to care about the
> special new HID that you've added purely to pander to the limitations
> of Windows.

PRP0001 could make sense from a Linux driver code reuse perspective. It
probably also makes sense for the x86 embedded world where there is ACPI
legacy. On embedded ARM we have DT already, so we don't need to solve
any ACPI issues.

However, for the ARM server ecosystem (both hardware and software), IMO,
PRP0001 will have long term negative implications. My view of the ARM
server (incipient) world is that we have two main categories of SoC
vendors targeting ACPI:

1. Vendors that have been in the server business for a long time and are
   looking into using ARM processors. They usually have experience with
   designing server hardware, ACPI firmware and targeting multiple OSes.

2. Vendors new to the server world (but not necessarily new to ARM) that
   would like to extend their SoC family with server products. They
   may not have prior experience with ACPI but are targeting it because
   they've probably been told so.

What I'm worried about is the second category. We try hard to make such
vendors follow both software and hardware standards (like ARM's SBSA and
even ACPI, I don't have a problem if used properly). They really need to
get into the habit of designing their hardware and firmware without
thinking that they can always apply a Linux patch and recompile the
kernel. In the server world, the kernel (image) is no longer owned by
the SoC vendor (as it is the norm in mobile space) but by a different
entity (OS vendor) which may not patch/upgrade the kernel every time
(for example) a clock routing is changed on some SoC.

So what we _do_ want on ARM is tight control of the _DSD properties that
are going to be used in ACPI tables, avoid pitfalls like OS-specific
names ("linux-trigger" is still listed as an example on uefi.org) or
defining more than the minimum necessary. In this last category we want
to avoid properties like clocks, voltage regulators; these should be
handled in an ACPI-specific way (AML, device power states) or just fully
initialised by the boot code/firmware when run-time changes not
required.

PRP0001 opens the door to any DT-like properties in ACPI and, knowing
how the ARM ecosystem works, I'm pretty sure we'll soon lose control (if
we haven't already; not all the developments are done in the open). I'm
also not a fan of different firmware paths based on which OS is running,
so I would rather have device _HID and _DSD properties where absolutely
necessary.

> (I'm planning to try to learn Coccinelle and do a bombing run convertin
> to the new API some time soon, FWIW).

I think such patch would address an issue with ACPI in the x86 embedded
land. But I'd very much like to make PRP0001 parsing depend on
!CONFIG_ARM64. What we first need to solve in the ARM (server) land is
firmware and hardware standardisation rather than working around it.

The pro ARM ACPI camp has been very vocal against DT in the server
space. I'd like to seem them as vocal about PRP0001, unless they find it
acceptable (and should apologise for bashing DT ;)).

Thanks.

-- 
Catalin
