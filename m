From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 10 May 2007 11:22:17 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902D10DA3@orsmsx414.amr.corp.intel.com>
References: <1178666902.4055.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Zhu, Yi" <yi.zhu@intel.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Patrick McHardy" <kaber@trash.net>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>, "cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9926 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbXEJSWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 14:22:20 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178666902.4055.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Wireless offers a strict priority scheduler with statistical 
> transmit (as opposed to deterministic offered by the linux 
> strict prio qdisc); so wireless is not in the same boat as DCE.

Again, you're comparing these patches with DCE, which is not the intent.
It's something I presented that can use these patches, not as a
justification for them.

> Once you run the ATA over ethernet with your approach, please 
> repeat the test with a single ring in hardware and an 
> equivalent qdisc in linux.
> I dont believe you will see any difference - Linux is that good.
> This is not to say i am against your patches, I am just for 
> optimizing for the common.

I ran some tests on a 1gig network (isolated) using 2 hardware queues,
streaming video on one and having everything else on the other queue.
After the buffered video is sent and the request for more video is made,
I see a slowdown with a single queue.  I see a difference using these
patches to mitigate the impact to the different flows; Linux may be good
at scheduling, but that doesn't help when hardware is being pushed to
its limit - this was running full line-rate constantly (uncompressed mpg
for video and standard iperf settings for LAN traffic).

I almost ran some tests where I resize the Tx rings to give more buffer
for the streaming video (or ATA over Ethernet, in my previous example),
and less for the LAN traffic.  I can see people who want to ensure more
resources for latency-sensitive traffic doing this, and it would
certainly show a more significant impact without the queue visibility in
the kernel.  I did not run these tests though, since unmodified ring
sizes showed that with my patches, I have less impact to my more
demanding flow than with a single ring and the same qdisc.  I suggest
you actually try it and see.

So I have run these tests at 1gig with a 2-core and 4-core system.  I'd
argue this is optimizing for the common, since I used streaming video in
my test, whereas someone else can use ATA over Ethernet, ndb, or VoIP,
and still benefit this way.  Please provide a counter-argument or data
showing this is not the case.

> You dont believe Linux has actually been doing QoS all these 
> years before DCE? It has. And we have been separating flows 
> all those years too. 

Indeed it has been.  But the hardware is now getting fast enough and
feature rich enough that the stack needs to mature and use the extra
queues.  Having multiple queues in software, multiple queues in
hardware, and a one-lane tunnel to get between them is not right in my
opinion.  It's like taking a 2-lane highway and putting a 1-lane tunnel
in the middle of it; when traffic gets heavy, everyone is affected,
which is wrong.  That's why they put those neat diamond lanes on
highways.  :)

> Wireless with CSMA/CA is a slightly different beast due to 
> the shared channels; its worse but not very different in 
> nature than the case where you have a shared ethernet hub 
> (CSMA/CD) and you keep adding hosts to it
> - we dont ask the qdiscs to backoff because we have a collision.
> Where i find wireless intriguing is in the case where its 
> available bandwidth adjusts given the signal strength - but 
> you are talking about HOLs not that specific phenomena.

You keep referring to doing things for the "common," but you're giving
specific wireless-based examples with specific packet scheduling
configurations.  I've given 3 scenarios of fairly different traffic
configurations where these patches will help.  Yi Zhu has also replied
that he sees wireless benefiting from these patches, but if you don't
believe that's the case, it's something you guys can hash out.

Thanks,

-PJ
