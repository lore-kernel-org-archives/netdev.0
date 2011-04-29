From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Is 802.3ad mode in bonding useful ?
Date: Fri, 29 Apr 2011 10:01:06 -0700
Message-ID: <11733.1304096466@death>
References: <4DB9185E.4050103@gmail.com> <20110428122102.GB4165@hmsreliant.think-freely.org> <4DBA2DDC.80502@gmail.com> <20110429104342.GA22387@hmsreliant.think-freely.org>
Cc: WeipingPan <panweiping3@gmail.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:40472 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab1D2RBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:01:40 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3TGj86v029359
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:45:08 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3TH2LCX064272
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 11:02:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3TH1ENE025469
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 11:01:17 -0600
In-reply-to: <20110429104342.GA22387@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:

>On Fri, Apr 29, 2011 at 11:17:48AM +0800, WeipingPan wrote:
>> On 04/28/2011 08:21 PM, Neil Horman wrote:
>> >On Thu, Apr 28, 2011 at 03:33:50PM +0800, WeipingPan wrote:
>> >>Hi, all,
>> >>
>> >>802.3ad mode in bonding implements 802.3ad standard.
>> >>
>> >>I am just wondering  802.3ad mode is useful,
>> >>since  bonding has many modes like balance-rr, active-backup, etc.
>> >>
>> >Yes, of course its usefull.  For switches which support 802.3ad, this mode
>> >allows for both peers to understand that the links in the bond are acting as an
>> >aggregate, which makes it easier to prevent things like inadvertently looped
>> >back frames, for which the other modes have to have all sorts of hacks to
>> >prevent.
>> What is looped back frames here ?
>In this case they are frames that get received by the bond, which the bond
>itself sent.  In modes where more than one slave is active, and in which the
>switch has no additional knoweldge of the aggregate (e.g. round robin mode), the
>bond can send a frame on one slave, which the switch may broadcast to all ports,
>causing the frame just sent by the bond to then get received on another slave.

	Actually, the round-robin (balance-rr) and balance-xor modes
were originally meant to interoperate with a switch configured for
traditional Etherchannel (old versions of Sun Trunking, etc) the common
term in use now seems to be "static link aggregation" to distinguish it
from 802.3ad dynamic link aggregation.  When the switch is set up that
way, there are no loopback problems, because the switch knows that all
of the ports are really one big aggregate, and it won't send broadcast
or multicast packets to more than one port of the aggregation, and knows
that a bcast/mcast originating from one of those ports should not loop
back to another port of the aggregation.

	What Neil is talking about is running -rr or -xor against,
basically, a hub or unmanaged switch, in which the switch (a) doesn't
have any link aggregation capabilities, and (b) won't complain when it
sees the same MAC address coming in from multiple ports more or less
simultaneously.  Managed switches (that have link aggregation
capabilities) will generally complain about "flapping" if they see the
same source MAC address arrive on multiple switch ports in a short
period of time.

	The special hacks now in bond_handle_frame aren't really about
preventing loopbacks, but rather to suppress duplicates, particularly
for the short periods of time that a switch is flooding traffic to all
ports because its mac table is not up to date.  This is an issue in,
e.g., active-backup mode, in which the switch has no special
configuration.  This code has moved around a lot lately, so older
kernels will have a substantially different layout, although the logic
is still pretty much the same.

	I don't recall that there's anything specifically to suppress
loopbacks for -rr or -xor mode, although there is transmit logic to keep
things like IGMP messages on the same slave all the time to keep the
switches happier.

>> I didn't see any special code to handle looped back frames in other
>> modes in bonding,
>> can you take an example ?
>> 
>See bond_handle_frame.

	The actual testing logic is in bond_should_deliver_exact_match.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
