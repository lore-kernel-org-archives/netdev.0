From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: double SAs are created when using AH and ESP together
Date: Fri, 09 Mar 2007 19:52:06 -0600
Message-ID: <1173491527.3085.126.camel@faith.austin.ibm.com>
References: <200703092314.l29NEsre023870@faith.austin.ibm.com>
	 <20070309.162027.38709797.davem@davemloft.net>
	 <1173488055.16821.50.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	jmorris@namei.org, paul.moore@hp.com, vyekkirala@TrustedCS.com
To: davem@davemloft.net, Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36821 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767722AbXCJCIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 21:08:11 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2A26ofJ007618
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 21:06:50 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2A28B6M156618
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 19:08:11 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2A28Au2012508
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 19:08:11 -0700
In-Reply-To: <1173488055.16821.50.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-09 at 19:54 -0500, Eric Paris wrote:
> On Fri, 2007-03-09 at 16:20 -0800, David Miller wrote:
> > From: Joy Latten <latten@austin.ibm.com>
> > Date: Fri, 9 Mar 2007 17:14:54 -0600
> > 
> > > I noticed that in xfrm_state_add we look for the larval SA in a few
> > > places without checking for protocol match. So when using both 
> > > AH and ESP, whichever one gets added first, deletes the larval SA. 
> > > It seems AH always gets added first and ESP is always the larval 
> > > SA's protocol since the xfrm->tmpl has it first. Thus causing the
> > > additional km_query()
> > > 
> > > Adding the check eliminates the double SA creation. 
> > > I know this may not seem like a complete solution and I will 
> > > continue to test and be on the lookout, but isn't having the
> > > check a good thing? So far I have tested SAs with just ESP, just AH
> > > and with both and all seems ok. 
> > > 
> > > Please let me know if this patch is ok. 
> > > My kernel was 2.6.20-rc3-git3.
> > > 
> > > Signed-off-by: Joy Latten <latten@austin.ibm.com>
> > 
> > Generally it looks OK, but I'm going to let this one sit for
> > a while before I apply it so that other folks can review it
> > too and spot any unintended consequences.
> > 
> > In particular, I find it strance that we didn't check the
> > protocol field all this time and I wonder whether that might
> > be on purpose for some reason.
> 
> At least the first hunk of this patch used to be checked back in
> net/ipv4/xfrm4_state.c in __xfrm4_find_acq and looks like it just was
> accidentally forgotten when there was a transition to using
> __find_acq_core
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=2770834c9f44afd1bfa13914c7285470775af657
> 
> Since Joy found this problem on a 2.6.18 kernel originally which was
> before this diff and had the proto check I'm guessing it is actually the
> second hunk which is more relevant to the problem.
> 
> -Eric

Don't mean to be a killjoy on a friday evening, but I just saw something
else that I recall seeing a while back but forgot and so want to report
now.

While initiator is establishing SAs, the responder sends an ACQUIRE.
I once got 3 sets of SAs. Now I only got 2 this time with above patch.
This occurs when I start netperf to send streams of tcp and udp packets
to test. This doesn't always happen. Just once in a while it seems...
like a packet escaped and reached remote...  (this is from lspp kernel)

Initiator's log file:

Mar  9 19:43:51 racoon: INFO: ISAKMP-SA established
9.3.192.210[500]-9.3.189.55[500] spi:dcdf529f9e7e1c7b:87400b8505e2f2aa
Mar  9 19:43:52 racoon: INFO: initiate new phase 2 negotiation:
9.3.192.210[500]<=>9.3.189.55[500]
Mar  9 19:43:53 racoon: INFO: IPsec-SA established: AH/Transport
9.3.189.55[0]->9.3.192.210[0] spi=193987518(0xb9003be)
Mar  9 19:43:53 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.189.55[0]->9.3.192.210[0] spi=137973961(0x83950c9)
Mar  9 19:43:53 racoon: INFO: IPsec-SA established: AH/Transport
9.3.192.210[0]->9.3.189.55[0] spi=248476422(0xecf7306)
Mar  9 19:43:53 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.192.210[0]->9.3.189.55[0] spi=263395735(0xfb31997)
Mar  9 19:43:53 racoon: INFO: respond new phase 2 negotiation:
9.3.192.210[500]<=>9.3.189.55[500]
Mar  9 19:43:55 racoon: INFO: IPsec-SA established: AH/Transport
9.3.189.55[0]->9.3.192.210[0] spi=37664464(0x23eb6d0)
Mar  9 19:43:55 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.189.55[0]->9.3.192.210[0] spi=246992333(0xeb8cdcd)
Mar  9 19:43:55 racoon: INFO: IPsec-SA established: AH/Transport
9.3.192.210[0]->9.3.189.55[0] spi=203651374(0xc23792e)
Mar  9 19:43:55 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.192.210[0]->9.3.189.55[0] spi=48093292(0x2ddd86c)

----------------------------------------------------------------------------------

Responder's log file:


Mar  9 19:43:10 racoon: INFO: respond new phase 2 negotiation:
9.3.189.55[500]<=>9.3.192.210[500]
Mar  9 19:43:11 racoon: INFO: IPsec-SA established: AH/Transport
9.3.192.210[0]->9.3.189.55[0] spi=248476422(0xecf7306)
Mar  9 19:43:11 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.192.210[0]->9.3.189.55[0] spi=263395735(0xfb31997)
Mar  9 19:43:11 racoon: INFO: IPsec-SA established: AH/Transport
9.3.189.55[0]->9.3.192.210[0] spi=193987518(0xb9003be)
Mar  9 19:43:11 racoon: INFO: security context doi: 1
Mar  9 19:43:11 racoon: INFO: security context algorithm: 1
Mar  9 19:43:11 racoon: INFO: security context length: 39
Mar  9 19:43:11 racoon: INFO: security context:
root:sysadm_r:sysadm_t:s0-s15:c0.c1023
Mar  9 19:43:11 racoon: INFO: initiate new phase 2 negotiation:
9.3.189.55[500]<=>9.3.192.210[500]
Mar  9 19:43:11 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.189.55[0]->9.3.192.210[0] spi=137973961(0x83950c9)
Mar  9 19:43:12 racoon: INFO: IPsec-SA established: AH/Transport
9.3.192.210[0]->9.3.189.55[0] spi=203651374(0xc23792e)
Mar  9 19:43:12 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.192.210[0]->9.3.189.55[0] spi=48093292(0x2ddd86c)
Mar  9 19:43:12 racoon: INFO: IPsec-SA established: AH/Transport
9.3.189.55[0]->9.3.192.210[0] spi=37664464(0x23eb6d0)
Mar  9 19:43:12 racoon: INFO: IPsec-SA established: ESP/Transport
9.3.189.55[0]->9.3.192.210[0] spi=246992333(0xeb8cdcd)



Joy
  

