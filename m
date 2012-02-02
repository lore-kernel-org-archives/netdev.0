From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering support
 for passthru mode
Date: Thu, 02 Feb 2012 00:46:57 -0800
Message-ID: <4F2A4D81.6070002@intel.com>
References: <1321575301.2749.51.camel@bwh-desktop> <CAEE6B20.3A9F7%roprabhu@cisco.com> <20120202072448.GA25403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, chrisw@redhat.com, sri@us.ibm.com,
	dragos.tatulea@gmail.com, kvm@vger.kernel.org, arnd@arndb.de,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120202072448.GA25403@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/1/2012 11:24 PM, Michael S. Tsirkin wrote:
> On Sun, Nov 20, 2011 at 08:30:24AM -0800, Roopa Prabhu wrote:
>>
>>
>>
>> On 11/17/11 4:15 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
>>
>>> Sorry to come to this rather late.
>>>
>>> On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
>>> [...]
>>>> v2 -> v3
>>>> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
>>>> - Support for SRIOV VFs.
>>>>         [Note: The get filters msg (in the way current get rtnetlink handles
>>>>         it) might get too big for SRIOV vfs. This patch follows existing
>>>> sriov 
>>>>         vf get code and tries to accomodate filters for all VF's in a PF.
>>>>         And for the SRIOV case I have only tested the fact that the VF
>>>>         arguments are getting delivered to rtnetlink correctly. The code
>>>>         follows existing sriov vf handling code so rest of it should work
>>>> fine]
>>> [...]
>>>
>>> This is already broken for large numbers of VFs, and increasing the
>>> amount of information per VF is going to make the situation worse.  I am
>>> no netlink expert but I think that the current approach of bundling all
>>> information about an interface in a single message may not be
>>> sustainable.
>>
>> Yes agreed. I have the same concern.
> 
> So it seems that we need to extend the existing interface to allow
> tweaking filters per VF. Does it need to block this
> patchset though? After all, we'll need to support the existing

hmm not sure I follow what patchset is this blocking?

> interface indefinitely, too.
> 

OK finally got to read through this. And its not clear to me why we need
these per VF/PF filter netdevice ops and netlink extensions if we can
get the stacking correct. (Adding filters to the macvlan seems reasonable
to me)

In the cases I saw listed above I see a few enumerations:

PF <--> MACVLAN  <---> Guest <--- [...]

VF <--> MACVLAN  <---> Guest <--- [...]       

                    VF|Guest <--- [...]       direct assigned VF

                    PF|Guest <--- [...]       direct assigned PF


I used '[...]' to represent whatever additional stacking is done in the
guest unknown to the host. In the direct assign VF case (Greg Rose
correct me if I am wrong) the normal uc and mc addr lists should suffice
along with the netdev op ndo_set_rx_mode(). Here the guest adds MAC
addresses and/or VLANS as normal and then the VF<->PF back channel
should handle this if needed. This should work for Linux guests and other
OS's should do something similar.

In the direct assign PF case the hardware is owned by the guest so
no problems here.

This leaves the two MACVLAN cases which can be handled the same. If
the MACVLAN driver and netlink interface is extended to add filters
to the MACVLAN then the addresses can be pushed to the lower device
using the normal dev_uc_{add|del}() and dev_mc_{add|del}() routines.

I think this has some real advantages to the above scheme. First
we get rid of _all_ the drivers having to add a bunch of new
net_device ops and do it once in the layer above. This is nice
for driver implementers but also because your feature becomes usable
immediately and we don't have to wait for driver developers to implement
it.

Also it prunes down the number of netlink extensions being added
here. 

Additionally the existing semantics seem a bit strange to me on the
netlink message side. Taking a quick look at the macvlan implementation
it looks like every set has to have a complete list of address. But
the dev_uc_add and dev_uc_del seem to be using a refcnt scheme so
if I want to add a second address and then latter a third address
how does that work?

Is the expected flow from user space 'read uc_list -> write uc_list'?
This seems risky because with two adders in user space you might
lose addresses unless they are somehow kept in sync. IMHO it is likely
easier to implement an ADD and DEL attribute rather than a table
approach. Took a quick stab at something like this below but there
might be a better way to do this and allow direct modification of the
uc and mc lists I think means you could remove a uc address added
by some stacked device maybe a VLAN. (just guessing.)

Sorry if I missed something in the above thread I read most of it. And
maybe I missed something or oversimplified the problem.

Thanks,
John



+/* MACVLAN ADDRLIST management section 
+ *
+ * Contains attributes to expose multicast and unicast hardware
+ * RX address filters to user space.
+ *
+ * FIELDS:
+ * - IFLA_ADDRLIST_{UC|MC}
+ *
+ *   Read only attributes, returns currently set mc or uc addr list.
+ *
+ * - IFLA_ADDRLIST_{UC|MC}_ADD
+ *
+ *   Write only attributes, adds listed addresses to dev uc or mc
+ *   RX filter address lists.
+ *
+ * - IFLA_ADDRLIST_{UC|MC}_DEL
+ *
+ *   Write only attributes, deletes listed addresses in dev uc or
+ *   mc RX filter address lists.
+ *
+ * PRECEDENCE:
+ *
+ * Add operations are parsed before delete operations. Passing a
+ * single netlink message with a single address in both the add
+ * and del lists will result in an addresses being added and then
+ * removed.
+ *
+ * USAGE:
+ *
+ *     [IFLA_ADDRLISTS]
+ *             [IFLA_ADDRLIST_UC]
+ *                     [IFLA_ADDRLIST_ADDR], ...
+ *             [IFLA_ADDRLIST_UC_ADD]
+ *                     [IFLA_ADDRLIST_ADDR], ...
+ *             [IFLA_ADDRLIST_UC_DEL]
+ *                     [IFLA_ADDRLIST_ADDR}, ...
+ *             [IFLA_ADDRLIST_MC]
+ *                     [IFLA_ADDRLIST_ADDR], ...
+ *             [IFLA_ADDRLIST_MC_ADD]
+ *                     [IFLA_ADDRLIST_ADDR], ...
+ *             [IFLA_ADDRLIST_MC_DEL]
+ *                     [IFLA_ADDRLIST_ADDR}, ...
+ *
+ * NOTES:
+ *
+ * This interface exposes the uc and mc addresses. Addresses
+ * are handled with reference counting so adding the same address
+ * repeatedly will increment the reference count. No effort is
+ * made to determine if the address being deleted was not added
+ * by a stacked object earlier e.g. VLAN. This could for instance
+ * result in ingress VLAN traffic being dropped.
+ */








