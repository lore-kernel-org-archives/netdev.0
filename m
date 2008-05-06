From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Detected Tx Unit Hang in ixgbe, kernel 2.6.25
Date: Tue, 6 May 2008 13:42:20 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52051AB2FF@orsmsx418.amr.corp.intel.com>
References: <48208F9D.1080608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>
To: "Ben Greear" <greearb@candelatech.com>,
	"NetDev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6507 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755461AbYEFUmW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:42:22 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48208F9D.1080608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> I'm using a 10Gbps copper(CX4) dual-port NIC from silicomusa.com.
> It uses the Intel chipset and ixgbe driver.  I'm using
> kernel 2.6.25 plus some hacks (no patches to ixgbe).
> 
> This particular test case was to create 500 mac-vlans on
> each of the two ports and generate UDP traffic between
> them (I have a version of the send-to-self patch applied
> to my kernel and enabled.)
> 
> During the setup for this test, the interfaces would have
> been bounced (effectively ifdown, ifup), so that is the
> reason for the link going up and down.
> 
> I noticed 90%+ drop rate when I first started the test,
> and then after maybe 1-2 minutes, things calmed down and
> started working.  I checked /var/log/messages and saw the
> messages below.

do you have ipv6 enabled?  I've seen this behavior that if a port is
flooded before the events/X thread finishes, lots of packets get dropped
and the events/X thread takes a long time to complete.  Not sure if it
is related.
 
> I previously ran 5Gbps of traffic through the two ports
> with them acting like a bridge for more than 24-hours without
> any obvious problems, so I think the hardware is probably OK.
> 
> May  6 09:51:41 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang:
> Detected Tx Unit Hang 
> May  6 09:51:41 simech-ice kernel:   TDH                  <1e>
> May  6 09:51:41 simech-ice kernel:   TDT                  <3ff>
> May  6 09:51:46 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang:
> Detected Tx Unit Hang 
> May  6 09:51:46 simech-ice kernel:   TDH                  <28d>
> May  6 09:51:46 simech-ice kernel:   TDT                  <26c>
> May  6 09:51:47 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang:
> Detected Tx Unit Hang 
> May  6 09:51:47 simech-ice kernel:   TDH                  <33f>
> May  6 09:51:47 simech-ice kernel:   TDT                  <321>

hm, snipped above to demonstrate my point.  These appear to be false
hangs.  TDH is still moving (indicating the hardware is still processing
packets.)  Do you have flow control enabled?  Can you try with fewer
descriptors?  It is truly unlikely you need more than 512, usually.

The driver (incorrectly, will patch soon) defaults to flow control
enabled.  I suggest you disable it with ethtool -A

You might be able to just comment out the detect_tx_hung variable being
set, see if the problem goes away (false hang for sure then)

Jesse

