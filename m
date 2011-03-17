From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: Stale entries in RT_TABLE_LOCAL
Date: Thu, 17 Mar 2011 17:11:29 +0100
Message-ID: <20110317161129.GA6384@midget.suse.cz>
References: <201102231243.23579.alexandre.sidorenko@hp.com>
 <alpine.LFD.2.00.1103100139510.2372@ja.ssi.bg>
 <alpine.LFD.2.00.1103100222080.2550@ja.ssi.bg>
 <201103101441.57105.alexandre.sidorenko@hp.com>
 <alpine.LFD.2.00.1103151033260.1729@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:35490 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754455Ab1CQQLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 12:11:33 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103151033260.1729@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Mar 15, 2011 at 10:47:20AM +0200, Julian Anastasov wrote:
> On Thu, 10 Mar 2011, Alex Sidorenko wrote:
> 
> >>IP1: 192.168.140.31/22, primary
> >>IP2: 192.168.142.109/23, primary
> >>IP3: 192.168.142.109/22, secondary for primary IP1
> >>
> >>        It is the route for IP3 that is leaked, with prefsrc=IP1.
> >>We create local route for secondary IPs with prefsrc=ItsPrimaryIP.
> >>Both local routes for 109 differ in prefsrc (fa_info)

Is there any reason to set the prefsrc of a local route to the
primary IP address of the subnet?

I tried the following patch:

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1d2cdd4..2046b21 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -751,7 +751,7 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 		}
 	}
 
-	fib_magic(RTM_NEWROUTE, RTN_LOCAL, addr, 32, prim);
+	fib_magic(RTM_NEWROUTE, RTN_LOCAL, addr, 32, ifa);
 
 	if (!(dev->flags & IFF_UP))
 		return;


The result with the teststcase mentioned previously is that only
one local route is created per IP address. The local routes are
correctly deleted after both identical IP addresses are removed
from the interface.

Furthemore, the testcase uncovers another weirdness with the
prefsrc of the local routes. When a primary IP address is deleted
and a secondary IP address is promoted to primary, its prefsrc is
not updated.

What is the prefrc of a local route good for?

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

