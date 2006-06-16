From: Stefan Rompf <stefan@loplof.de>
Subject: Re: Suspending 802.11 drivers
Date: Fri, 16 Jun 2006 20:36:26 +0200
Message-ID: <200606162036.26518.stefan@loplof.de>
References: <200606152158.10079.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from natlemon.rzone.de ([81.169.145.170]:54971 "EHLO
	natlemon.rzone.de") by vger.kernel.org with ESMTP id S1751338AbWFPSfu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 14:35:50 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606152158.10079.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag 15 Juni 2006 21:58 schrieb Michael Buesch:

> I am currently thinking about the best way to correctly
> implement PM suspending for wireless drivers.
> Currently, the 802.11 stack is not suspend aware (if I talk
> about "stack" here, I mostly mean devicescape).
> For example, if we suspend the bcm43xx driver, we don't
> notify the stack before doing so. That's a bug.

I think the most important question is how a suspend/resume action should be 
translated. For the managed case, it is clearly an association loss, normally 
signalled by netif_carrier_on/off() and a corresponding SIOCGIWAP event. 
Supplicants can act on this. In AP mode, suspend is equal to disassociating 
all stations. Ad-hoc... dunno.

For a softmac stack like devicescape, it makes sense to have a function that 
abstracts these scenarios as it is the stack anyway that handles association 
stuff. However, I'd rather extend the existing function 
ieee80211_netif_oper().

> The suspend would save all status information, for example
> to which AP we are associated and so on. After that it would
> cleanly disassociate from the AP and do other cleanups which
> are needed.

It would *try* to cleanly disassociate. No way waiting for the management 
packet to reach the air or even for the AP's acknowledgement while half of 
userspace is already frozen and the user wants the machine to go down ASAP. 
(But that's an interesting point. Will sniff whether ipw2200 hardware sends a 
final packet on suspend.)

> The resume function would try to re-esablish the connection.

Don't keep too much state - just notify userspace of the disassociation, then 
scan and reassociate using the given iwconfig parameters or the running 
supplicant as it would happen on a normal association loss. ipw2200 acts like 
this, and it is definitely fast enough.

Stefan
