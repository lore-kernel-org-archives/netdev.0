From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: Re: Question on behavior of tg3_self_test() (ethtool -t on tg3 driver)
Date: Tue, 11 Aug 2015 14:24:17 -0500
Message-ID: <55CA4BE1.80904@linux.vnet.ibm.com>
References: <55CA1BF1.2060403@linux.vnet.ibm.com> <1439314863.6488.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Prashant Sreedharan <prashant@broadcom.com>,
	siva.kallam@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:59323 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932312AbbHKTYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 15:24:21 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Tue, 11 Aug 2015 13:24:21 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D868A3E4004E
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 13:24:18 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7BJNMgG48496716
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 12:23:22 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7BJOINP012186
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 13:24:18 -0600
In-Reply-To: <1439314863.6488.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Michael for getting back to me.

Yes, the "wrap plugs" are the loopback cables/plugs. It is my 
understanding that the "offline" tests do not require anything to be 
plugged into the ports, as they do not in any way touch the "external" 
port. They perform an "internal loopback" test which does not depend on 
any external connection.

 From what I can tell, the only difference between "offline" and 
"external_lb" is that "external_lb" performs the external loopback 
tests, *in addition to* all the tests done for "offline". This would 
imply that the only tests that depend on anything connected to the 
physical port is "external_lb", and there is no requirement that the 
wrap plugs be removed/replaced in order to run "offline" tests.

In the case I was debugging, wrap plugs were installed because the ports 
were, later, being tested in an "external loopback" way.

What I am observing is that it takes about 20 seconds for the kernel to 
declare that the link is up, after running the "offline" or 
"external_lb" test. In the case of "offline" I cannot run the test again 
until the kernel declares the link up. In the case of "external_lb" I 
can run the test again immediately and it passes. This suggests to me 
that the "external_lb" case (again, it is a superset of "offline") is 
performing some configuration on the port that allows the subsequent 
test to work. The one significant difference between "offline" and 
"external_lb" is that "external_lb" performs the
"tg3_phy_lpbk_set(tp, 0, true);" changes to configuration (immediately 
prior to running the loopback tests again). I believe this call is to 
switch from "internal loopback" to "normal", in order to leverage the 
wrap plugs and perform the external loopback tests. But this call is not 
made for "offline" and I am wondering if that leaves the port in a state 
where it cannot be used until the kernel completes the "link up".

Thanks,
Doug



On 08/11/2015 12:41 PM, Michael Chan wrote:
> On Tue, 2015-08-11 at 10:59 -0500, Douglas Miller wrote:
>> (Sorry if you got several duplicates, am trying to work through rejected
>> messages due to supposed HTML content)
>>
>> The following behavior is being observed when running "ethtool -t <dev>
>> offline" on ports on the Broadcom BCM5719 adapter (tg3 driver). The
>> ports have wrap plugs on them, although I'm not sure why that would have
>> any affect.
> I'm not sure what are wrap plugs.
>
>> The test "ethtool -t <dev> offline" was being running continuously. The
>> first invocation passes, all subsequent ones fail (at least in the "link
>> test" step) after ~20 second timeout. When running the test once, I see
>> the following: Looking at /var/log/messages, I see a "Link is down"
>> message during the test. Then, 20 seconds after the test completes,
>> there is a "Link is up..." message. If I wait for the "Link is up..."
>> message I can run the test without problems. If the test is run again
>> while the link is still down, it fails and seems to delay the "link up"
>> by an additional 20 seconds.
> When you do offline test, the chip is reset and the PHY is also reset,
> causing the link to go down.  Normally, link should come back up within
> a few seconds.  The selftest code will wait for 6 seconds for copper and
> 2 seconds for serdes link to be up before declaring there is no link.
>
> So for whaever reason, the link in your setup takes longer than that to
> come up and therefore it fails the link test when you run it in a loop
> starting on the 2nd iteration.
>
>
>> If I run "external_lb" instead of "offline", I am able to run the test
>> repeatedly without error. So it seems that some action taken in the
>> "external_lb" case actually "repairs" the port. But the "external_lb"
>> test also exhibits the link-down for 20 seconds symptom, although it can
>> been run while the link is considered "down" without failure.
> External loopback requires a loopback cable.  So you must have a
> loopback cable for this test to pass.  May be that's what you meant by
> wrap plugs.
>
>> The first question is whether we should expect to be able to run
>> "ethtool -t <dev> offline" continually, with no delay between runs. I
>> presume this is supported.
> If your intention is to run external loopback, yes you should specify
> external loopback.  Otherwise the driver expects normal link behavior
> and that's why it fails.
>
> If you connect a normal cable, then ethtool -t <dev> offline works
> repeatedly, right?
>
>> Second question, I would like someone with experience with the tg3
>> driver and this adapter to comment on what might be done to fix this. My
>> first, simple, guess would be move the "tg3_phy_lpbk_set(tp, 0, true);"
>> setting (in tg3_test_loopback()) to be done for both "offline" and
>> "external_lb" cases. I am awaiting time on a system with this adapter in
>> order to try out some possible fixes and/or debug what might be
>> wrong/different with the configuration after the "offline" test.
>>
>> I would appreciate any help,
>> Thanks,
>> Doug Miller
>>
>
