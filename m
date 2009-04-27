From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Mon, 27 Apr 2009 16:55:58 -0700
Message-ID: <13072.1240876558@death.nxdomain.ibm.com>
References: <49F1DE6F.1030606@trash.net> <49F1EB2F.1050505@candelatech.com> <30658.1240619463@death.nxdomain.ibm.com> <49F4BCEB.6040507@candelatech.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:41857 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbZD0Xzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 19:55:54 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3RNrMXa016561
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 17:53:22 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3RNtssL088484
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 17:55:54 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3RNtrTu007024
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 17:55:53 -0600
In-reply-to: <49F4BCEB.6040507@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> wrote:

>Jay Vosburgh wrote:
>>> If so, I think that is not a good idea and could possibly be considered
>>> a security issue.  I think instead there should be a new flag for VLANs
>>> that is 'preferred-admin-state'.  To be UP, both the underlying device
>>> and the preferred state must be UP.  That should allow bouncing eth0
>>> w/out affecting the eventual admin state of the VLANs on eth0 in
>>> the example above.
>>>     
>>
>> 	I dunno if it's a security issue, but I'd agree it's wrong.  I
>> looked, and I suspect that a couple of judiciously placed "if
>> (dev->flags & IFF_UP)" bits ought to sort things out by simply not
>> copying the carrier state to the upper level VLAN device if that device
>> is down.  Unless somebody works this up over the weekend, I'll work that
>> out on Monday.
>>   
>That may be fine.  I suppose you'll also be ignoring admin state changes
>for the
>underlying devices in the VLAN code?  Ie, if eth0 goes admin down, you won't
>change the eth0.5 vlan to be admin down?

	Ok, I did a bit of testing on this, and I don't believe the
"update vlan carrier state" patch I did changed anything in this regard.

	Without the patch, given a configuration of eth0 with eth0.600
and eth0.700 stacked above, the sequence "ifconfig eth0.700 down;
ifconfig eth0 down; ifconfig eth0 up" results in eth0.700 being up at
the end, and both eth0.600 and eth0.700 being down when eth0 is down (up
and down here referring to IFF_UP, not carrier state).  The VLAN event
handler (vlan_device_event) deliberately sets all VLAN devices to match
the real device when the real device goes up or down.

	I still agree that this is a bit counterintuitive, but the patch
doesn't change the VLAN behavior in this regard.

	With the patch, the same thing happens, but the carrier state
also changes to match (without the patch, the VLAN interfaces remain
carrier up the whole time).

	I'm reluctant to mess with this behavior without knowing why it
works this way; there may be a good reason for it that I'm not aware of.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
