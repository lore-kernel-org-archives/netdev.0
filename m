From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Wed, 6 Jan 2016 01:26:19 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250503CE1@FMSMSX105.amr.corp.intel.com>
References: <1450339417-31254-1-git-send-email-zyjzyj2000@gmail.com>
 <1586.1450389436@famine> <20151228084331.GA22747@unicorn.suse.cz>
 <5680FE85.60200@gmail.com>
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
Received: from mga04.intel.com ([192.55.52.120]:57750 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbcAFB0V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 20:26:21 -0500
In-Reply-To: <5680FE85.60200@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of zhuyj
>Sent: Monday, December 28, 2015 1:19 AM
>To: Michal Kubecek; Jay Vosburgh
>Cc: vfalico@gmail.com; gospo@cumulusnetworks.com; netdev@vger.kernel.org;
>Shteinbock, Boris (Wind River)
>Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>
>On 12/28/2015 04:43 PM, Michal Kubecek wrote:
>> On Thu, Dec 17, 2015 at 01:57:16PM -0800, Jay Vosburgh wrote:
>>> <zyjzyj2000@gmail.com> wrote:
>>>> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>>>> there is a time span between NIC up state and getting speed and duplex.
>>>> As such, sometimes a slave in 802.3ad mode is in up state without
>>>> speed and duplex. This will make bonding in 802.3ad mode can not
>>>> work well.
>>>> To make bonding driver be compatible with more NICs, it is
>>>> necessary to restrict the up state in 802.3ad mode.
>>> 	What device is this?  It seems a bit odd that an Ethernet device
>>> can be carrier up but not have the duplex and speed available.
>> ...
>>> 	In general, though, bonding expects a speed or duplex change to
>>> be announced via a NETDEV_UPDATE or NETDEV_UP notifier, which would
>>> propagate to the 802.3ad logic.
>>>
>>> 	If the device here is going carrier up prior to having speed or
>>> duplex available, then maybe it should call netdev_state_change() when
>>> the duplex and speed are available, or delay calling netif_carrier_on().
>> I have encountered this problem (NIC having carrier on before being able
>> to detect speed/duplex and driver not notifying when speed/duplex
>> becomes available) with netxen cards earlier. But it was eventually
>> fixed in the driver by commit 9d01412ae76f ("netxen: Fix link event
>> handling.") so this example rather supports what you said.
>>
>>                                                            Michal Kubecek
>Thanks a lot.
>I checked the commit 9d01412ae76f ("netxen: Fix link event
>handling."). The symptoms are the same with mine.
>
>The root cause is different. In my problem, the root cause is that LINKS
>register[]  can not provide link_up and link_speed at the same time.
>There is a time span between link_up and link_speed.

The LINK_UP and LINK_SPEED bits in the LINKS register for ixgbe HW are updated
simultaneously. Do you have any proof to show the delay you are referring to
as I am sure our HW engineers would like to know about it.

What we have seen in the case of bonding is that with some link partners there
may be a rapid link flap (up, down, up) and as result the bonding driver may
report the speed as unknown if just so happens that the speed is checked during
the period in which the interface is re-negotiating.

Thanks,
Emil
 
>My solution is to force to synchronize link_up and link_speed in ixgbe X540 NIC.
>
>Best Regards!
>Zhu Yanjun
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
