From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen
Date: Tue, 7 Apr 2015 11:37:07 -0400
Message-ID: <20150407153707.GA28129@l.oracle.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Xen maintainers:
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>, ;
	Recently touched tg3:
	Prashant Sreedharan <prashant@broadcom.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>, ; Linux tg3 maintainers:
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, ;
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19410 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbbDGPhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 11:37:50 -0400
Content-Disposition: inline
In-Reply-To: <21795.62414.465476.464027@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 07, 2015 at 04:12:14PM +0100, Ian Jackson wrote:
> I am experiencing what appears to be a bug involving the tg3 NIC
> driver in (various stable branches of) Linux.
> 
> The symptom is a very high level of packet loss: around 25-30% (as
> seen in `ping').  There don't seem to be any untoward-looking kernel
> messages.  The lost packets get added to the `errors' counter shown in
> ifconfig.  I don't know whether the problem is with the transmit path,
> or receive path, or both.
> 
> All connections and data transfers seem to complete correctly
> eventually, but they can be very slow indeed.
> 
> The bug occurs only when Linux is running under Xen.  I have
> reproduced the bug with Linux running as dom0, both as a 32-bit PAE PV
> guest and as a 64-bit PV guest.  I have reproduced the bug with Linux

Do you see this if you run on baremetal with 'iommu=soft swiotlb=force'?
(same kernel). 

Looking briefly at the driver it looks to use the PCI DMA sync for frames smaller
than 256, and for larger it uses pci_unmap_single which would sync it too. Hmm.

Perhaps if baremetal you can reproduce it using the incantation mentioned
above it would narrow it to the usage of the PCI DMA API.

> 3.14.21, 3.14.34 and 3.18.0, but the bug seems absent from Debian's
> Linux 3.2.0-4-686-pae.
> 
> 
> An example of the failure can be seen in the logs from this automated
> test:
>   http://logs.test-lab.xenproject.org/osstest/logs/50216/test-amd64-i386-xl/info.html
> 
> The host's serial console output is here:
>   http://logs.test-lab.xenproject.org/osstest/logs/50216/test-amd64-i386-xl/serial-elbling0.log
> (Up to 01:23:01, at which time the automated tester started log
> capture including invoking Xen debug keys.)
>   
> As you can see from those logs, the test simply times out (in an
> operation which involves a lot of data transfer from a cache host on
> the local network).
> 
> In that particular test, we used:
>   Linux             413cb08cebe9fd8107f556eee48b2d40773cacde
>   linux-firmware    c530a75c1e6a472b0eb9558310b518f0dfcd8860
>   Xen               3a28f760508fb35c430edac17a9efde5aff6d1d5
> 
> The host OS is Debian wheezy i386 (32-bit x86).  The kernel was built
> for x86 32-bit PAE on Debian wheezy i386.  Xen was built for 64-bit
> x86 on Debian wheezy amd64 (64-bit x86).  In each case we used the
> default GCC supplied with Debian.
> 
> The full information about the kernel build including build
> log, kernel config, build outputs, and test harness control variables
> etc., are here:
>   http://logs.test-lab.xenproject.org/osstest/logs/50216/build-amd64-pvops/build/
>   http://logs.test-lab.xenproject.org/osstest/logs/50216/build-amd64-pvops/info.html
> 
> 
> I have a number of machines which are affected by this bug[1].  All
> have a tg3 as onboard NIC.
> 
> The bug is easy for me to reproduce.  I'd appreciate opinions on what
> this might be and how to go about debugging and fixing it, and more
> generally any help or advice.
> 
> I can test proposed kernel patches, or debugging patches, easily.
> (But if you provide patches please say what they are based on.)
> 
> Thanks,
> Ian.
> 
> [1] For my and Xen community reference:
>   - elbling{0,1} in the new osstest test lab
>   - merlot{0,1} in the new osstest test lab
>   - bedbug, test box under my desk
