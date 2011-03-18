From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Stale entries in RT_TABLE_LOCAL
Date: Sat, 19 Mar 2011 00:57:30 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103190011430.1678@ja.ssi.bg>
References: <201102231243.23579.alexandre.sidorenko@hp.com> <alpine.LFD.2.00.1103100139510.2372@ja.ssi.bg> <alpine.LFD.2.00.1103100222080.2550@ja.ssi.bg> <201103101441.57105.alexandre.sidorenko@hp.com> <alpine.LFD.2.00.1103151033260.1729@ja.ssi.bg>
 <20110317161129.GA6384@midget.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48323 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932577Ab1CRWw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 18:52:29 -0400
In-Reply-To: <20110317161129.GA6384@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Thu, 17 Mar 2011, Jiri Bohac wrote:

>>>> IP2: 192.168.142.109/23, primary
>>>> IP3: 192.168.142.109/22, secondary for primary IP1
>>>>
>>>>        It is the route for IP3 that is leaked, with prefsrc=IP1.
>>>> We create local route for secondary IPs with prefsrc=ItsPrimaryIP.
>>>> Both local routes for 109 differ in prefsrc (fa_info)
>
> Is there any reason to set the prefsrc of a local route to the
> primary IP address of the subnet?
>
> I tried the following patch:
>
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 1d2cdd4..2046b21 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -751,7 +751,7 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
> 		}
> 	}
>
> -	fib_magic(RTM_NEWROUTE, RTN_LOCAL, addr, 32, prim);
> +	fib_magic(RTM_NEWROUTE, RTN_LOCAL, addr, 32, ifa);
>
> 	if (!(dev->flags & IFF_UP))
> 		return;
>
>
> The result with the teststcase mentioned previously is that only
> one local route is created per IP address. The local routes are
> correctly deleted after both identical IP addresses are removed
> from the interface.

 	It is a problem also for the broadcast addresses.

> Furthemore, the testcase uncovers another weirdness with the
> prefsrc of the local routes. When a primary IP address is deleted
> and a secondary IP address is promoted to primary, its prefsrc is
> not updated.

 	Yes, I see the same when the deleted primary is
also in another subnet or device.

> What is the prefrc of a local route good for?

 	To prefer this src when talking to local IP :)
You can always add local IPs with /32 mask but currently
you must add it first, i.e. fib_magic does not remove
the NLM_F_APPEND flag for /32 local routes when dst is
same as ifa->ifa_local. So, the order of IP adding
will determine the order of local routes:

ip addr add 1.2.3.4/24 brd + dev eth1
# secondary
ip addr add 1.2.3.5/24 brd + dev eth1
# primary:
ip addr add 1.2.3.5/32 brd + dev eth1

when talking to 1.2.3.5 you will use 1.2.3.4 because
the secondary is added first.

Regards

--
Julian Anastasov <ja@ssi.bg>
