From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering support
 for passthru mode
Date: Wed, 08 Feb 2012 18:03:31 -0800
Message-ID: <4F332973.3000405@intel.com>
References: <CB53F459.437DF%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, davem@davemloft.net, chrisw@redhat.com,
	sri@us.ibm.com, dragos.tatulea@gmail.com, kvm@vger.kernel.org,
	arnd@arndb.de, gregory.v.rose@intel.com, mchan@broadcom.com,
	dwang2@cisco.com, shemminger@vyatta.com, eric.dumazet@gmail.com,
	kaber@trash.net, benve@cisco.com
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CB53F459.437DF%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/5/2012 8:54 AM, Roopa Prabhu wrote:
> 
> 
> 
> On 2/3/12 7:32 AM, "Roopa Prabhu" <roprabhu@cisco.com> wrote:
> 
>>
>>
>>
>> On 2/2/12 10:58 AM, "John Fastabend" <john.r.fastabend@intel.com> wrote:
> <snip>..
> 
>>> Are you sure they will be good to have? I'm  not so sure you want to be
>>> able to manipulate the uc and mc tables from user space. MACVLAN seems to
>>> be one type of device where it is useful but doing this to a PF or VF seems
>>> hard to use for any real use case. Fun to test the embedded bridge though.
>>>
>>
>> I wont say I am sure. Would be nice have to have netlink interfaces to
>> ADD/DEL additional uc, mc addrs, filter flags and vlans. I have looked at
>> the existing interfaces and nothing seemed straightforward then. But I
>> forget and need to take a look again.
>> I think vlans and filter flags is somehow possible today. And maybe mc too.
>> But if I am right we don't have a way to add additional unicast addresses
>> from userspace. 
>>
>> I will dig my notes and try and list down the problems with using the
>> existing netlink interfaces for this.
> 
> There are kernel api's/ops to add/del hw uc/mc/vlan/filter filter flags:
> Ndo_set_rx_mode, add/del_vid, dev_uc_add, dev_mc_add and dev_filter_flags.
> 
> But there are no straight forward mechanisms to add these from userspace. L2
> mc addresses can be added by SIOCADDMULTI. And filter flags maybe via
> netlink. Nothing for uc and vlan as far as I know (correct me if I am
> wrong). Setting of hw filters is usually done indirectly by the kernel
> during creation of vlan devices for example.
> 
> There is a netlink msg to create a vlan device. But there is no way to add a
> vlan filter directly to the hw. Nothing for secondary uc addrs.
> This is ok for all cases except for the virtualization case I am trying to
> solve. 

Well there is the somewhat asymmetric case where we allow port VLANs to be set
on a VF but not on the PF. I can think of cases (802.1Qbg) where firmware
might be doing EVB or CDCP and enforce a specific filtering. With current
asymmetric interfaces I'm not sure how to expose this on the PF.

to see how this works look for 'ifla_vf_vlan'.

> 
> To summarize,
> 
> The requirement is to have a mechanism from userspace to populate hw filters
> on a device. And this is required to program guest nic filters into the host
> device backing the guest nic. In the direct attach case, its the macvtap
> device and in turn the macvtap lower device.

Yes I agree we would like a mechanism to do this.

> 
> Today I cant think of any other use case that would require this (except
> that there is a brief chance that this could be used in the hybrid
> acceleration stuff that ben and intel have been discussing).

I'll post a RFC I hacked out today to do this with the ./net/bridge code
in a minute. (still needs testing and some fixups).

> 
> I see the below ways this can be done:
> 1) TUNSETTXFILTER: My v1 patch, that targets only the above specific macvtap
> problem. This works for only uc/mc and flags filter. Possibly requires a new
> cmd TUNSETVLANFILTER for vlan filters.
> 
> 
> 2) rtnetlink ops for setting hw filters: My v2 patch targeting virtual
> devices that implement rtnl_link_ops. Example macvtap/macvlan
> 
> This netlink interface to set filters follows TUNSETTXFILTER giving the
> ability to set filters on these devices. The netlink payload must contain
> all the uc, mc, vid's and filter flags that go on the device.
> 
> 
> 3) netdev_ops for setting hw filters: my v3 and v4 patches. This is same as
> 2 but moves the ops to netdev, so that it can be used by all devices if
> required.
> 
> 
> 4) v5 (New approach. Not submitted yet):
> In 2 and 3 above, the netlink msg could be broken down to have separate msgs
> to support add/del of uc/mc/vlan. This should be close to what we have today
> for vf vlan and vf mac. (Something similar to what John Fastabend was
> suggesting too). Advantage, use existing hw ops. (This slightly varies from
> the original goal which was not targeted at getting in to uc,mc lists alone.
> The goal was to have macvlan maintain its own filters and use it in fwding
> lookups if needed in the future. But I guess if we need this in the future
> we could possibly use the macvlan uc, mc lists.)
> 

hmm I'm on the fence here. I like that (4) is generic but I'm not sure I
would want user space to come in and whack a uc addr added from a stacked
device. Looks like there is a free bit in netdev_hw_addr maybe we could add
another bool here to let user space only modify/delete entries that haven't
been locked by the kernel.

That said (1) seems like the straight forward approach and if we don't have
a compelling reason and use case to add the ability to modify the uc and mc
lists generically then adding features for features sake might not be a good.
I'm leaning towards (1) unless someone has a use case for the others and is
really going to implement something with it.

.John

> 
> Netlink msgs to set hw filters (basically for dev_uc_add/del,
> dev_mc_add/del, and vlans). The below is not a final cut. Just attempting
> something here. Please comment.
> 
> [IFLA_FILTER_ADDR] = {
>     [IFLA_FILTER_ADD_ADDR] = {
>         [IFLA_FILTER_HWADDR]      // Maybe a list here
>     }
> 
>     [IFLA_FILTER_DEL_ADDR] = {
>         [IFLA_FILTER_HWADDR]    // Maybe a list here
>     }
> }
> 
> [IFLA_FILTER_VLAN] = {
>     [IFLA_FILTER_ADD_VLAN] = {
>         [IFLA_FILTER_VID]          // Maybe a list here too
>     }
>     [IFLA_FILTER_DEL_VLAN] = {
>         [IFLA_FILTER_VID] // Maybe a list here too
>     }
> }
> 
> 
> 
> No additional ops, these will call the dev_uc_add/del and add/del_vid api's
> directly.
> 
> If people think this might be a better way to go, I can work up a patch for
> this.
> 
> Or if anyone thinks we can use something existing please let me know.
> 
> Again, this is needed for passing guest filters in the virtualization case.
> I don't see a need to add support for this in iproute2 too (unless anyone
> thinks otherwise)
> 
> [Note1: Since the addr is a resource and multiple adds/dels are handled by
> reference counts, a thread can really call delete multiple times and delete
> all references of a particular addr even if he had not owned it. But this is
> possible even with existing code today I think. Except that today the kernel
> does not expose an interface to do this to userspace
> 
> Note2: We probably will need one for filter flags as well. I am still
> thinking maybe we can use an existing interface for that. For symmetry a
> IFLA_FILTER_FLAGS would be nice]
> 
> 
> 
> Comments ?
> Thanks,
> Roopa
> 
> 
> 
>  
> 

