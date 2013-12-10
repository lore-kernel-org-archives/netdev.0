From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v4 6/11] bonding: rebuild the lock use for bond_activebackup_arp_mon()
Date: Tue, 10 Dec 2013 11:28:16 +0800
Message-ID: <52A68A50.7010404@huawei.com>
References: <52A2D22F.1000902@huawei.com> <7308.1386643143@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"Veaceslav Falico" <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:56970 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3LJDaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:30:19 -0500
In-Reply-To: <7308.1386643143@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/10 10:39, Jay Vosburgh wrote:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>> The bond_activebackup_arp_mon() use the bond lock for read to
>> protect the slave list, it is no effect, and the RTNL is only
>> called for bond_ab_arp_commit() and peer notify, for the performance
>> better, use RCU to replace with the bond lock, to the bond slave
>> list need to called in RCU, add a new bond_first_slave_rcu()
>> to get the first slave in RCU protection.
>>
>> In bond_ab_arp_probe(), the bond->current_arp_slave may changd
>> if bond release slave, just like:
>>
>> 	bond_ab_arp_probe()			bond_release()
>> 	cpu 0					cpu 1
>> 	...
>> 	if (bond->current_arp_slave...)		...
>> 	...				bond->current_arp_slave = NULl
>> 	bond->current_arp_slave->dev->name	...
>>
>> So the current_arp_slave need to dereference in the section.
>>
>> When bond_ab_arp_inspect() and should_notify_peers is true, the
>> RTNL will called twice, it is a loss of performance, so make the
>> two RTNL together to avoid performance loss.
> 
> 	Just for the record, we cannot acquire RTNL every single pass of
> the monitor (at typically ten per second), but the situation you cite is
> rare, and the performance impact of two round trips on RTNL is minimal.
> That said, if the code is clear, there's no disadvantage with arranging
> for just one round trip on RTNL.
> 
yes, it is a very slight improvement and hardly convincing to make two
rounds to one, if you strongly disagree with it, I will abandon the modify.

> 	In patch 2 of the series you reorganized the RTNL locking around
> the inspect / notify_peers logic in bond_mii_monitor to be generally:
> 
> 	if (inspect) {
> 		[ acquire RTNL ]
> 		[ do commit activity, et al ]
> 
> 		if (should_notify_peers)
> 			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);
> 
> 		[ release RNTL ]
> 	} else {
> 		if (should_notify_peers) {
> 			[ acquire RTNL ]
> 			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);
> 			[ release RTNL ]
> 		}
> 	}
> 
> 	but in this patch, the new logic in bond_activebackup_arp_mon
> is:
> 
> 	if (inspect) {
> 		[ acquire RTNL ]
> 		[ do commit activity, et al ]
> 
> 		if (should_notify_peers) {
> 			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);
> 			should_notify_peers = false;
> 		}
> 		[ release RNTL ]
> 	}
> 
> [ ... ]
> 
> re_arm:
> 
> 	if (should_notify_peers) {
> 		[ acquire RTNL ]
> 		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);
> 		[ release RTNL ]
> 	}
> 
> 
> 	Is there a reason not to have these both operate the same way?
> 
> 	I found the version in bond_mii_monitor (from patch 2 of the
> series) easier to follow than this version for bond_activebackup_arp_mon
> (because the two calls are closer together, and the "should_notify_peers
> = false" is easy to miss on a first read).
>

yes, it is true, although in fact they have same logic, I think the version
in bond_mii_monitor is easy to read, so if you thought the version in 
bond_activebackup_arp_mon is bad, I will just follow the version of bond_mii_monitor.

Regards
Ding
 
