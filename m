From: "Templeman, Chaim" <chaim.templeman@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] e1000e: Cleanup handling of VLAN_HLEN
 as a part of max frame size
Date: Thu, 9 Apr 2015 06:17:47 +0000
Message-ID: <BD4006F19E8FC247A4760EC0EE12CCDF468ACD40@HASMSX110.ger.corp.intel.com>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org>
 <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22>
 <alpine.NEB.2.11.1504081413510.3388@chris.i8u.org>
 <5525B2AE.80301@gmail.com>
 <alpine.NEB.2.11.1504081602260.3388@chris.i8u.org>
 <5525B62A.1050601@gmail.com>
 <alpine.NEB.2.11.1504081705350.3388@chris.i8u.org>
 <alpine.NEB.2.11.1504081714400.3388@chris.i8u.org>
 <5525D389.3010700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mike@cchtml.com" <mike@cchtml.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Ertman, David M" <david.m.ertman@intel.com>,
	"Lubetkin, YanirX" <yanirx.lubetkin@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Hisashi T Fujinaka <htodd@twofifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1973 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbbDIGRv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 02:17:51 -0400
In-Reply-To: <5525D389.3010700@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will look into this with the HW architect and get back to you on what the HW limitations actually are on this issue.

-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Thursday, April 09, 2015 04:19
To: Hisashi T Fujinaka
Cc: netdev@vger.kernel.org; mike@cchtml.com; intel-wired-lan@lists.osuosl.org; Ertman, David M
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: Cleanup handling of VLAN_HLEN as a part of max frame size

On 04/08/2015 05:26 PM, Hisashi T Fujinaka wrote:
> On Wed, 8 Apr 2015, Hisashi T Fujinaka wrote:
>
>> On Wed, 8 Apr 2015, Alexander Duyck wrote:
>>>
>>> It is but it isn't.  If you look in e1000_change_mtu you will find the
>>> node about "Jumbo frame workaround on 82579 and newer requires CRC be
>>> stripped".  With that being the case I'm wondering if the 9018 doesn't
>>> include CRC but instead includes VLAN header.  So as a result the
>>> actual
>>> hardware is processing frames that are 9022 in size, but the buffer
>>> only
>>> ever receives at most 9018 since the CRC is stripped.
>>>
>>> I suspect that is why the Windows driver has had no issues reporting
>>> support for a size of 9014 (excluding VLAN and CRC) on these parts and
>>> hasn't had any issues.
>>
>> I can only tell you what was told to me by Dave Ertman, which is that
>> there is a hard hardware limit of 9018 bytes. I wouldn't know if we do
>> have Windows issues because it's a completely different division and
>> there's no reason for any of those issues to be routed to us.
>>
>> In fact, the problem with different max MTU across the drivers in Linux
>> has only ever been reported by one user.
>>
>> I'm still looking for the HW documentation and would like Jeff to hold
>> off until we find it.
>
> OK. So the data sheet states:
>
> LPE controls whether long packet reception is permitted. Hardware
> discards long packets if LPE is 0. A long packet is one longer than 1522
> bytes. If LPE is 1, the maximum packet size that the device can receive
> is 9018 bytes.

Yeah, that is mostly clear except it doesn't indicate if that includes
or excludes the CRC and/or VLAN header.  All the documentation I can
find seems to indicate it is likely skipping one or the other since it
recommends setting any switches to support 9022 in order to account for
both.

> So if you're pre-stripping the CRC, then it will be less than 9018.

Right so the argument is probably moot since you cannot enable jumbo
frames unless CRC stripping is enabled.  Ugh, but it looks like nothing
prevents disabling CRC stripping once jumbo frames has been enabled. 
I'll patch that shortly.

> I guess I'd like to hear what Dave thinks.

The problem is this pre-dates when Dave Ertman started working on
e1000e.  All of this went into effect back during the introduction of
82579 and i217/i218 and the two patches from Bruce that reduced the size
down to 9018 didn't specify where the number came from.  I suspect it is
the same data sheet we have been looking at which is a bit vague about
what is included in that size.
_______________________________________________
Intel-wired-lan mailing list
Intel-wired-lan@lists.osuosl.org
http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
