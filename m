From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 1/6] net: bridge: Use the MDB_RTR_TYPE_TEMP on
 bridge device too
Date: Thu, 5 Oct 2017 15:52:32 +0300
Message-ID: <3b1fa70c-9880-39de-f48f-45f117d6d552@cumulusnetworks.com>
References: <20171005103642.1414-1-jiri@resnulli.us>
 <20171005103642.1414-2-jiri@resnulli.us>
 <b9cfcf9f-bb3a-6649-5b6a-39be0a957550@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        andrew@lunn.ch, stephen@networkplumber.org, nbd@nbd.name,
        roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:45587 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751310AbdJEMwh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 08:52:37 -0400
Received: by mail-lf0-f47.google.com with SMTP id d17so16848574lfe.2
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 05:52:36 -0700 (PDT)
In-Reply-To: <b9cfcf9f-bb3a-6649-5b6a-39be0a957550@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/17 15:09, Nikolay Aleksandrov wrote:
> On 05/10/17 13:36, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>>
>> Every bridge port is in one of four mcast router port states:
>>  - MDB_RTR_TYPE_PERM - the port is set by the user to be an mrouter port
>>    regardless of IGMP queries.
>>  - MDB_RTR_TYPE_DISABLED - the port is set by the user to not be an mrouter
>>    port regardless of IGMP queries.
>>  - MDB_RTR_TYPE_TEMP - the port is set by the user to be in mcast router
>>    learning state, but currently it is not an mrouter port as no IGMP query
>>    has been received by it for the last multicast_querier_interval.
>>  - MDB_RTR_TYPE_TEMP_QUERY - the port is set by the user to be in mcast
>>    router learning state, and currently it is an mrouter port due to an
>>    IGMP query that has been received by it during the passed
>>    multicast_querier_interval.
> 
> I think you got the last two partially mixed up, MDB_RTR_TYPE_TEMP marks the port as a router
> regardless if there were any igmp queries, while TYPE_TEMP_QUERY means it's in learning
> state. It is the timer (armed vs not) that defines if currently the port is a router
> when one of the TEMP/TEMP_QUERY are set. In the _TEMP case it is always armed as it
> is refreshed by user or igmp queries which was the point of that mode.
> So this means in br_multicast_router() just check for the timer_pending or perm mode.
> 
> In the port code you have the following transitions:
>  _TEMP -> TEMP_QUERY (on timer fire or user-set val, port becomes learning only)
>  _TEMP -> _TEMP (noop on user refresh or igmp query, timer refreshes)
>  _TEMP_QUERY -> _TEMP_QUERY (on igmp query the timer is armed, port becomes router)
> 
> you never have _TEMP_QUERY -> _TEMP, which you're using here to denote the timer
> getting armed and the bridge becoming a router.
> 
>>
>> The bridge device (brX) itself can also be configured by the user to be
>> either fixed, disabled or learning mrouter port states, but currently there
>> is no distinction between the MDB_RTR_TYPE_TEMP_QUERY and MDB_RTR_TYPE_TEMP
>> in the bridge internal state. Due to that, when an IGMP query is received,
>> it is not straightforward to tell whether it changes the bridge device
>> mrouter port status or not.
> 
> But before this patch the bridge device could not get that set.
> 
>>
>> Further patches in this patch-set will introduce notifications upon the
>> bridge device mrouter port state. In order to prevent resending bridge
>> mrouter notification when it is not needed, such distinction is necessary.
>>
> 
> Granted the bridge device hasn't got a way to clearly distinguish the transitions
> without the chance for a race and if using the timer one could get an unnecessary
> notification but that seems like a corner case when the timer fires exactly at the
> same time as the igmp query is received. Can't it be handled by just checking if
> the new state is different in the notification receiver ?

Scratch the sentence below, on a second thought I'd prefer to stick with this
version if it's a problem. :-)

> If it can't and is a problem then I'd prefer to add a new boolean to denote that
> router on/off transition rather than doing this.
> 
>> Hence, add the distinction between MDB_RTR_TYPE_TEMP and
>> MDB_RTR_TYPE_TEMP_QUERY states for the bridge device, similarly to any
>> other bridge port.
>>
> 
> This does not add proper MDB_RTR_TYPE_TEMP support for the bridge device
> but seems to abuse it to distinguish the timer state, and changes
> the meaning of MDB_RTR_TYPE_TEMP. Can't you just use the timer instead ?
> I think it will simplify the set and avoid all of this.
> 
>> In order to not break the current kernel-user API, don't propagate the new
>> state to the user and use it only in the bridge internal state. Thus, if
>> the user reads (either via sysfs or netlink) the bridge device mrouter
>> state, he will get the MDB_RTR_TYPE_TEMP_QUERY state even if the current
>> bridge state is MDB_RTR_TYPE_TEMP.
>>
[snip]
