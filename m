From: Michael Chan <mchan@broadcom.com>
Subject: Re: Question on behavior of tg3_self_test() (ethtool -t on tg3
 driver)
Date: Tue, 11 Aug 2015 10:41:03 -0700
Message-ID: <1439314863.6488.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <55CA1BF1.2060403@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	<siva.kallam@broadcom.com>
To: Douglas Miller <dougmill@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:18600 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbHKRlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 13:41:07 -0400
In-Reply-To: <55CA1BF1.2060403@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-11 at 10:59 -0500, Douglas Miller wrote: 
> (Sorry if you got several duplicates, am trying to work through rejected 
> messages due to supposed HTML content)
> 
> The following behavior is being observed when running "ethtool -t <dev> 
> offline" on ports on the Broadcom BCM5719 adapter (tg3 driver). The 
> ports have wrap plugs on them, although I'm not sure why that would have 
> any affect.

I'm not sure what are wrap plugs.

> 
> The test "ethtool -t <dev> offline" was being running continuously. The 
> first invocation passes, all subsequent ones fail (at least in the "link 
> test" step) after ~20 second timeout. When running the test once, I see 
> the following: Looking at /var/log/messages, I see a "Link is down" 
> message during the test. Then, 20 seconds after the test completes, 
> there is a "Link is up..." message. If I wait for the "Link is up..." 
> message I can run the test without problems. If the test is run again 
> while the link is still down, it fails and seems to delay the "link up" 
> by an additional 20 seconds.

When you do offline test, the chip is reset and the PHY is also reset,
causing the link to go down.  Normally, link should come back up within
a few seconds.  The selftest code will wait for 6 seconds for copper and
2 seconds for serdes link to be up before declaring there is no link.

So for whaever reason, the link in your setup takes longer than that to
come up and therefore it fails the link test when you run it in a loop
starting on the 2nd iteration.


> If I run "external_lb" instead of "offline", I am able to run the test 
> repeatedly without error. So it seems that some action taken in the 
> "external_lb" case actually "repairs" the port. But the "external_lb" 
> test also exhibits the link-down for 20 seconds symptom, although it can 
> been run while the link is considered "down" without failure.

External loopback requires a loopback cable.  So you must have a
loopback cable for this test to pass.  May be that's what you meant by
wrap plugs.

> 
> The first question is whether we should expect to be able to run 
> "ethtool -t <dev> offline" continually, with no delay between runs. I 
> presume this is supported.

If your intention is to run external loopback, yes you should specify
external loopback.  Otherwise the driver expects normal link behavior
and that's why it fails.

If you connect a normal cable, then ethtool -t <dev> offline works
repeatedly, right?

> 
> Second question, I would like someone with experience with the tg3 
> driver and this adapter to comment on what might be done to fix this. My 
> first, simple, guess would be move the "tg3_phy_lpbk_set(tp, 0, true);" 
> setting (in tg3_test_loopback()) to be done for both "offline" and 
> "external_lb" cases. I am awaiting time on a system with this adapter in 
> order to try out some possible fixes and/or debug what might be 
> wrong/different with the configuration after the "offline" test.
> 
> I would appreciate any help,
> Thanks,
> Doug Miller
> 
