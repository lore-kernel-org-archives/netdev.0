From: James Morris <jmorris@namei.org>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Thu, 1 Feb 2007 18:44:48 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0702011819070.11820@d.namei>
References: <1170370281.2603.359.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:47792 "EHLO
	mail5.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422944AbXBAXov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 18:44:51 -0500
In-Reply-To: <1170370281.2603.359.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Feb 2007, Joy Latten wrote:

> IPsec returns EAGAIN when it needs to acquire an SA.
> There have been a thread or two about this...
> Has there been any info or progress in how best to fix this?
> 
> James Morris presented some work/ideas,
> http://vger.kernel.org/jmorris_ipsec_sa_resolution_netconf2006.pdf

The status of this is that I started refactoring some core IPv6 code (to 
bring it in line with the IPv4 code, e.g. create an ip6_route_connect() to 
match ip_route_connect(), and manage the packet queuing from there) and 
ran into some IPv6 bugs, and fixed those, but then ran out of time on the 
IPsec stuff.  AFAIK, no other progress has been made.

Generally, the problem is only seen when using the BSD userland, which 
does not proactively maintain SAs.  Openswan does, and general IPsec users 
running it never see the problem, so it's not clear how high the priority 
is for fixing this really is in the general case.  It's quite a lot of 
surgery on core networking to fix a problem which doesn't occur with the 
Linux tools, which seemingly most people use when they're not using 
proprietary and/or userland IPsec stacks.

Non-kernel options include moving to Openswan (which I would hope is 
getting labeled networking support at some stage in any case), or have the 
BSD code proactively maintain SAs.

Also, applications using TCP, and UDP applications with their own session 
management, will resend packets while the SA is being negotiated, which 
I've observed as typically completing before the first resend.  I think 
one of the practical problems with this is that the apps are not expecting 
an EAGAIN and thus decide to crash.

A quick & dirty solution, which is what I think the BSD kernels do, is to 
still drop the packet but just not return an error to the app.  The app 
then just sees a slight delay on the initial connection, as if a DNS 
lookup took a bit longer than usual.

> When using labeled xfrms (xfrms that contain a security context), there
> is potential for a greater amount of SAs to be created than when using
> regular xfrms. An SA may be created every time a different security
> context is encountered in a particular traffic stream. This could be
> many if each networking app has its own security context, making current
> behavior problematic.

Do you have any examples of how many SAs would need to be created on a 
typical system?

It may not be the end of the world if an MLS box has to negotiate a 
whole bunch of SAs when it boots up.


- James
-- 
James Morris
<jmorris@namei.org>
