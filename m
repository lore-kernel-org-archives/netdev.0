From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding two 802.1q interfaces triggers "sleeping function called from invalid context"
Date: Tue, 01 May 2007 13:33:26 -0700
Message-ID: <6380.1178051606@death>
References: <46378B5F.9060301@redhat.com> <20070501193105.GA4737@gospo.rdu.redhat.com>
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:34992 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423548AbXEAUdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 16:33:31 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l41KXVCQ020180
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 16:33:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l41KXTPI530102
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 16:33:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l41KXSHa021030
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 16:33:29 -0400
In-reply-to: <20070501193105.GA4737@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>> I need to use a bonding through two 802.1q tag VLAN virtual interface in the
>> same physical network interface. When I bond interface with command :
>> ifenslave bond0 eth1.10 eth1.20
>> Console and dmesg will continues report BUG:
>> --------------Output1 begin kernel 2.6.20-1.2933.fc6------------
>> BUG: sleeping function called from invalid context at include/asm/uaccess.h:500
>> in_atomic():1, irqs_disabled():0
>>  [<c04ecadb>] copy_from_user+0x35/0x66
>>  [<c05c2e78>] dev_ethtool+0x51/0xa0d
>>  [<c05ee503>] tcp_current_mss+0x71/0xdf
>>  [<c05ee169>] tcp_rcv_established+0x74f/0x7de
>>  [<c04cf48f>] selinux_netlbl_sock_rcv_skb+0x1d/0x5b
>>  [<c05f3a78>] tcp_v4_do_rcv+0x1bf/0x49c
>>  [<c05f5f1b>] tcp_v4_rcv+0x564/0x8b1
>>  [<d8a3ac03>] vlan_dev_ioctl+0x7b/0xa7 [8021q]
>>  [<d8a3ab88>] vlan_dev_ioctl+0x0/0xa7 [8021q]
>>  [<d8a53102>] bond_update_speed_duplex+0x88/0xd7 [bonding]
>>  [<d8a5688e>] bond_mii_monitor+0x0/0x403 [bonding]
>>  [<d8a56c01>] bond_mii_monitor+0x373/0x403 [bonding]
>
>Jay Vosburgh and I have been working on something to address this and
>other issues related to possible sleeping activities that might come
>from the monitoring functions.  I feel like we are getting close to
>something so I hope we can post something soon.
>
>Care to add anything, Jay?

	I was thinking about this one a couple of days ago; it's a
little tricky to get out of, since we nominally need to do the ethtool
calls holding only rtnl, but don't want to cycle rtnl for each monitor
pass.

	The warning only shows up with VLANs because VLAN get_settings()
calls dev_ethtool() directly, and the copy_from_user() in dev_ethtool()
is the complaining party here.

	Calling an end device driver's get_settings() directly doesn't
trigger the warning.  I think that's safe without rtnl (at least insofar
as the slave won't vanish), since the slave cannot vanish without
bonding being notified via the NETDEV_UNREGISTER notifier.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
