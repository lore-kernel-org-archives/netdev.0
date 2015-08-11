From: Michael Chan <mchan@broadcom.com>
Subject: Re: Question on behavior of tg3_self_test() (ethtool -t on tg3
 driver)
Date: Tue, 11 Aug 2015 13:31:13 -0700
Message-ID: <1439325073.6488.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <55CA1BF1.2060403@linux.vnet.ibm.com>
	 <1439314863.6488.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <55CA4BE1.80904@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	<siva.kallam@broadcom.com>
To: Douglas Miller <dougmill@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:34062 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932934AbbHKUbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 16:31:14 -0400
In-Reply-To: <55CA4BE1.80904@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-11 at 14:24 -0500, Douglas Miller wrote: 
> Yes, the "wrap plugs" are the loopback cables/plugs. It is my 
> understanding that the "offline" tests do not require anything to be 
> plugged into the ports, as they do not in any way touch the "external" 
> port. They perform an "internal loopback" test which does not depend on 
> any external connection.

Correct.

> 
>  From what I can tell, the only difference between "offline" and 
> "external_lb" is that "external_lb" performs the external loopback 
> tests, *in addition to* all the tests done for "offline".

Correct.

> This would 
> imply that the only tests that depend on anything connected to the 
> physical port is "external_lb", and there is no requirement that the 
> wrap plugs be removed/replaced in order to run "offline" tests.

When you do external loopback test, we skip the link test because you no
longer have normal connection to the network.  You now use a special
loopback cable, which will fail the link up test because the link up
test assumes connection to the network using normal cable.

> 
> In the case I was debugging, wrap plugs were installed because the ports 
> were, later, being tested in an "external loopback" way.
> 
> What I am observing is that it takes about 20 seconds for the kernel to 
> declare that the link is up, after running the "offline" or 
> "external_lb" test. In the case of "offline" I cannot run the test again 
> until the kernel declares the link up. In the case of "external_lb" I 
> can run the test again immediately and it passes.

As stated earlier, because we skip the link test when we are performing
external_lb.

So, you should always do ethtool -t <dev> external_lb if you have a
loopback cable connected.  We will perform the external loopback test
and skip the link test.

If you don't have an external loopback cable connected, you should run
ethtool -t <dev> offline.  It will not do the external loopback test and
will do the link test for proper link up with the network.

> This suggests to me 
> that the "external_lb" case (again, it is a superset of "offline") is 
> performing some configuration on the port that allows the subsequent 
> test to work. The one significant difference between "offline" and 
> "external_lb" is that "external_lb" performs the
> "tg3_phy_lpbk_set(tp, 0, true);" changes to configuration (immediately 
> prior to running the loopback tests again). I believe this call is to 
> switch from "internal loopback" to "normal", in order to leverage the 
> wrap plugs and perform the external loopback tests. But this call is not 
> made for "offline" and I am wondering if that leaves the port in a state 
> where it cannot be used until the kernel completes the "link up".
> 
> 
