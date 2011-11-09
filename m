From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering support
	for passthru mode
Date: Tue, 08 Nov 2011 23:55:35 -0800
Message-ID: <20111109075449.13549.58135.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, sri@us.ibm.com, dragos.tatulea@gmail.com,
	kvm@vger.kernel.org, arnd@arndb.de, mst@redhat.com,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v3 -> v4
- Removed RFC in subject-prefix
- Regenerated patches over latest net-next
(no code changes)

Thanks to Greg Rose <gregory.v.rose@intel.com> for evaluating v3

v2 -> v3
- Moved set and get filter ops from rtnl_link_ops to netdev_ops
- Support for SRIOV VFs.
	[Note: The get filters msg (in the way current get rtnetlink handles
	it) might get too big for SRIOV vfs. This patch follows existing sriov 
	vf get code and tries to accomodate filters for all VF's in a PF. 
        And for the SRIOV case I have only tested the fact that the VF 
	arguments are getting delivered to rtnetlink correctly. The code
	follows existing sriov vf handling code so rest of it should work fine]
- Fixed all op and netlink attribute names to start with IFLA_RX_FILTER
- Changed macvlan filter ops to call corresponding lowerdev op if lowerdev 
  supports it for passthru mode. Else it falls back on macvlan handling the 
  filters locally as in v1 and v2

v1 -> v2
- Instead of TUNSETTXFILTER introduced rtnetlink interface for the same


Background and details:
=======================
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
filters on an interface via rtnetlink. It adds new netlink msg and netdev
ops for the same. And implements these ops in macvlan for passthru mode.

- Netlink interface:
    This patch provides the following netlink interface to set mac and vlan
    filters :

    Interface to set RX filter on a SRIOV VF:
    [IFLA_VF_RX_FILTERS] = {
    	[IFLA_VF_RX_FILTER] = {
    		[IFLA_RX_FILTER_VF]
    		[IFLA_RX_FILTER_ADDR] = {
    			[IFLA_RX_FILTER_ADDR_FLAGS]
    			[IFLA_RX_FILTER_ADDR_UC_LIST] = {
    				[IFLA_ADDR_LIST_ENTRY]
    			}
    			[IFLA_RX_FILTER_ADDR_MC_LIST] = {
    				[IFLA_ADDR_LIST_ENTRY]
    			}
    		}
    		[IFLA_RX_FILTER_VLAN] = {
    			[IFLA_RX_FILTER_VLAN_BITMAP]
    		}
    	}
    	...
    }
    
    Interface to set RX filter on a any network interface.:
    [IFLA_RX_FILTER] = {
    	[IFLA_RX_FILTER_VF]
    	[IFLA_RX_FILTER_ADDR] = {
    		[IFLA_RX_FILTER_ADDR_FLAGS]
    		[IFLA_RX_FILTER_ADDR_UC_LIST] = {
    			[IFLA_ADDR_LIST_ENTRY]
    		}
    		[IFLA_RX_FILTER_ADDR_MC_LIST] = {
    			[IFLA_ADDR_LIST_ENTRY]
    		}
    	}
    	[IFLA_RX_FILTER_VLAN] = {
    		[IFLA_RX_FILTER_VLAN_BITMAP]
	}
    } 

    Note1: The IFLA_RX_FILTER_VLAN is a nested attribute, but contains only 
    IFLA_RX_FILTER_VLAN_BITMAP today. The idea is that the IFLA_RX_FILTER_VLAN 
    can be extended tomorrow to have a vlan list if some implementations 
    prefer a list instead. 

    And it provides the following netdev_ops to set/get MAC/VLAN filters:

    int                     (*ndo_set_rx_filter_addr)(
	                                        struct net_device *dev, int vf,
                                                struct nlattr *tb[]);
    int                     (*ndo_set_rx_filter_vlan)(
                                                struct net_device *dev, int vf,
                                                struct nlattr *tb[]);
    size_t                  (*ndo_get_rx_filter_addr_size)(
                                                const struct net_device *dev,
                                                int vf);
    size_t                  (*ndo_get_rx_filter_vlan_size)(
                                                const struct net_device *dev,
                                                int vf);
    int                     (*ndo_get_rx_filter_addr)(
                                                const struct net_device *dev,
                                                int vf, struct sk_buff *skb);
    int                     (*ndo_get_rx_filter_vlan)(
                                                const struct net_device *dev,
                                                int vf, struct sk_buff *skb);

Some answers to questions that were raised during the review:
- Protection against address spoofing:
	- This patch adds filtering support only for macvtap PASSTHRU 
	Mode. PASSTHRU mode is used mainly with SRIOV VF's. And SRIOV VF's 
	come with anti mac/vlan spoofing support in the lowerdev driver. 
	(netdev infrastructure to support this was added recently 
	with IFLA_VF_SPOOFCHK). For 802.1Qbh devices, the port profile has a 
	knob to enable/disable anti spoof check. Lowerdevice drivers also 
	enforce limits on the number of address registrations allowed. 
	For non-SRIOV VF's its the responsibility of the lowerdev driver
	to implement any such protection. The currrent netdev hooks for 
	SRIOV VF's spoof check could be extended to accomodate any network 
	interface in the future.

- Support for multiqueue devices: Enable filtering on individual queues (?):
	As i understand after the thread between (Micheal and Greg),
	VMdq Linux implementation is not in yet and dont know how its going to
	take shape. But Intel VMdq devices do accept filters on a per-queue
	basis. Since the netdev infrastructure for VMdq is not in yet, Its
	hard to say how this patch can support it.

	This patch makes use of current netdev infrastructure for setting
	address and vlan filters. And if that changes for vmdq tomorrow,
	then the work that this patch represents can be modified to accomodate
	vmdq devices at that time. 

	So i dont see a huge problem with this patch coming in the way for
	vmdq devices.

- Support for non-PASSTHRU mode:
	I started implementing this. But there are a couple of problems.	
	- Today, in non-PASSTHRU cases macvlan_handle_frame assumes that 
	every macvlan device has a single unique mac.
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
01/6 rtnetlink: Netlink interface for setting MAC and VLAN filters
02/6 netdev: Add netdev_ops to set and get MAC/VLAN rx filters
03/6 rtnetlink: Add support to set MAC/VLAN filters
04/6 rtnetlink: Add support to get MAC/VLAN filters
05/6 macvlan: Add support to set MAC/VLAN filter netdev ops
06/6 macvlan: Add support to get MAC/VLAN filter netdev ops

Please comment. Thanks.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
