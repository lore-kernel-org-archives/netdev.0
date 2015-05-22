From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH v5] ixgbe: Add module parameter to disable
 VLAN filter
Date: Fri, 22 May 2015 09:16:04 -0700
Message-ID: <555F5644.8040401@redhat.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB460C@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sy.jong.choi@intel.com" <sy.jong.choi@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB460C@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/21/2015 06:10 AM, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> Introduce module parameter "disable_hw_vlan_filter" to disable HW VLAN
> filter on ixgbe module load.
>
>  From the hardware limitation, there are only 64 VLAN entries for HW VLAN
> filter, and it leads to limit the number of VLANs up to 64 among PF and
> VFs. For SDN/NFV case, we need to handle unlimited VLAN packets on VF.
> In such case, every VLAN packet can be transmitted to each VF.
>
> When we try to make VLAN devices on VF, the 65th VLAN registration fails
> and never be able to receive a packet with that VLAN tag.
> If we do the below command on VM, ethX.65 to ethX.100 cannot be created.
>    # for i in `seq 1 100`; do \
>      ip link add link ethX name ethX.$i type vlan id $i; done
>
> There is a capability to disable HW VLAN filter and that makes all VLAN
> tagged packets can be transmitted to every VFs. After VLAN filter stage,
> unicast packets are transmitted to VF which has the MAC address same as
> the transmitting packet.
>
> With this patch and "disable_hw_vlan_filter=1", we can use unlimited
> number of VLANs on VF.
>
> Disabling HW VLAN filter breaks some NIC features such as DCB and FCoE.
> DCB and FCoE are disabled when HW VLAN filter is disabled by this module
> parameter.
> Because of that reason, the administrator has to know that before turning
> off HW VLAN filter.

You might also want to note that it makes the system susceptible to 
broadcast/multicast storms since it eliminates any/all VLAN isolation.  
So a broadcast or multicast packet on one VLAN is received on ALL 
interfaces regardless of their VLAN configuration. In addition the 
current VF driver is likely to just receive the packet as untagged, see 
ixgbevf_process_skb_fields().  As a result one or two VFs can bring the 
entire system to a crawl by saturating the PCIe bus via 
broadcast/multicast traffic since there is nothing to prevent them from 
talking to each other over VLANs that are no longer there.

For the sake of backwards compatibility I would say that a feature like 
this should be mutually exclusive with SR-IOV as well since it will 
cause erratic behavior.  The VF will receive requests from all VLANs 
thinking the traffic is untagged, and then send replies back to VLAN 0 
even though that isn't where the message originated. Until the VF issue 
is fixed this type of feature is a no-go.

- Alex
