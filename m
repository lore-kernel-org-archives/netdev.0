From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 08 Sep 2011 09:19:32 -0700
Message-ID: <CA8E3924.33B60%roprabhu@cisco.com>
References: <20110908110835.GA25984@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dragos.tatulea@gmail.com>,
	<arnd@arndb.de>, <dwang2@cisco.com>, <benve@cisco.com>,
	<kaber@trash.net>, <sri@us.ibm.com>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <mchan@broadcom.com>,
	<kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:59945 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab1IHXbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 19:31:45 -0400
In-Reply-To: <20110908110835.GA25984@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 9/8/11 4:08 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Wed, Sep 07, 2011 at 10:20:28PM -0700, Roopa Prabhu wrote:
>> On 9/7/11 5:34 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
>> 
>>> On Tue, Sep 06, 2011 at 03:35:40PM -0700, Roopa Prabhu wrote:
>>>> This patch is an attempt at providing address filtering support for macvtap
>>>> devices in PASSTHRU mode. Its still a work in progress.
>>>> Briefly tested for basic functionality. Wanted to get some feedback on the
>>>> direction before proceeding.
>>>> 
>>> 
>>> Good work, thanks.
>>> 
>> 
>> Thanks.
>> 
>>>> I have hopefully CC'ed all concerned people.
>>> 
>>> kvm crowd might also be interested.
>>> Try using ./scripts/get_maintainer.pl as well.
>>> 
>> Thanks for the tip. Expanded CC list a bit more.
>> 
>>>> PASSTHRU mode today sets the lowerdev in promiscous mode. In PASSTHRU mode
>>>> there is a 1-1 mapping between macvtap device and physical nic or VF. And
>>>> all
>>>> filtering is done in lowerdev hw. The lowerdev does not need to be in
>>>> promiscous mode as long as the guest filters are passed down to the
>>>> lowerdev.
>>>> This patch tries to remove the need for putting the lowerdev in promiscous
>>>> mode. 
>>>> I have also referred to the thread below where TUNSETTXFILTER was mentioned
>>>> in 
>>>> this context: 
>>>>  http://patchwork.ozlabs.org/patch/69297/
>>>> 
>>>> This patch basically passes the addresses got by TUNSETTXFILTER to macvlan
>>>> lowerdev.
>>>> 
>>>> I have looked at previous work and discussions on this for qemu-kvm
>>>> by Michael Tsirkin, Alex Williamson and Dragos Tatulea
>>>> http://patchwork.ozlabs.org/patch/78595/
>>>> http://patchwork.ozlabs.org/patch/47160/
>>>> https://patchwork.kernel.org/patch/474481/
>>>> 
>>>> Redhat bugzilla by Michael Tsirkin:
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=655013
>>>> 
>>>> I used Michael's qemu-kvm patch for testing the changes with KVM
>>>> 
>>>> I would like to cover both MAC and vlan filtering in this work.
>>>> 
>>>> Open Questions/Issues:
>>>> - There is a need for vlan filtering to complete the patch. It will require
>>>>   a new tap ioctl cmd for vlans.
>>>>   Some ideas on this are:
>>>> 
>>>>   a) TUNSETVLANFILTER: This will entail we send the whole vlan bitmap
>>>> filter
>>>> (similar to tun_filter for addresses). Passing the vlan id's to lower
>>>> device will mean going thru the whole list of vlans every time.
>>>> 
>>>>   OR
>>>> 
>>>>   b) TUNSETVLAN with vlan id and flag to set/unset
>>>> 
>>>>   Does option 'b' sound ok ?
>>>> 
>>>> - In this implementation we make the macvlan address list same as the
>>>> address
>>>>   list that came in the filter with TUNSETTXFILTER. This will not cover
>>>> cases
>>>>   where the macvlan device needs to have other addresses that are not
>>>>   necessarily in the filter. Is this a problem ?
>>> 
>>> What cases do you have in mind?
>>> 
>> This patch targets only macvlan PASSTHRU mode and for PASSTHRU mode I don't
>> see a problem with uc/mc address list being the same in all the stacked
>> netdevs in the path. I called that out above to make sure I was not missing
>> any case in PASSTHRU mode where this might be invalid. Otherwise I don't see
>> a problem in the simple PASSTHRU use case this patch supports.
>> 
>>>> - The patch currently only supports passing of IFF_PROMISC and
>>>> IFF_MULTICAST
>>>> filter flags to lowerdev
>>>> 
>>>> This patch series implements the following
>>>> 01/3 - macvlan: Add support for unicast filtering in macvlan
>>>> 02/3 - macvlan: Add function to set addr filter on lower device in passthru
>>>> mode
>>>> 03/3 - macvtap: Add support for TUNSETTXFILTER
>>>> 
>>>> Please comment. Thanks.
>>>> 
>>>> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
>>>> Signed-off-by: Christian Benvenuti <benve@cisco.com>
>>>> Signed-off-by: David Wang <dwang2@cisco.com>
>>> 
>>> The security isn't lower than with promisc, so I don't see
>>> a problem with this as such.
>>> 
>>> There are more features we'll want down the road though,
>>> so let's see whether the interface will be able to
>>> satisfy them in a backwards compatible way before we
>>> set it in stone. Here's what I came up with:
>>> 
>>> How will the filtering table be partitioned within guests?
>> 
>> Since this patch supports macvlan PASSTHRU mode only, in which the lower
>> device has 1-1 mapping to the guest nic, it does not require any
>> partitioning of filtering table within guests. Unless I missed understanding
>> something. 
>> If the lower device were being shared by multiple guest network interfaces
>> (non PASSTHRU mode), only then we will need to maintain separate filter
>> tables for each guest network interface in macvlan and forward the pkt to
>> respective guest interface after a filter lookup. This could affect
>> performance too I think.
> 
> Not with hardware filtering support. Which is where we'd need to
> partition the host nic mac table between guests.
> 
I need to understand this more. In non passthru case when a VF or physical
nic is shared between guests, the nic does not really know about the guests,
so I was thinking we do the same thing as we do for the passthru case (ie
send all the address filters from macvlan to the physical nic). So at the
hardware, filtering is done for all guests sharing the nic. But if we want
each virtio-net nic or guest to get exactly what it asked for
macvlan/macvtap needs to maintain a copy of each guest filter and do a
lookup and send only the requested traffic to the guest. Here is the
performance hit that I was seeing. Please see my next comment for further
details. 


