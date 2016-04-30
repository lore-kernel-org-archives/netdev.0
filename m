From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH net] Propagate MAC address changes to VLANs
Date: Sat, 30 Apr 2016 11:28:55 +0100
Message-ID: <572488E7.8040700@brocade.com>
References: <56D42C63.1070602@brocade.com>
 <20160303.161240.631812391738601311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:28465 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751548AbcD3K3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 06:29:23 -0400
In-Reply-To: <20160303.161240.631812391738601311.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2016 09:12 PM, David Miller wrote:
> From: Mike Manning <mmanning@brocade.com>
> Date: Mon, 29 Feb 2016 11:32:51 +0000
> 
>>  
>> -	/* vlan address was equal to the old address and is different from
>> +	/* vlan address was equal to the old address so now also inherit
>>  	 * the new address */
>> -	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
>> -	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
>> -		dev_uc_add(dev, vlandev->dev_addr);
>> +	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr))
>> +		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
>>  
> 
> This dev_uc_add() call removal cannot be correct, if the device is up
> we must programe it into the hardware unicast filters and if also
> potentially put it into promiscuous mode via __dev_set_rx_mode().
> 

The call to dev_uc_add() to add a secondary address is only needed if the VLAN MAC is different from that for the physical interface. For the proposed changes, the VLAN MAC is tracking that of the physical interface and so is the same (as typically it does not make sense for these to be different), so dev_uc_add() should not be called. The easiest way to demonstrate equivalence with the original code, where the MAC address has to be set manually, is with some test debugs. Here, first the MAC of the interface itself is changed (so dev_uc_add() is called), then the MAC of the VLAN is changed (so dev_uc_del() is called):

1) ORIGINAL CODE:

ip addr show dev dp0s8 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff
ip addr show dev dp0s8.40 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff
sudo ip link set dp0s8.40 addr 10:20:30:40:50:61
sudo ip link set dp0s8 addr 10:20:30:40:50:61
ip addr show dev dp0s8 | grep ether
    link/ether 10:20:30:40:50:61 brd ff:ff:ff:ff:ff:ff
ip addr show dev dp0s8.40 | grep ether
    link/ether 10:20:30:40:50:61 brd ff:ff:ff:ff:ff:ff

[ 3990.332577] --- vlan_dev_set_mac_address: id 40, call dev_uc_add for 10:20:30:40:50:61 on dp
0s8
[ 3990.332579] device dp0s8 entered promiscuous mode
[ 4002.425234] 8021q: --- vlan_sync_address: id 40, for 10:20:30:40:50:61 on dp0s8.40 (from dp0
s8)
[ 4002.425472] --- vlan_sync_address: id 40, call dev_uc_del for 10:20:30:40:50:61 on dp0s8
[ 4002.425475] --- __hw_addr_del_entry: refcount 0 for 10:20:30:40:50:61
[ 4002.425477] device dp0s8 left promiscuous mode

sudo ip link set dp0s8 addr 52:54:00:1f:06:2a
ip addr show dev dp0s8.40 | grep ether
    link/ether 10:20:30:40:50:61 brd ff:ff:ff:ff:ff:ff
sudo ip link set dp0s8.40 addr 52:54:00:1f:06:2a
ip addr show dev dp0s8 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff
ip addr show dev dp0s8.40 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff

[ 4121.606671] --- vlan_sync_address: id, 40, call dev_uc_add for 10:20:30:40:50:61 on dp0s8
[ 4121.606673] device dp0s8 entered promiscuous mode
[ 4147.487780] --- vlan_dev_set_mac_address: id 40, for 52:54:00:1f:06:2a on dp0s8
[ 4147.487782] --- vlan_dev_set_mac_address: id 40, call dev_uc_del for 10:20:30:40:50:61 dp0s8
[ 4147.487784] --- __hw_addr_del_entry: refcount 0 for 10:20:30:40:50:61
[ 4147.487786] device dp0s8 left promiscuous mode


