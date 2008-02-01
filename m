From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Fri, 1 Feb 2008 01:27:32 -0500
Message-ID: <20080201012732.232b7859.billfink@mindspring.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
	<36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>
	<Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu>
	<47A20E9E.7070503@intel.com>
	<Pine.LNX.4.63.0801311251040.14403@trinity.phys.uwm.edu>
	<47A22241.70600@intel.com>
	<Pine.LNX.4.63.0801311340270.14403@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:40390 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975AbYBAG1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 01:27:39 -0500
In-Reply-To: <Pine.LNX.4.63.0801311340270.14403@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jan 2008, Bruce Allen wrote:

> >> Based on the discussion in this thread, I am inclined to believe that
> >> lack of PCI-e bus bandwidth is NOT the issue.  The theory is that the
> >> extra packet handling associated with TCP acknowledgements are pushing
> >> the PCI-e x1 bus past its limits.  However the evidence seems to show
> >> otherwise:
> >>
> >> (1) Bill Fink has reported the same problem on a NIC with a 133 MHz
> >> 64-bit PCI connection.  That connection can transfer data at 8Gb/s.
> >
> > That was even a PCI-X connection, which is known to have extremely good latency
> > numbers, IIRC better than PCI-e? (?) which could account for a lot of the
> > latency-induced lower performance...
> >
> > also, 82573's are _not_ a serverpart and were not designed for this 
> > usage. 82546's are and that really does make a difference.
> 
> I'm confused.  It DOESN'T make a difference! Using 'server grade' 82546's 
> on a PCI-X bus, Bill Fink reports the SAME loss of throughput with TCP 
> full duplex that we see on a 'consumer grade' 82573 attached to a PCI-e x1 
> bus.
> 
> Just like us, when Bill goes from TCP to UDP, he gets wire speed back.

Good.  I thought it was just me who was confused by Auke's reply.  :-)

Yes, I get the same type of reduced TCP performance behavior on a
bidirectional test that Bruce has seen, even though I'm using the
better 82546 GigE NIC on a faster 64-bit/133-MHz PCI-X bus.  I also
don't think bus bandwidth is an issue, but I am curious if there
are any known papers on typical PCI-X/PCI-E bus overhead on network
transfers, either bulk data transfers with large packets or more
transaction or video based applications using smaller packets.

I started musing if once one side's transmitter got the upper hand,
it might somehow defer the processing of received packets, causing
the resultant ACKs to be delayed and thus further slowing down the
other end's transmitter.  I began to wonder if the txqueuelen could
have an affect on the TCP performance behavior.  I normally have
the txqueuelen set to 10000 for 10-GigE testing, so decided to run
a test with txqueuelen set to 200 (actually settled on this value
through some experimentation).  Here is a typical result:

[bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -w2m 192.168.6.79
tx:  1120.6345 MB /  10.07 sec =  933.4042 Mbps 12 %TX 9 %RX 0 retrans
rx:  1104.3081 MB /  10.09 sec =  917.7365 Mbps 12 %TX 11 %RX 0 retrans

This is significantly better, but there was more variability in the
results.  The above was with TSO enabled.  I also then ran a test
with TSO disabled, with the following typical result:

[bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -w2m 192.168.6.79
tx:  1119.4749 MB /  10.05 sec =  934.2922 Mbps 13 %TX 9 %RX 0 retrans
rx:  1131.7334 MB /  10.05 sec =  944.8437 Mbps 15 %TX 12 %RX 0 retrans

This was a little better yet and getting closer to expected results.

Jesse Brandeburg mentioned in another post that there were known
performance issues with the version of the e1000 driver I'm using.
I recognized that the kernel/driver versions I was using were rather
old, but it was what I had available to do a quick test with.  Those
particular systems are in a remote location so I have to be careful
with messing with their network drivers.  I do have some other test
systems at work that I might be able to try with newer kernels
and/or drivers or maybe even with other vendor's GigE NICs, but
I won't be back to work until early next week sometime.

						-Bill