>> I chose to support PASSTHRU Mode only at first because its simpler and all
>> code additions are in control path only.
> 
> I agree. It would be a bit silly to have a dedicated interface
> for passthough and a completely separate one for
> non passthrough.
>
Agree. The reason I did not focus on non-passthru case in the initial
version was because I was thinking things to do in the non-passthru case
will be just add-ons to the passthru case. But true Better to flush out the
non-pasthru case details.

After dwelling on this a bit more how about the below:

Phase 1: Goal: Enable hardware filtering for all macvlan modes
    - In macvlan passthru mode the single guest virtio-nic connected will
receive traffic that he requested for
    - In macvlan non-passthru mode all guest virtio-nics sharing the
      physical nic will see all other guest traffic
      but the filtering at guest virtio-nic will make sure each guest
      eventually sees traffic he asked for. This is still better than
putting the physical nic in promiscuous mode.

(This is mainly what my patch does...but will need to remove the passthru
check and see if there are any thing else needed for non-passthru case)


Phase 2: Goal: Enable filtering at macvlan so that each guest virtio-nic
receives only what he requested for.
    - In this case, in addition to pushing the filters down to the physical
nic we will have to maintain the same filter in macvlan and do a filter
lookup before forwarding the traffic to a virtio-nic.

But I am thinking phase 2 might be redundant given virtio-nic already does
filtering for the guest. In which case we might not need phase 2 at all. I
might have been over complicating things.

Please comment. And please correct if I missed something.
 
 
>>> 
>>> A way to limit what the guest can do would also be useful.
>>> How can this be done? selinux?
>> 
>> I vaguely remember a thread on the same context.. had a suggestion to
>> maintain pre-approved address lists and allow guest filter registration of
>> only those addresses for security. This seemed reasonable. Plus the ability
>> to support additional address registration from guest could be made
>> configurable (One of your ideas again from prior work).
>> 
>> I am not an selinux expert, but I am thinking we can use it to only allow or
>> disallow access or operations to the macvtap device. (?). I will check more
>> on this.
> 
> We'd have to have a way to revoke that as well.
> 
Yes true.


>>> 
>>> Any thoughts on spoofing filtering?
>> 
>> I can only think of checking addresses against an allowed address list.
>> Don't know of any other ways. Any hints ?
> 
> Hardware (esp SRIOV) often has ways to do this check, too.
> 
Yes correct. Hw sriov and even switch in 802.1Qbh has anti-spoofing feature.
In which case I am thinking having It at the macvtap layer is not an
absolute must (?).


>> 
>> In any case I am assuming all the protection/security measures should be
>> taken at the layer calling the TUNSETTXFILTER ie..In macvtap virtualization
>> use case its libvirt or qemu-kvm. No ?
> 
> Ideally we'd have a way to separate these capabilities, so that libvirt
> can override qemu.
> 
>>> 
>>> Would it be possible to make the filtering programmable
>>> using netlink, e.g. ethtool, ip, or some such?
>> 
>> Should be possible via ethtool or ip calling ioctl TUNSETTXFILTER. Are you
>> thinking of macvlan having a netlink interface to set filter and not ioctl
>> ?. Sure.
> 
> Yes.
> 
>> But I was thinking the point of implementing TUNSETTXFILTER was to
>> maintain compatibility with the generic tap interface that does the same
>> thing. 
> 
> Yes. OTOH I don't think anyone uses that ATM so it might not
> be important if it's not a good fit.
> E.g. we could notify libvirt and have it use netlink for us
> if we like that better.
> 
Ok thanks for clarifying that. One more reason to use TUNSETTXFILTER
interface was for qemu-kvm who uses the same tap interface for macvtap and
regular tap. So if we use netlink we have to do different things for macvtap
and tap filters in qemu. And qemu-kvm does not distinguish between macvtap
and tap as far as I know. No ?


Thanks you for your review and comments.


>> And having both the netlink op and ioctl interface might not be clean ?.
> 
> No idea.
> 
>> Sorry if I misunderstood your question.
>> 
>>> That would make this useful for bridged setups besides
>>> macvtap/virtualization.
>>> 
>> 
>> Thanks for the comments. 
