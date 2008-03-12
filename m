From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: new PPP code for generic HDLC
Date: Wed, 12 Mar 2008 19:21:55 +0100
Message-ID: <m3prtzsszg.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:41553 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbYCLSWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 14:22:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'll follow up with a patch for generic HDLC PPP code.

Current status of generic HDLC is:
- up to 2.6.22 - working.
- 2.6.23.* and 2.6.24.* - Frame Relay and PPP protocols panic instantly,
  breakage caused by a change to netdev code that I overlooked.
- 2.6.25-git - Frame Relay is already fixed, PPP still panics.

The fix to FR was simple (983e23041b28abb113862b2935a85cfb9aab4f5a).

PPP has been using syncppp.c implementation for years, meaning working
as a mid-layer between hardware drivers and syncppp. This situation is
increasingly hard to maintain, and I've decided to write a dedicated
PPP implementation for generic HDLC.

Rationale:
- syncppp assumes no mid-layer between itself and hw drivers - dirty
  hacks must be used to work around this
- syncppp doesn't even try to implement PPP correctly, it looks like
  it was written to work with another specific implementation and then
  left in this state for *teen years
- every protocol (LCP and IPCP) uses different state machine code.
- lack of IPv6 support and adding it is non-trivial.
- I've considered using the generic PPP stack, however it's oriented
  towards async tty and requires the pppd daemon - I guess code to
  interface to it would be more complicated than the new PPP code.

The PPP state machine is distributed over many functions and this is
extremely hard to maintain or even understand. No wonder it's not very
standard-compliant.

Instead my new implementation has:
- a single state machine code for all control protocols (LCP, IPCP,
  IPV6CP, and whatever is needed)
- it's modelled after STD-51
- even more minimalistic than syncppp (no "magic number"), though
  adding optional support (if needed) is simple.
- can actually be maintained.

I have positively tested it on i686 and big-endian ARM, against itself
and against syncppp.c. I can't test it against any other device due to
-ENOHW, so I expect some bugs/problems in/with this code, though I hope
it's better than the current brokenness.

I guess it should go into 2.6.25, not sure about "stable" series.
I will appreciate any feedback, review and/or test results.
-- 
Krzysztof Halasa
