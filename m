From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: unresponsive vlan on top of bond with fail_over_mac=active
Date: Thu, 11 Oct 2012 17:33:48 -0700
Message-ID: <29107.1350002028@death.nxdomain>
References: <20121010231122.GB28935@unicorn.suse.cz> <8588.1349926471@death.nxdomain> <20121011103757.GA13873@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:52961 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757379Ab2JLAdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 20:33:55 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 11 Oct 2012 18:33:54 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 04CCC1FF003F
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 18:33:46 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9C0XpUg217994
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 18:33:51 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9C0XoNc002365
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 18:33:51 -0600
In-reply-to: <20121011103757.GA13873@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Kubecek <mkubecek@suse.cz> wrote:

>On Wed, Oct 10, 2012 at 08:34:31PM -0700, Jay Vosburgh wrote:
>> Michal Kubecek <mkubecek@suse.cz> wrote:
>> 	What network device are they using that requires fail_over_mac
>> to be set to active?
>
>I would have to ask for exact configuration, all I know for sure is that
>the problem was reported for s390x (S390-64) architecture. I reproduced
>it with VMware Workstation virtual devices which emulate Intel e1000.

	Have you tried the "follow" setting to fail_over_mac?

	I looked into this very topic (VLAN address propagation on s390)
earlier this year.  The eventual solution for that case was to use the
"follow" fail_over_mac option, which resolved the problem for the OSA
device (qeth).

	I did submit a patch to do MAC address propagation to VLANs, but
then withdrew it after I figured out that "follow" would also resolve
the problem without code changes.

http://patchwork.ozlabs.org/patch/153551/

>> 	I tested some of this out earlier this year, and I don't recall
>> having problems (although I'm not sure I did this exact test).  The
>> dev_uc_add() logic (in __dev_set_rx_mode) would put the underlying
>> device into promiscuous mode if the hardware didn't support multiple
>> unicast MAC addresses. dev_uc_add() was invoked by vlan_sync_address(),
>> which is called by the vlan NETDEV_CHANGEADDR notifier callback.
>
>Yes, this part works fine, I checked uc list with live crash session.
>But as bonding driver doesn't set its ndo_set_rx_mode method, the
>iformation about second MAC address doesn't propagate down to the
>slaves.

	What kernel are you looking at?  In current mainline, bonding
does have bond_set_multicast_list as ndo_set_rx_mode, although it
doesn't propagate unicast address information, only multicast.  I
believe this has been the case for a long time.

>> 	Bonding does propagate promisc to its slaves, but (as you point
>> out) not the uc lists; is the hardware in question something that
>> supports multiple unicast addresses (IFF_UNICAST_FLT)?  The device I
>> tested with does not support IFF_UNICAST_FLT, and (as I recall) would
>> end up in promisc mode.
>
>My tests were done with (emulated) e1000 which supports unicast
>filtering (up to 14 addresses, according to what I've seen in the
>driver). I'm not sure about the devices on s390x.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
