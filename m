From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: setsockopt()
Date: Wed, 9 Jul 2008 10:03:41 +0400
Message-ID: <20080709060341.GA29743@2ka.mipt.ru>
References: <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu> <20080707.144912.76654646.davem@davemloft.net> <20080708045443.GA7726@2ka.mipt.ru> <20080708020235.388a7bd5.billfink@mindspring.com> <adar6a4x510.fsf@cisco.com> <20080708134845.2372a483@speedy> <20080708180500.e8a61231.billfink@mindspring.com> <20080709052534.GA8157@2ka.mipt.ru> <20080709014758.d59be0d8.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:50560 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381AbYGIGED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 02:04:03 -0400
Content-Disposition: inline
In-Reply-To: <20080709014758.d59be0d8.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2008 at 01:47:58AM -0400, Bill Fink (billfink@mindspring.com) wrote:
> Are you sure you're not thinking about tcp_mem, which is a function
> of available memory, or has this been changed in more recent kernels?
> The 2.6.22.9 Documentation/networking/ip-sysctl.txt indicates:

In 2.6.25 tcp_mem depends on amount of ram, and third tcp_wmem is
calculated based on it:

/* Set per-socket limits to no more than 1/128 the pressure threshold */
limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
max_share = min(4UL*1024*1024, limit);

sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
sysctl_tcp_wmem[1] = 16*1024;
sysctl_tcp_wmem[2] = max(64*1024, max_share);

sysctl_tcp_rmem[0] = SK_MEM_QUANTUM;
sysctl_tcp_rmem[1] = 87380;
sysctl_tcp_rmem[2] = max(87380, max_share);

> tcp_wmem - vector of 3 INTEGERs: min, default, max
> 	...
> 	max: Maximal amount of memory allowed for automatically selected
> 	send buffers for TCP socket. This value does not override
> 	net.core.wmem_max, "static" selection via SO_SNDBUF does not use this.
> 	Default: 128K

Yeah, its a bit confusing. It probably was copypasted, there is no
default, but minimum possible value.

> 
> The TCP autotuning worked great, with both tests basically achieving
> full 10-GigE line rate.  The test with the TCP autotuning actually
> did slightly better than the test where an explicitly specified 1 MB
> socket buffer was used, although this could just be within the margin
> of error of the testing.

If you will check tcp_wmem on your machine, it will likely show that
tcp_wmem[max] is far larger than 128k. It is equal to 1mb on my old
laptop with 256mb of ram, I suppose machines equipped with 10gige
network adapters usually have slightly more.

-- 
	Evgeniy Polyakov
