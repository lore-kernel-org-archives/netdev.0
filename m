From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: Regression: "rtnetlink: Compute and store minimum ifinfo dump
 size" breaks glibc's getifaddrs()
Date: Mon, 30 Jan 2012 16:50:58 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A07012CCF52@ORSMSX106.amr.corp.intel.com>
References: <4F229A5F.4050600@citrix.com>
 <20120127.165357.462031319592012792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"steweg@gmail.com" <steweg@gmail.com>
To: David Miller <davem@davemloft.net>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6378 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742Ab2A3QvO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 11:51:14 -0500
In-Reply-To: <20120127.165357.462031319592012792.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, January 27, 2012 1:54 PM
> To: david.vrabel@citrix.com
> Cc: netdev@vger.kernel.org; Rose, Gregory V; steweg@gmail.com
> Subject: Re: Regression: "rtnetlink: Compute and store minimum ifinfo dump
> size" breaks glibc's getifaddrs()
> 
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Fri, 27 Jan 2012 12:36:47 +0000
> 
> > Changeset c7ac8679bec9397afe8918f788cbcef88c38da54 (rtnetlink: Compute
> > and store minimum ifinfo dump size) applied to 3.1 increased the maximum
> > size of the RTM_GETLINK message response.
> >
> > glibc's getifaddrs() function uses a page sized (4 KiB) buffer for the
> > RTM_GETLINK response and returns a failure if the message is truncated.
> > This buffer is not large enough if there is a network card with many
> > virtual functions.
> >
> > What do you recommend to resolve this regression?
> 
> Actually, glibc technically uses the CPP define value "PAGE_SIZE" if
> available, which is potentially different from the system page size.
> 
> Using a statically defined PAGE_SIZE is wrong if the program is
> subsequently executed on a system with a different page size.
> 
> On sparc, and powerpc I believe, this happens commonly.  A 32-bit
> executable will see a PAGE_SIZE value of 4K, but when executed on a
> 64-bit system the page size is actually 8K or larger.  That's why
> __getpagesize() should always be used.
> 
> Anyways, if the page sizes are correct we're in a bit of a pickle.
> 
> Do you have any idea what the computed value of min_ifinfo_dump_size
> is at the time of the failure?
> 
> Greg, I think we're kind of screwed.  The defined minimum appropriate
> buffer size for a recvmsg() call on a netlink socket is defined as:
> 
> 	getpagesize() < 8192 ? getpagesize() : 8192
> 
> and glibc essentially abides by this by unconditionally using page
> size, and therefore if an interface with many virtual interfaces takes
> us over this limit, we break basically every properly written piece of
> netlink code out there.

Yep, we're screwed.  And as more features and capabilities get added to virtual functions that we want to control through netlink it gets even worse.

Maybe we should have 'ip link show' just display the number of VFs and then have a new 'ip' tool syntax along the lines of 'ip link show eth(x) vf (n)' where eth(x) is the PF and n is the number of the VF.  Then it could show all relevant information for just that VF.  Scripts could parse the number of VFs from the first call to 'ip link show' and then loop to show the details of each VF.

Just an idea... maybe there are other ones out there but it's just getting ridiculous how much data has to be transferred back and forth during the basic 'ip link show' command when the interface as subordinate VFs now that we're getting to devices with up to 256 VFs.

- Greg
