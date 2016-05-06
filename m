From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net v3] vlan: Propagate MAC address to VLANs
Date: Fri, 6 May 2016 12:48:26 -0700
Message-ID: <CAKgT0Uerb6k2aDhzJ9y+O7E5O40orX7pwOb2K2JEu048UfbFag@mail.gmail.com>
References: <572C99FB.1060905@brocade.com>
	<572C9B9E.1000304@brocade.com>
	<CAKgT0UeOhYkajP7PJo15cvTJsiEo_Z0OD7Kf=z1iXVRWQhkqaQ@mail.gmail.com>
	<572CF258.4070309@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36324 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758275AbcEFTs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 15:48:27 -0400
Received: by mail-io0-f173.google.com with SMTP id u185so143109201iod.3
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 12:48:26 -0700 (PDT)
In-Reply-To: <572CF258.4070309@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 12:36 PM, Mike Manning <mmanning@brocade.com> wrote:
> On 05/06/2016 06:02 PM, Alexander Duyck wrote:
>> On Fri, May 6, 2016 at 6:26 AM, Mike Manning <mmanning@brocade.com> wrote:
>>> The MAC address of the physical interface is only copied to the VLAN
>>> when it is first created, resulting in an inconsistency after MAC
>>> address changes of only newly created VLANs having an up-to-date MAC.
>>>
>>> The VLANs should continue inheriting the MAC address of the physical
>>> interface, unless explicitly changed to be different from this.
>>> This allows IPv6 EUI64 addresses for the VLAN to reflect any changes
>>> to the MAC of the physical interface and thus for DAD to behave as
>>> expected.
>>>
>>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>>> ---
>>>  include/linux/if_vlan.h |    2 ++
>>>  net/8021q/vlan.c        |   17 +++++++++++------
>>>  net/8021q/vlan_dev.c    |   13 ++++++++++---
>>>  3 files changed, 23 insertions(+), 9 deletions(-)
>>>
>>> --- a/include/linux/if_vlan.h
>>> +++ b/include/linux/if_vlan.h
>>> @@ -138,6 +138,7 @@ struct netpoll;
>>>   *     @flags: device flags
>>>   *     @real_dev: underlying netdevice
>>>   *     @real_dev_addr: address of underlying netdevice
>>> + *     @addr_assign_type: address assignment type
>>>   *     @dent: proc dir entry
>>>   *     @vlan_pcpu_stats: ptr to percpu rx stats
>>>   */
>>> @@ -153,6 +154,7 @@ struct vlan_dev_priv {
>>>
>>>         struct net_device                       *real_dev;
>>>         unsigned char                           real_dev_addr[ETH_ALEN];
>>> +       unsigned char                           addr_assign_type;
>>>
>>>         struct proc_dir_entry                   *dent;
>>>         struct vlan_pcpu_stats __percpu         *vlan_pcpu_stats;
>>
>> Please don't start adding new members to structures when it already
>> exists in the net_device.  If anything you should be able to drop
>> read_dev_addr if you do this correctly because you shouldn't need to
>> clone the lower dev address to watch for changes.  All you will need
>> to do is watch NET_ADDR_STOLEN.
>>
>
> Thanks for the detailed review. I had initially used the existing type
> in net_device, but the problem with this was that it got overwritten to
> NET_ADDR_SET in dev_set_mac_address(), which I was reluctant to modify.
> It would just be a case of setting the type earlier in that function
> (and caching the previous value in case there is an error).
>
> However, based on your later comment, it seems I should not bother with
> the approach I have here, namely that if the VLAN MAC is set to the same
> value as that of the lower device MAC, that is to be considered as
> resetting it and thus for MAC inheritance to resume. Instead, I will just
> make this a 1-shot transition, i.e. the VLAN MAC starts off as inherited,
> and if it is set to anything (even the value of the lower device MAC),
> inheritance is stopped. I agree this makes for a far simpler changeset.
>
> I don't think I can remove real_dev_addr, as that is still needed for
> the existing functionality in vlan_sync_address() to determine if the sync
> should be done, also as a way of caching it for handling in vlan_dev_open().

The thing is that logic isn't really needed anymore though if you are
going to be following the lower dev.  If you follow the code what it
is doing is adding the address via dev_uc_add if the lower address
moves away from the VLAN address.  With your changes you are updating
the VLAN MAC address to the lower value in the NET_ADDR_STOLEN case so
you don't need to add or remove an extra unicast address.  If the user
sets the MAC address you can then use the vlandev->dev_addr as the
address you add/remove from the unicast list and you probably don't
need to bother with tracking the lower device state anyway.

> As a matter of interest, what is the advantage of not updating the VLAN
> MAC when it is down? I appreciate that one should not add/delete
> secondary unicast addresses in this case, but there is no such
> restriction for copying the MAC.

Basically you are just wasting cycles messing with it while it is
down.  You don't need to bother with syncing up the addresses until
you bring the interface up.  At that point you essentially need to do
the vlan_sync_address type work anyway because you have to push your
address to the lower dev, or you have to pull it up from the lower dev
in the case of the stolen address.  You don't want to have MAC
addresses written to the device for an interface that is down.
