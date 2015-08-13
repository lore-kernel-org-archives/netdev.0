From: "Siva Reddy (Siva) Kallam" <siva.kallam@broadcom.com>
Subject: Re: Question on behavior of tg3_self_test() (ethtool -t on tg3 driver)
Date: Thu, 13 Aug 2015 14:10:53 +0530
Message-ID: <55CC5815.90005@broadcom.com>
References: <55CA1BF1.2060403@linux.vnet.ibm.com> <1439314863.6488.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <55CA4BE1.80904@linux.vnet.ibm.com> <1439325073.6488.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <55CB3CD8.1030300@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>
To: Douglas Miller <dougmill@linux.vnet.ibm.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:59964 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbbHMIk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 04:40:56 -0400
In-Reply-To: <55CB3CD8.1030300@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/12/2015 6:02 PM, Douglas Miller wrote:
> Oh, I had missed the extra "if" condition on tg3_test_link(). So 
> "external_lb" is not a true superset of "offline".
>
> So you are not surprised by the (about) 20 second "link down" period 
> after this test? If this is expected (albeit undocumented) behavior we 
> can change the test scenario to work around it. It seems as though not 
> all adapters exhibit this same symptom. From a testing standpoint, it 
> is a long delay to add that may only be needed for this one adapter 
> (Broadcom BCM5719, or adapter family).
>
We executed the "ethtool -t <dev> offline" in a loop on our local test 
machine with 5719 and linkup time is <= 5 secs.

Script:
#!/bin/bash
echo "---------OS Information---------"
uname -a
echo "----------Card Information----------"
lspci | grep 5719
echo "----------Interface information------"
ethtool -i p4p4
echo "---------Offline test start----------"
for i in 1 2 3
do
     date
     ethtool -t p4p4 offline
done

Output:

---------OS Information---------
Linux siva-dev 4.2.0-rc4+ #1 SMP Thu Aug 13 20:24:11 IST 2015 x86_64 
x86_64 x86_64 GNU/Linux
----------Card Information----------
03:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5719 
Gigabit Ethernet PCIe (rev 01)
03:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5719 
Gigabit Ethernet PCIe (rev 01)
03:00.2 Ethernet controller: Broadcom Corporation NetXtreme BCM5719 
Gigabit Ethernet PCIe (rev 01)
03:00.3 Ethernet controller: Broadcom Corporation NetXtreme BCM5719 
Gigabit Ethernet PCIe (rev 01)
----------Interface information------
driver: tg3
version: 3.137
firmware-version: 5719-v1.41 NCSI v1.3.6.0
bus-info: 0000:03:00.3
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
---------Offline test start----------
Thu Aug 13 22:05:59 IST 2015
The test result is PASS
The test extra info:
nvram test        (online)      0
link test         (online)      0
register test     (offline)     0
memory test       (offline)     0
mac loopback test (offline)     0
phy loopback test (offline)     0
ext loopback test (offline)     0
interrupt test    (offline)     0

Thu Aug 13 22:06:00 IST 2015
The test result is PASS
The test extra info:
nvram test        (online)      0
link test         (online)      0
register test     (offline)     0
memory test       (offline)     0
mac loopback test (offline)     0
phy loopback test (offline)     0
ext loopback test (offline)     0
interrupt test    (offline)     0

Thu Aug 13 22:06:05 IST 2015
The test result is PASS
The test extra info:
nvram test        (online)      0
link test         (online)      0
register test     (offline)     0
memory test       (offline)     0
mac loopback test (offline)     0
phy loopback test (offline)     0
ext loopback test (offline)     0
interrupt test    (offline)     0

Please check your test environment.

> Thanks,
> Doug
>
> On 08/11/2015 03:31 PM, Michael Chan wrote:
>> On Tue, 2015-08-11 at 14:24 -0500, Douglas Miller wrote:
>>> Yes, the "wrap plugs" are the loopback cables/plugs. It is my
>>> understanding that the "offline" tests do not require anything to be
>>> plugged into the ports, as they do not in any way touch the "external"
>>> port. They perform an "internal loopback" test which does not depend on
>>> any external connection.
>> Correct.
>>
>>>   From what I can tell, the only difference between "offline" and
>>> "external_lb" is that "external_lb" performs the external loopback
>>> tests, *in addition to* all the tests done for "offline".
>> Correct.
>>
>>> This would
>>> imply that the only tests that depend on anything connected to the
>>> physical port is "external_lb", and there is no requirement that the
>>> wrap plugs be removed/replaced in order to run "offline" tests.
>> When you do external loopback test, we skip the link test because you no
>> longer have normal connection to the network.  You now use a special
>> loopback cable, which will fail the link up test because the link up
>> test assumes connection to the network using normal cable.
>>
>>> In the case I was debugging, wrap plugs were installed because the 
>>> ports
>>> were, later, being tested in an "external loopback" way.
>>>
>>> What I am observing is that it takes about 20 seconds for the kernel to
>>> declare that the link is up, after running the "offline" or
>>> "external_lb" test. In the case of "offline" I cannot run the test 
>>> again
>>> until the kernel declares the link up. In the case of "external_lb" I
>>> can run the test again immediately and it passes.
>> As stated earlier, because we skip the link test when we are performing
>> external_lb.
>>
>> So, you should always do ethtool -t <dev> external_lb if you have a
>> loopback cable connected.  We will perform the external loopback test
>> and skip the link test.
>>
>> If you don't have an external loopback cable connected, you should run
>> ethtool -t <dev> offline.  It will not do the external loopback test and
>> will do the link test for proper link up with the network.
>>
>>> This suggests to me
>>> that the "external_lb" case (again, it is a superset of "offline") is
>>> performing some configuration on the port that allows the subsequent
>>> test to work. The one significant difference between "offline" and
>>> "external_lb" is that "external_lb" performs the
>>> "tg3_phy_lpbk_set(tp, 0, true);" changes to configuration (immediately
>>> prior to running the loopback tests again). I believe this call is to
>>> switch from "internal loopback" to "normal", in order to leverage the
>>> wrap plugs and perform the external loopback tests. But this call is 
>>> not
>>> made for "offline" and I am wondering if that leaves the port in a 
>>> state
>>> where it cannot be used until the kernel completes the "link up".
>>>
>>>
>
