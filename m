From: Joy Latten <latten@austin.ibm.com>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 05 Feb 2007 14:52:06 -0600
Message-ID: <1170708727.2603.366.camel@faith.austin.ibm.com>
References: <1170370281.2603.359.camel@faith.austin.ibm.com>
	 <Pine.LNX.4.64.0702011819070.11820@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:48418 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933441AbXBEVHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 16:07:20 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l15L7KQv032271
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 16:07:20 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l15L7JwG232642
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 16:07:19 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l15L7IF6021569
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 16:07:19 -0500
In-Reply-To: <Pine.LNX.4.64.0702011819070.11820@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-02-01 at 18:44 -0500, James Morris wrote:
> On Thu, 1 Feb 2007, Joy Latten wrote:
> 
> > IPsec returns EAGAIN when it needs to acquire an SA.
> > There have been a thread or two about this...
> > Has there been any info or progress in how best to fix this?
> > 
> > James Morris presented some work/ideas,
> > http://vger.kernel.org/jmorris_ipsec_sa_resolution_netconf2006.pdf
> 
> The status of this is that I started refactoring some core IPv6 code (to 
> bring it in line with the IPv4 code, e.g. create an ip6_route_connect() to 
> match ip_route_connect(), and manage the packet queuing from there) and 
> ran into some IPv6 bugs, and fixed those, but then ran out of time on the 
> IPsec stuff.  AFAIK, no other progress has been made.
> 
> Generally, the problem is only seen when using the BSD userland, which 
> does not proactively maintain SAs.  Openswan does, and general IPsec users 
> running it never see the problem, so it's not clear how high the priority 
> is for fixing this really is in the general case.  It's quite a lot of 
> surgery on core networking to fix a problem which doesn't occur with the 
> Linux tools, which seemingly most people use when they're not using 
> proprietary and/or userland IPsec stacks.
> 
> Non-kernel options include moving to Openswan (which I would hope is 
> getting labeled networking support at some stage in any case), or have the 
> BSD code proactively maintain SAs.
> 
> Also, applications using TCP, and UDP applications with their own session 
> management, will resend packets while the SA is being negotiated, which 
> I've observed as typically completing before the first resend.  I think 
> one of the practical problems with this is that the apps are not expecting 
> an EAGAIN and thus decide to crash.
> 
> A quick & dirty solution, which is what I think the BSD kernels do, is to 
> still drop the packet but just not return an error to the app.  The app 
> then just sees a slight delay on the initial connection, as if a DNS 
> lookup took a bit longer than usual.
> 
> > When using labeled xfrms (xfrms that contain a security context), there
> > is potential for a greater amount of SAs to be created than when using
> > regular xfrms. An SA may be created every time a different security
> > context is encountered in a particular traffic stream. This could be
> > many if each networking app has its own security context, making current
> > behavior problematic.
> 
> Do you have any examples of how many SAs would need to be created on a 
> typical system?
> 
No, but I have to admit, just playing around with it gives me a scary
idea. We have s0-s15 levels, each with c0-c1023 categories. Then I have
noticed, each mapped selinux user is a different context... thus just an
ssh session by a sysadm and a regular user (who is mapped to an selinux
user) can cause 8 SAs to be generated, whereas with regular ipsec, we
only need one... :-(
 
Regards,
Joy
