From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
	support for passthru mode
Date: Tue, 18 Oct 2011 23:25:54 -0700
Message-ID: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, arnd@arndb.de,
	kvm@vger.kernel.org, mst@redhat.com, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v1 version of this RFC patch was posted at http://www.spinics.net/lists/netdev/msg174245.html

Today macvtap used in virtualized environment does not have support to 
propagate MAC, VLAN and interface flags from guest to lowerdev.
Which means to be able to register additional VLANs, unicast and multicast
addresses or change pkt filter flags in the guest, the lowerdev has to be
put in promisocous mode. Today the only macvlan mode that supports this is 
the PASSTHRU mode and it puts the lower dev in promiscous mode.

PASSTHRU mode was added primarily for the SRIOV usecase. In PASSTHRU mode 
there is a 1-1 mapping between macvtap and physical NIC or VF.

There are two problems with putting the lowerdev in promiscous mode (ie SRIOV 
VF's):
	- Some SRIOV cards dont support promiscous mode today (Thread on Intel
	driver indicates that http://lists.openwall.net/netdev/2011/09/27/6)
	- For the SRIOV NICs that support it, Putting the lowerdev in 
	promiscous mode leads to additional traffic being sent up to the 
	guest virtio-net to filter result in extra overheads.
	
Both the above problems can be solved by offloading filtering to the 
lowerdev hw. ie lowerdev does not need to be in promiscous mode as 
long as the guest filters are passed down to the lowerdev. 

This patch basically adds the infrastructure to set and get MAC and VLAN 
filters on an interface via rtnetlink. And adds support in macvlan and macvtap
to allow set and get filter operations.

Earlier version of this patch provided the TUNSETTXFILTER macvtap interface 
for setting address filtering. In response to feedback, This version 
introduces a netlink interface for the same.

Response to some of the questions raised during v1:

- Netlink interface:
	This patch provides the following netlink interface to set mac and vlan
	filters :
	[IFLA_RX_FILTER] = {
		[IFLA_ADDR_FILTER] = {
			[IFLA_ADDR_FILTER_FLAGS]
			[IFLA_ADDR_FILTER_UC_LIST] = {
				[IFLA_ADDR_LIST_ENTRY]
			}
			[IFLA_ADDR_FILTER_MC_LIST] = {
				[IFLA_ADDR_LIST_ENTRY]
			}
		}
		[IFLA_VLAN_FILTER] = {
			[IFLA_VLAN_BITMAP]
		}
	}

	Note: The IFLA_VLAN_FILTER is a nested attribute and contains only 
	IFLA_VLAN_BITMAP today. The idea is that the IFLA_VLAN_FILTER can
	be extended tomorrow to use a vlan list option if some implementations 
	prefer a list instead. 

	And it provides the following rtnl_link_ops to set/get MAC/VLAN filters:

       int                     (*set_rx_addr_filter)(struct net_device *dev,
                                               struct nlattr *tb[]);
       int                     (*set_rx_vlan_filter)(struct net_device *dev,
                                                struct nlattr *tb[]);
       size_t                  (*get_rx_addr_filter_size)(const struct 
					net_device *dev);
       size_t                  (*get_rx_vlan_filter_size)(const struct 
					net_device *dev);
       int                     (*fill_rx_addr_filter)(struct sk_buff *skb,
                                                const struct net_device *dev);
       int                     (*fill_rx_vlan_filter)(struct sk_buff *skb,
                                                const struct net_device *dev);


	Note: The choice of rtnl_link_ops was because I saw the use case for 
	this in virtual devices that need  to do filtering in sw like macvlan 
	and tun. Hw devices usually have filtering in hw with netdev->uc and 
	mc lists to indicate active filters. But I can move from rtnl_link_ops 
	to netdev_ops if that is the preferred way to go and if there is a 
	need to support this interface on all kinds of interfaces. 
	Please suggest.
	
- Protection against address spoofing:
	- This patch adds filtering support only for macvtap PASSTHRU 
	Mode. PASSTHRU mode is used mainly with SRIOV VF's. And SRIOV VF's 
	come with anti mac/vlan spoofing support. (Recently added 
	IFLA_VF_SPOOFCHK). In 802.1Qbh case the port profile has a knob to
	enable/disable anti spoof check. Lowerdevice drivers also enforce limits
	on the number of address registrations allowed.

- Support for multiqueue devices: Enable filtering on individual queues (?):
	AFAIK, there is no netdev interface to install per queue hw 
	filters for a multi queue interface. And also I dont know of any hw 
	that provides an interface to set hw filters on a per queue basis.
	A multi queue device appears as a single lowerdev (ie netdev) and
	uses the same uc and mc lists to setup unicast and multicast hw filters.
	So i dont see a huge problem with this patch coming in the way for
	multi queue devices.

- Support for non-PASSTHRU mode:
	I started implementing this. But there are a couple of problems.	
	- The lowerdev may not be a SRIOV VF and may not have 
	anti spoof capability
	- Today, in non-PASSTHRU cases macvlan_handle_frame assumes that 
	every macvlan device on top of the lowerdev has a single unique mac.
	And the macvlans are hashed on that single mac address. 
	To support filtering for non-PASSTHRU mode in addition to this 
	patch the following needs to be done:
		- non-passthru mode with a single macvlan over a lower dev
		can be treated as PASSTHRU case
		- For non-PASSTHRU mode with multiple macvlans over a single 
		lower dev:  
			- Multiple unicast mac's now need to be hashed to the 
			same macvlan device. The macvlan hash needs to change 
			for lookup based on any one of the multiple unicast 
			addresses a macvlan is interested in
			- We need to consider vlans during the lookup too
			- So the macvlan device hash needs to hash on both mac 
			and vlan
		- But the support for filtering in non-PASSTHRU mode can be 
		built on this patch

This patch series implements the following 
01/8 rtnetlink: Netlink interface for setting MAC and VLAN filters
02/8 rtnetlink: Add rtnl link operations for MAC address and VLAN filtering
03/8 rtnetlink: Add support to set MAC/VLAN filters
04/8 rtnetlink: Add support to get MAC/VLAN filters
05/8 macvlan: Add support to set MAC/VLAN filter rtnl link operations
06/8 macvlan: Add support to get MAC/VLAN filter rtnl link operations
07/8 macvtap: Add support to set MAC/VLAN filter rtnl link operations
08/8 macvtap: Add support to get MAC/VLAN filter rtnl link operations

Please comment. Thanks.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
