From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: set device in RLB ARP packet
 handler
Date: Sat, 24 Jul 2010 20:38:16 -0700 (PDT)
Message-ID: <20100724.203816.226785255.davem@davemloft.net>
References: <20100722195240.GA25359@w-gedwards.lhn.com>
	<28252.1279915324@death>
	<20100723202648.GU7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, greg.edwards@hp.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40612
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750912Ab0GYDiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 23:38:00 -0400
In-Reply-To: <20100723202648.GU7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Fri, 23 Jul 2010 16:26:48 -0400

> On Fri, Jul 23, 2010 at 01:02:04PM -0700, Jay Vosburgh wrote:
>> 
>> From: Greg Edwards <greg.edwards@hp.com>
>> 
>> After:
>> 
>> commit 6146b1a4da98377e4abddc91ba5856bef8f23f1e
>> Author: Jay Vosburgh <fubar@us.ibm.com>
>> Date:   Tue Nov 4 17:51:15 2008 -0800
>> 
>>     bonding: Fix ALB mode to balance traffic on VLANs
>> 
>> the dev field in the RLB ARP packet handler was set to NULL to wildcard
>> and accommodate balancing VLANs on top of bonds.
>> 
>> This has the side-effect of the packet handler being called against
>> other, non RLB-enabled bonds, and a kernel oops results when it tries to
>> dereference rx_hashtbl in rlb_update_entry_from_arp(), which won't be
>> set for those bonds, e.g. active-backup.
>> 
>> With the __netif_receive_skb() changes from:
>> 
>> commit 1f3c8804acba841b5573b953f5560d2683d2db0d
>> Author: Andy Gospodarek <andy@greyhouse.net>
>> Date:   Mon Dec 14 10:48:58 2009 +0000
>> 
>>     bonding: allow arp_ip_targets on separate vlans to use arp validation
>> 
>> frames received on VLANs correctly make their way to the bond's handler,
>> so we no longer need to wildcard the device.
>> 
>> The oops can be reproduced by:
>> 
>> modprobe bonding
>> 
>> echo active-backup > /sys/class/net/bond0/bonding/mode
>> echo 100 > /sys/class/net/bond0/bonding/miimon
>> ifconfig bond0 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
>> echo +eth0 > /sys/class/net/bond0/bonding/slaves
>> echo +eth1 > /sys/class/net/bond0/bonding/slaves
>> 
>> echo +bond1 > /sys/class/net/bonding_masters
>> echo balance-alb > /sys/class/net/bond1/bonding/mode
>> echo 100 > /sys/class/net/bond1/bonding/miimon
>> ifconfig bond1 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
>> echo +eth2 > /sys/class/net/bond1/bonding/slaves
>> echo +eth3 > /sys/class/net/bond1/bonding/slaves
>> 
>> Pass some traffic on bond0.  Boom.
>> 
>> [ Tested, behaves as advertised.  I do not believe a test of the bonding
>> mode is necessary, as there is no race between the packet handler and
>> the bonding mode changing (the mode can only change when the device is
>> closed).  Also updated the log message to include the reproduction and
>> full commit ids.  -J ]
>> 	
>> Signed-off-by: Greg Edwards <greg.edwards@hp.com>
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 
> Acked-by: Andy Gospodarek <andy@greyhouse.net>

This seems serious enough to put into net-2.6, so that's where I applied
it.

Thanks!
