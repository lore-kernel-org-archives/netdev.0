From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 7 Jan 2016 05:02:25 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
References: <1450339417-31254-1-git-send-email-zyjzyj2000@gmail.com>
 <1586.1450389436@famine> <20151228084331.GA22747@unicorn.suse.cz>
 <5680FE85.60200@gmail.com>
 <87618083B2453E4A8714035B62D6799250503CE1@FMSMSX105.amr.corp.intel.com>
 <568C846E.6020304@gmail.com>
 <87618083B2453E4A8714035B62D67992505043B1@FMSMSX105.amr.corp.intel.com>
 <568DDC90.7030408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
To: zhuyj <zyjzyj2000@gmail.com>, Michal Kubecek <mkubecek@suse.cz>,
	"Jay Vosburgh" <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61062 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750707AbcAGFC2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 00:02:28 -0500
In-Reply-To: <568DDC90.7030408@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: zhuyj [mailto:zyjzyj2000@gmail.com]
>Sent: Wednesday, January 06, 2016 7:34 PM
>To: Tantilov, Emil S; Michal Kubecek; Jay Vosburgh
>Cc: vfalico@gmail.com; gospo@cumulusnetworks.com; netdev@vger.kernel.org;
>Shteinbock, Boris (Wind River)
>Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>
>On 01/07/2016 10:43 AM, Tantilov, Emil S wrote:
>>> -----Original Message-----
>>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>>> Sent: Tuesday, January 05, 2016 7:05 PM
>>> To: Tantilov, Emil S; Michal Kubecek; Jay Vosburgh
>>> Cc: vfalico@gmail.com; gospo@cumulusnetworks.com;
>netdev@vger.kernel.org;
>>> Shteinbock, Boris (Wind River)
>>> Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>>>
>>> On 01/06/2016 09:26 AM, Tantilov, Emil S wrote:
>>>>> -----Original Message-----
>>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org]
>>> On
>>>>> Behalf Of zhuyj
>>>>> Sent: Monday, December 28, 2015 1:19 AM
>>>>> To: Michal Kubecek; Jay Vosburgh
>>>>> Cc: vfalico@gmail.com; gospo@cumulusnetworks.com;
>>> netdev@vger.kernel.org;
>>>>> Shteinbock, Boris (Wind River)
>>>>> Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>>>>>
>>>>> On 12/28/2015 04:43 PM, Michal Kubecek wrote:
>>>>>> On Thu, Dec 17, 2015 at 01:57:16PM -0800, Jay Vosburgh wrote:
>>>>>>> <zyjzyj2000@gmail.com> wrote:
>>>>>>>> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>>>>>>>> there is a time span between NIC up state and getting speed and
>>> duplex.
>>>>>>>> As such, sometimes a slave in 802.3ad mode is in up state without
>>>>>>>> speed and duplex. This will make bonding in 802.3ad mode can not
>>>>>>>> work well.
>>>>>>>> To make bonding driver be compatible with more NICs, it is
>>>>>>>> necessary to restrict the up state in 802.3ad mode.
>>>>>>> 	What device is this?  It seems a bit odd that an Ethernet
>device
>>>>>>> can be carrier up but not have the duplex and speed available.
>>>>>> ...
>>>>>>> 	In general, though, bonding expects a speed or duplex change to
>>>>>>> be announced via a NETDEV_UPDATE or NETDEV_UP notifier, which would
>>>>>>> propagate to the 802.3ad logic.
>>>>>>>
>>>>>>> 	If the device here is going carrier up prior to having speed or
>>>>>>> duplex available, then maybe it should call netdev_state_change()
>when
>>>>>>> the duplex and speed are available, or delay calling
>>> netif_carrier_on().
>>>>>> I have encountered this problem (NIC having carrier on before being
>>> able
>>>>>> to detect speed/duplex and driver not notifying when speed/duplex
>>>>>> becomes available) with netxen cards earlier. But it was eventually
>>>>>> fixed in the driver by commit 9d01412ae76f ("netxen: Fix link event
>>>>>> handling.") so this example rather supports what you said.
>>>>>>
>>>>>>                                                              Michal
>>> Kubecek
>>>>> Thanks a lot.
>>>>> I checked the commit 9d01412ae76f ("netxen: Fix link event
>>>>> handling."). The symptoms are the same with mine.
>>>>>
>>>>> The root cause is different. In my problem, the root cause is that
>LINKS
>>>>> register[]  can not provide link_up and link_speed at the same time.
>>>>> There is a time span between link_up and link_speed.
>>>> The LINK_UP and LINK_SPEED bits in the LINKS register for ixgbe HW are
>>> updated
>>>> simultaneously. Do you have any proof to show the delay you are
>referring
>>> to
>>>> as I am sure our HW engineers would like to know about it.
>>> Sorry. I can not reproduce this problem locally. What I have is the
>>> feedback from the customer.
>> So you are assuming that there is a delay due to the issue you are
>seeing?
>
>Sure. Before I get the further feedback from the customer, I can not
>make further conclusion.
>My patch is based on the feedback from the customer.

Your patch is throwing an RTNL assertion warning:

RTNL: assertion failed at net/core/ethtool.c (357)

Looks like you may need to hold an RTNL lock for the slave before calling
bond_update_speed_duplex(), though I am not sure if it's a good idea in
general. 

Thanks,
Emil