2) WITH IMPROVEMENT FOR VLAN MAC TO FOLLOW THAT OF PHYSICAL INTF, UNLESS EXPLICITLY SET:

ip addr show dev dp0s8 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff
ip addr show dev dp0s8.40 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff
sudo ip link set dp0s8 addr 10:20:30:40:50:61
ip addr show dev dp0s8 | grep ether
    link/ether 10:20:30:40:50:61 brd ff:ff:ff:ff:ff:ff
ip addr show dev dp0s8.40 | grep ether
    link/ether 10:20:30:40:50:61 brd ff:ff:ff:ff:ff:ff

[  196.574789] 8021q: --- vlan_sync_address: id 40, for 10:20:30:40:50:61 on dp0s8.40 (from dp0
s8)
[  196.575004] --- vlan_sync_address: id 40, update to 10:20:30:40:50:61 on dp0s8.40 (from dp0s
8)

sudo ip link set dp0s8 addr 52:54:00:1f:06:2a
ip addr show dev dp0s8 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff
ip addr show dev dp0s8.40 | grep ether
    link/ether 52:54:00:1f:06:2a brd ff:ff:ff:ff:ff:ff

[  265.683313] 8021q: --- vlan_sync_address: id 40, for 52:54:00:1f:06:2a on dp0s8.40 (from dp0
s8)
[  265.683534] --- vlan_sync_address: id 40, update to 52:54:00:1f:06:2a on dp0s8.40 (from dp0s
8)

sudo ip link set dp0s8.40 addr 10:20:30:40:50:61
sudo ip link set dp0s8 addr 10:20:30:40:50:99
ip addr show dev dp0s8 | grep ether
    link/ether 10:20:30:40:50:99 brd ff:ff:ff:ff:ff:ff
ip addr show dev dp0s8.40 | grep ether
    link/ether 10:20:30:40:50:61 brd ff:ff:ff:ff:ff:ff
sudo ip link set dp0s8 addr 10:20:30:40:50:61

[ 5561.791222] --- vlan_dev_set_mac_address: id 40, for 10:20:30:40:50:61 on dp0s8
[ 5561.791225] --- vlan_dev_set_mac_address: id 40, call dev_uc_add for 10:20:30:40:50:61 on dp
0s8
[ 5561.791227] device dp0s8 entered promiscuous mode
[ 5601.050450] 8021q: --- vlan_sync_address: id 40, for 10:20:30:40:50:99 on dp0s8.40 (from dp0
s8)
[ 5630.258345] 8021q: --- vlan_sync_address: id 40, for 10:20:30:40:50:61 on dp0s8.40 (from dp0
s8)
[ 5630.258497] --- vlan_sync_address: id 40, call dev_uc_del for 10:20:30:40:50:61 on dp0s8
[ 5630.258499] --- __hw_addr_del_entry: refcount 0 for 10:20:30:40:50:61
[ 5630.258501] device dp0s8 left promiscuous mode

sudo ip link set dp0s8.40 addr 52:54:00:1f:06:2a
sudo ip link set dp0s8 addr 52:54:00:1f:06:2a

[ 5730.706196] --- vlan_dev_set_mac_address: id 40, for 52:54:00:1f:06:2a on dp0s8
[ 5730.706199] --- vlan_dev_set_mac_address: id 40, call dev_uc_add for 52:54:00:1f:06:2a on dp
0s8
[ 5730.706211] device dp0s8 entered promiscuous mode
[ 5737.378102] 8021q: --- vlan_sync_address: id 40, for 52:54:00:1f:06:2a on dp0s8.40 (from dp0
s8)
[ 5737.378236] --- vlan_sync_address: id 40, call dev_uc_del for 52:54:00:1f:06:2a on dp0s8
[ 5737.378238] --- __hw_addr_del_entry: refcount 0 for 52:54:00:1f:06:2a
[ 5737.378239] device dp0s8 left promiscuous mode



> Also your subject line isn't formatted properly, it should be:
> 
> 	[PATCH net] vlan: Propagate MAC address changes properly.
> 

Will resend with correct subject line, apologies for delay in replying.
