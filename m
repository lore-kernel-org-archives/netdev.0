From: David Miller <davem@davemloft.net>
Subject: Re: Regression: "rtnetlink: Compute and store minimum ifinfo dump
 size" breaks glibc's getifaddrs()
Date: Fri, 27 Jan 2012 16:53:57 -0500 (EST)
Message-ID: <20120127.165357.462031319592012792.davem@davemloft.net>
References: <4F229A5F.4050600@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregory.v.rose@intel.com, steweg@gmail.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab2A0VyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:54:02 -0500
In-Reply-To: <4F229A5F.4050600@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Fri, 27 Jan 2012 12:36:47 +0000

> Changeset c7ac8679bec9397afe8918f788cbcef88c38da54 (rtnetlink: Compute
> and store minimum ifinfo dump size) applied to 3.1 increased the maximum
> size of the RTM_GETLINK message response.
> 
> glibc's getifaddrs() function uses a page sized (4 KiB) buffer for the
> RTM_GETLINK response and returns a failure if the message is truncated.
> This buffer is not large enough if there is a network card with many
> virtual functions.
> 
> What do you recommend to resolve this regression?

Actually, glibc technically uses the CPP define value "PAGE_SIZE" if
available, which is potentially different from the system page size.

Using a statically defined PAGE_SIZE is wrong if the program is
subsequently executed on a system with a different page size.

On sparc, and powerpc I believe, this happens commonly.  A 32-bit
executable will see a PAGE_SIZE value of 4K, but when executed on a
64-bit system the page size is actually 8K or larger.  That's why
__getpagesize() should always be used.

Anyways, if the page sizes are correct we're in a bit of a pickle.

Do you have any idea what the computed value of min_ifinfo_dump_size
is at the time of the failure?

Greg, I think we're kind of screwed.  The defined minimum appropriate
buffer size for a recvmsg() call on a netlink socket is defined as:

	getpagesize() < 8192 ? getpagesize() : 8192

and glibc essentially abides by this by unconditionally using page
size, and therefore if an interface with many virtual interfaces takes
us over this limit, we break basically every properly written piece of
netlink code out there.

iproute2 is funny, it uses a static 16K buffer size for netlink
message reception, which tends to paper over this problem :-/

Stefan, this plays into your work too, we're starting to create
situations which are going to cause very serious problems.  Imagine
an interface with lots of these new macvlan source rules, it would
potentially exceed the limit in the above equation as well.

Thanks.
