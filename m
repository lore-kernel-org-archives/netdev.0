From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw addresses
Date: Tue, 26 Feb 2013 21:01:43 -0800
Message-ID: <512D9337.6070504@intel.com>
References: <20130226.150309.1215210522427869530.davem@davemloft.net> <512D1A01.9020301@redhat.com> <512D300F.20405@intel.com> <20130226.171503.1736601811583226926.davem@davemloft.net> <20130227020744.GA25063@nitbit.x32> <512D6F27.90209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43090 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab3B0FBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 00:01:45 -0500
In-Reply-To: <512D6F27.90209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/26/2013 6:27 PM, Vlad Yasevich wrote:
> On 02/26/2013 09:07 PM, John Fastabend wrote:
>> On Tue, Feb 26, 2013 at 05:15:03PM -0500, David Miller wrote:
>>> From: John Fastabend <john.r.fastabend@intel.com>
>>> Date: Tue, 26 Feb 2013 13:58:39 -0800
>>>
>>>> [...]
>>>>
>>>>>>>
>>>>>>>
>>>>>>> [RFC PATCH] rtnetlink: Add support for adding/removing additional hw
>>>>>>> addresses.
>>>>>>>
>>>>>>> Add an ability to add and remove HW addresses to the device
>>>>>>> unicast and multicast address lists.  Right now, we only have
>>>>>>> an ioctl() to manage the multicast addresses and there is no
>>>>>>> way the manage the unicast list.
>>>>>>>
>>>>>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>>>>>
>>>>>> This is a step in the right direction, and you're right that there is
>>>>>> a difficulty in detecting whether support exists or not.
>>>>>>
>>>>>> I am so surprised that we've have ->set_rx_mode() support for
>>>>>> multiple
>>>>>> unicast MAC addresses in so many drivers all this time, yet no way
>>>>>> outside of FDB to make use of it at all.
>>>>>
>>>>> And even that is not always available.  In most drivers it requires
>>>>> module parameters or other explicit configuration steps.  Meanwhile
>>>>> set_rx_mode() doesn't seem to depend on any of those and just does the
>>>>> right thing.
>>>>>
>>>>> For what I was trying to do ioctl() was a really easy way out for both
>>>>> kernel and user space implementation, so I gave is shot.
>>>>>
>>>>> -vlad
>>>>>
>>>>
>>>> Don't we already support this with
>>>
>>> The whole point is that these multiple-unicast-address configuration
>>> facilities are inaccessible without FDB, and there is no reason
>>> whatsoever for that.
>>
>> Yes I see now sorry I was behind the thread.
>>
>> We could just use the fdb hooks and add a dflt routine to handle the
>> case where the netdev doesn't provide a specific ndo_op for us. This
>> boils down to calling set_rx_mode anyways through this call chain,
>>
>>     ndo_fdb_add
>>     dev_uc_add_excl
>>         __dev_set_rx_mode
>>             ndo_set_rx_mode
>>
>> As long as folks don't think this is too much of an abuse of the fdb
>> hooks. Here's an example I only compile tested this so take it as
>> an example only. It probably needs some cleanups and the dump routine
>> needs some thought not sure you want to dump all MACs always.
>
> I thought about doing, but this becomes broken on the drivers that
> support ndo_fdb_* functions.  Those drivers mainly require additional
> configuration that is not necessary for dev_uc_add_excl() to work.
>
> For example, ixgbe and melanox requires VF to be on, qlogic needs a
> module parameter, macvlan has to be in passthrough.  However,
> ndo_set_rx_mode() in most cases doesn't care about those settings and
> just works.
>

The ixgbe piece could just use the dflt routines I put below. The
SR-IOV check is only there because when I wrote that I didn't consider
adding additional addresses without VFs. This was a poor example.

The mlx4 card is checking if the device is a slave or master before
adding/removing addresses. My guess is this is the same type of check
as ixgbe and would work just fine without it.

I'm not sure macvlan supports unicast hw addresses either way but
there is no reason we couldn't. The idea was we would come back and
write it later. Like many things I haven't got to it yet.

Calling set_rx_mode() on qlcnic doesn't look to help you at all either
it appears to ignore the uc_list either way.

is that all the callers? looks like it.

> So fdb will not always work even if the driver has proper support for
> IFF_UNICAST_FLT.
>

The fdb could work if we fix the drivers it seems to me most
the cases where it wouldn't work are just lack of foresight or the code
isn't there yet. I think it might be valuable to have a single API for
both use cases.

.John

> -vlad
>
