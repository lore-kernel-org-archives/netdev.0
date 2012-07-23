From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: New commands to configure IOV features
Date: Mon, 23 Jul 2012 17:06:17 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A070C7D88D0@ORSMSX106.amr.corp.intel.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>
			<5005D45D.1040302@genband.com>
		 <20120717.141153.46613285253481776.davem@davemloft.net>
		 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>
	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009B186.6000806@genband.com>
 <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
 <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com>
 <500D6932.8090306@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"yuvalmin@broadcom.com" <yuvalmin@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>,
	Don Dutile <ddutile@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30372 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753142Ab2GWRGX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 13:06:23 -0400
In-Reply-To: <500D6932.8090306@genband.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Chris Friesen [mailto:chris.friesen@genband.com]
> Sent: Monday, July 23, 2012 8:10 AM
> To: Don Dutile
> Cc: Ben Hutchings; David Miller; yuvalmin@broadcom.com; Rose, Gregory V;
> netdev@vger.kernel.org; linux-pci@vger.kernel.org
> Subject: Re: New commands to configure IOV features
> 
> On 07/23/2012 08:03 AM, Don Dutile wrote:
> > On 07/20/2012 07:42 PM, Chris Friesen wrote:
> >>
> >> I actually have a use-case where the guest needs to be able to modify
> >> the MAC addresses of network devices that are actually VFs.
> >>
> >> The guest is bonding the network devices together, so the bonding
> >> driver in the guest expects to be able to set all the slaves to the
> >> same MAC address.
> >>
> >> As I read the ixgbe driver, this should be possible as long as the
> >> host hasn't explicitly set the MAC address of the VF. Is that correct?
> >>
> >> Chris
> >
> > Interesting tug of war: hypervisors will want to set the macaddrs for
> > security reasons,
> >                         some guests may want to set macaddr for
> > (valid?) config reasons.
> >
> 
> In our case we have control over both guest an host anyways, so it's
> less of a security issue.  In the general case though I could see it
> being an interesting problem.
> 
> Back to the original discussion though--has anyone got any ideas about
> the best way to trigger runtime creation of VFs?  I don't know what the
> binary APIs looks like, but via sysfs I could see something like
> 
> echo number_of_new_vfs_to_create >
> /sys/bus/pci/devices/<address>/create_vfs

The original proposals for creation and management of virtual functions were very much along these lines.  However, at the time most of the distributions that used virtualization were based upon the 2.6.18 kernel.  Red Hat Enterprise Linux 5.x and Citrix Xen Server were both using kernels derived from the 2.6.18 kernel.  In order to implement a sysfs based management approach we would have had to break the 2.6.18 kernel ABI, which is of course a non-starter.  We were able to implement an SR-IOV solution without breaking the ABI but it required use of a module parameter to inform the PF driver of how many VFs it should create.

This was fine during the first couple of years in which not many folks were using SR-IOV outside of a lab and the number of platforms that supported SR-IOV was very limited.  As an experimental solution it has worked pretty well.

The last year and a half or so we have seen SR-IOV go from an experimental technology to one that is becoming increasingly deployed in real world applications and now the limitations of that original approach are more apparent.  

> 
> Something else that occurred to me--is there buy-in from driver
> maintainers?

That's a good question.  I've seen a lot of resistance to using sysfs based interfaces in drivers but usually that is when a driver wants to implement a private interface that other drivers wouldn't want or be able to use.  I'm less sure about a sysfs solution that could be deployed by all SR-IOV capable devices of any type, be they Ethernet controllers, SCSI controllers, etc.  I'm not sure what the objection would be in case of a general purpose solution, however I've been told that in general sysfs based solutions are often frowned upon by kernel maintainers.  Perhaps that is because many of them are not generic solutions to a well defined problem.

  I know the Intel ethernet drivers (what I'm most familiar
> with) would need to be substantially modified to support on-the-fly
> addition of new vfs.

Actually, it wouldn't be that bad.  But yes, there'd have to be some way for a driver to register a callback routine with the PCI interface so that it could be notified when changes have been made to the SR-IOV configuration of the device.  This would require a new API, and some driver changes.  In the case of the Intel drivers it wouldn't be too intrusive and it would definitely help us to meet some customer requirements.  The current model using a module parameter forces all ports controlled by a PF driver to use the same number of VFs per function.  This is clunky and there are a lot of users that would like the ability to assign differing numbers of VFs to respective physical functions.

I should also note that we need to be careful about what we mean by the phrase "support on-the-fly addition of new vfs".

You cannot just add VFs without first tearing down the VFs that are currently allocated.  This is a limitation of the PCIE SR-IOV spec IIRC, and in any case it is true with Intel SR-IOV capable devices.  The numVFs parameter in the SR-IOV capability structure is not writeable while the VF enable bit is set.  To change that value you must first clear the VF enable bit and when you do that all your current VFs cease to exist.  You can then write a different number of VFs and re-enable them but during a short interval the VFs that were already there are destroyed and completely reset when they come back on-line.

- Greg
