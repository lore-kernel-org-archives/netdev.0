From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 15 Sep 2011 06:46:46 -0700
Message-ID: <CA974FD6.343A2%roprabhu@cisco.com>
References: <CA93894D.33EF8%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, <netdev@vger.kernel.org>,
	<dragos.tatulea@gmail.com>, <arnd@arndb.de>, <dwang2@cisco.com>,
	<benve@cisco.com>, <kaber@trash.net>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <mchan@broadcom.com>,
	<kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CA93894D.33EF8%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



The netlink patch is still in the works. I will post the patches after I
clean it up a bit and also accommodate or find answers to most questions
discussed for non-passthru case. Thought I will post the netlink interface
here to see if anyone has any early comments. I have a
rtnl_link_ops->set_rx_filter defined.

[IFLA_RX_FILTER] = {
    [IFLA_ADDRESS_FILTER] = {
        [IFLA_ADDRESS_FILTER_FLAGS]
        [IFLA_ADDRESS_LIST] = {
            [IFLA_ADDRESS_LIST_ENTRY]
        }
    }    
    [IFLA_VLAN_FILTER] = {
        [IFLA_VLAN_LIST] = {
            [IFLA_VLAN]
        }
    }
}

Some open questions:
    - The VLAN filter above shows a VLAN list. It could also be a bitmap or
the interface could provide both a bitmap and VLAN list for more flexibility
. Like the below  

[IFLA_RX_FILTER] = {
    [IFLA_ADDRESS_FILTER] = {
        [IFLA_ADDRESS_FILTER_FLAGS]
        [IFLA_ADDRESS_LIST] = {
            [IFLA_ADDRESS_LIST_ENTRY]
        }
    }    
    [IFLA_VLAN_FILTER] = {
        [IFLA_VLAN_BITMAP]
        [IFLA_VLAN_LIST] = {
            [IFLA_VLAN]
        }
    }
}

    - Do you see any advantage in keeping Unicast and multicast address list
separate ? Something like the below :
    [IFLA_RX_FILTER] = {
        [IFLA_ADDRESS_FILTER_FLAGS]
        [IFLA_UC_ADDRESS_FILTER] = {
            [IFLA_ADDRESS_LIST] = {
                [IFLA_ADDRESS_LIST_ENTRY]
            }
        }
        [IFLA_MC_ADDRESS_FILTER] = {
            [IFLA_ADDRESS_LIST] = {
                [IFLA_ADDRESS_LIST_ENTRY]
            }
        }
        [IFLA_VLAN_FILTER] = {
            [IFLA_VLAN_LIST] = {
                [IFLA_VLAN]
            }
        }
    } 

    - Is there any need to keep address and vlan filters separate. And have
two rtnl_link_ops, set_rx_address_filter, set_rx_vlan_filter ?. I don't see
one .

    [IFLA_RX_ADDRESS_FILTER] = {
        [IFLA_ADDRESS_FILTER_FLAGS]
        [IFLA_ADDRESS_LIST] = {
            [IFLA_ADDRESS_LIST_ENTRY]
        }
    }
    [IFLA_RX_VLAN_FILTER] = {
        [IFLA_VLAN_LIST] = {
            [IFLA_VLAN]
        }
    } 


Thanks,
Roopa



On 9/12/11 10:02 AM, "Roopa Prabhu" <roprabhu@cisco.com> wrote:

> 
> 
> 
> On 9/11/11 12:03 PM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
>> On Sun, Sep 11, 2011 at 06:18:01AM -0700, Roopa Prabhu wrote:
>>> 
>>> 
>>> 
>>> On 9/11/11 2:44 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
>>> 
>>>> 
>>>> Yes, but what I mean is, if the size of the single filter table
>>>> is limited, we need to decide how many addresses is
>>>> each guest allowed. If we let one guest ask for
>>>> as many as it wants, it can lock others out.
>>> 
>>> Yes true. In these cases ie when the number of unicast addresses being
>>> registered is more than it can handle, The VF driver will put the VF  in
>>> promiscuous mode (Or at least its supposed to do. I think all drivers do
>>> that).
>>> 
>>> 
>>> Thanks,
>>> Roopa
>> 
>> Right, so that works at least but likely performs worse
>> than a hardware filter. So we better allocate it in
>> some fair way, as a minimum. Maybe a way for
>> the admin to control that allocation is useful.
> 
> Yes I think we will have to do something like that. There is a maximum that hw
> can support. Might need to consider that too. But there is no interface to get
> that today. I think the virtualization case gets a little trickier. Virtio-net
> allows upto 64 unicast addresses. But the lowerdev may allow only upto say 10
> unicast addresses (I think intel supports 10 unicast addresses on the VF). Am
> not sure if there is a good way to notify the guest of blocked addresses.
> Maybe putting the lower dev in promiscuous mode could be a policy decision too
> in this case. 
> 
> One other thing, I had indicated that I will look up details on opening my
> patch for non-passthru to enable hw filtering (without adding filtering
> support in macvlan right away. Ie phase1). Turns out in current code in
> macvlan_handle_frame, for non-passthru case, it does not fwd unicast pkts
> destined to macs other than the ones in macvlan hash. So a filter or hash
> lookup there for additional unicast addresses needs to be definitely added for
> non-passthru.
> 
> Thanks,
> Roopa
> 
> 
>  

