From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 25062] New: Bonding packet deduplication doesn't work properly anymore
Date: Thu, 06 Jan 2011 18:47:11 -0800
Message-ID: <14110.1294368431@death>
References: <bug-25062-10286@https.bugzilla.kernel.org/> <20110104133936.60d389e2.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-new@lists.osdl.org, bugme-daemon@bugzilla.kernel.org,
	kevin.lapagna@bigtag.ch
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:50957 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab1AGCrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 21:47:17 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p072bM2A006473
	for <netdev@vger.kernel.org>; Thu, 6 Jan 2011 19:37:22 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p072lEa0251588
	for <netdev@vger.kernel.org>; Thu, 6 Jan 2011 19:47:14 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p072lDgv010314
	for <netdev@vger.kernel.org>; Thu, 6 Jan 2011 19:47:14 -0700
In-reply-to: <20110104133936.60d389e2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:

>On Fri, 17 Dec 2010 11:45:18 GMT
>bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=25062
>> 
>>            Summary: Bonding packet deduplication doesn't work properly
>>                     anymore
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: > 2.6.33
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: high
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: kevin.lapagna@bigtag.ch
>>         Regression: No
>> 
>> 
>> Here's the setup:
>> 
>> switch: ordinary cisco switch
>> eth0: NIC with kernel module tg3
>> eth1: NIC with kernel module e1000e
>> bond0: bond with slaves eth0,eth1 in mode 1 (or 5)
>> bond0.100: vlan device created with vconfig
>> bridge100: bridge created with brctl
>> tap1: tap device created with tunctl
>> vguest: qemu-kvm vguest whit emulated e1000 NIC
>> 
>> 
>> |________________|-- eth0 \                                               |________________|
>> | switch |          -- bond0 -- bond0.100 -- bridge100 -- tap1 -- | vguest |
>> |________|-- eth1 /                                               |________|
>> 
>> When the vguest emits an ethernet broadcast (DHCP-request), it's forwarded all
>> the way up to the switch, through eth0. The switch forwards the broadcast -
>> also to eth1. The packet travels then all the way back to bridge100. So the
>> last status known for bridge100, regarding the mac address of the vgeust is,
>> that it is behind bond0.110 (instead of tap1). If a DHCP-server responds to the
>> request, the packet travels to bridge100, which has now a faulty
>> MAC-address-table and the packet will be rejected and never reaches tap1 and
>> therefor not the vguest.
>> 
>> I witnessed this wrong behavior in kernel 2.6.37-rc5 (debian package), 2.6.36.2
>> and 2.6.35.9 (self compiled -  vanilla). The setup has worked with kernels <=
>> 2.6.33.7. I've never tried 2.6.34.
>> 
>> I assume the setup above is a common way for the separation of virtual guests
>> on a network level. So this could become a major issue for a lot of people when
>> upgrading their kernels.

	Just a note that I have reproduced what I believe is the same
problem (I didn't use tap, and assigned an IP to the bridge).  I used
arping to generate ethernet broadcasts.  I see the problem on 2.6.36.2,
but not on today's net-next-2.6.

	I'll see if I can dig up the root cause tomorrow.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
