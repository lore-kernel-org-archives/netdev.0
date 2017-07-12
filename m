From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC 05/12] net: dsa: Add support for learning FDB
 through notification
Date: Wed, 12 Jul 2017 14:42:58 +0300
Message-ID: <8109bc0d-8887-98f3-ff06-1ae5d9a0a0f8@cumulusnetworks.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-6-git-send-email-arkadis@mellanox.com>
 <424fbf9a-f060-87d1-cad2-36e2ef732bd6@gmail.com>
 <87aa5f4c-748c-7a6f-b1ce-18625ef9418e@mellanox.com>
 <87r2xoross.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <ccad80c4-2d1f-2efe-ebf6-29945d84f287@mellanox.com>
 <df578ae3-ec4e-5aca-6b1c-9bdb8db10774@cumulusnetworks.com>
 <c59d8cc0-4601-24d6-414f-a4d8c59b4cfb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        roopa <roopa@cumulusnetworks.com>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:35355 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932497AbdGLLnC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 07:43:02 -0400
Received: by mail-wr0-f180.google.com with SMTP id k67so29897009wrc.2
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 04:43:01 -0700 (PDT)
In-Reply-To: <c59d8cc0-4601-24d6-414f-a4d8c59b4cfb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/17 14:23, Arkadi Sharshevsky wrote:
> 
> 
> On 07/11/2017 06:05 PM, Nikolay Aleksandrov wrote:
>> On 11/07/17 13:26, Arkadi Sharshevsky wrote:
>>>
>>>
>>> On 07/10/2017 11:59 PM, Vivien Didelot wrote:
>>>> Hi Arkadi,
>>>>
>>>> Arkadi Sharshevsky <arkadis@mellanox.com> writes:
>>>>
>>>>>>> +		err = dsa_port_fdb_add(p->dp, fdb_info->addr, fdb_info->vid);
>>>>>>> +		if (err) {
>>>>>>> +			netdev_dbg(dev, "fdb add failed err=%d\n", err);
>>>>>>> +			break;
>>>>>>> +		}
>>>>>>> +		call_switchdev_notifiers(SWITCHDEV_FDB_OFFLOADED, dev,
>>>>>>> +					 &fdb_info->info);
>>>>>>> +		break;
>>>>>>> +
>>>>>>> +	case SWITCHDEV_FDB_DEL_TO_DEVICE:
>>>>>>> +		fdb_info = &switchdev_work->fdb_info;
>>>>>>> +		err = dsa_port_fdb_del(p->dp, fdb_info->addr, fdb_info->vid);
>>>>>>> +		if (err)
>>>>>>> +			netdev_dbg(dev, "fdb del failed err=%d\n", err);
>>>>>>
>>>>>> OK I must have missed from the off-list discussion why we are not
>>>>>> calling the switchdev notifier here?
>>>>>
>>>>> We do not agree on it actually, that is why it was moved to the list.
>>>>> I think that delete should succeed, you should retry until succession.
>>>>>
>>>>> The deletion is done under spinlock in the bridge so you cannot block,
>>>>> thus delete cannot fail due to hardware failure. Calling it here doesn't
>>>>> make sense because the bridge probably already deleted this FDB.
>>>>
>>>> So as we discussed, the problem here is that if dsa_port_fdb_del fails
>>>> for some probable reasons (MDIO timeout, weak GPIO lines, etc.), Linux
>>>> bridge will delete the entry in software, dumping bridge fdb will show
>>>> nothing, but the entry would still be programmed in hardware and the
>>>> network can thus be inconsistent, unsupposedly switching frames.
>>>>
>>>> IMHO the correct way for bridge to use the notification chain is to make
>>>> SWITCHDEV_FDB_DEL_TO_DEVICE symmetrical to SWITCHDEV_FDB_ADD_TO_DEVICE:
>>>> if an entry has been marked as offloaded, bridge must mark the entry as
>>>> to-be-deleted and do not delete the software entry until the driver
>>>> notifies back the successful deletion.
>>>>
>>>> If that is hardly feasible due to some bridge limitations, we must
>>>> explain this in a comment and use something more explosive than a simple
>>>> netdev_dbg to warn the user about the broken network setup...
>>>>
>>>>
>>>> Thanks,
>>>>
>>>>         Vivien
>>>>
>>>
>>> Hi Nikolay,
>>>
>>> Vivien raised inconsistency issue with the current switchdev
>>> notification chain in case of FDB del. In case of static FDB delete,
>>> notification will be sent to the driver, followed by deletion of the
>>> software entry without waiting for the hardware delete. In case of
>>> hardware deletion failure the consecutive FDB dump will not show the
>>> deleted entry, yet, the entry will stay in hardware.
>>>
>>> The deletion is done under lock thus the hardware deletion is deferred,
>>> and cannot fail due to hardware removal failure. Thus the above proposed
>>> solution by Vivien can lead to confusing situation:
>>>
>>> 1. User deletes the entry
>>> 2. Deletion succeed
>>> 3. User dumps FDB and still sees this entry due to hardware failure,
>>>    what should he do? retry to delete until the FDB dump will not show
>>>    the entry?
>>>
>>> Would like to hear you opinion about this solution.
>>>
>>> IMHO in this case the driver should retry to delete, in case of
>>> several retries the driver should maybe:
>>> 1. Trap the traffic to CPU (dint think it possible in case of DSA).
>>> 2. Disable the port (its more explosive then netdev_dbg).
>>>
>>> Thanks,
>>> Arkadi
>>>
>>>
>>
>> Hi,
>> Looking at the code - it would seem that retrying is the only current option
>> with the way these switchdev notifications are handled. They cannot fail, meaning
>> from the bridge POV these ops must always succeed and errors are ignored, so the
>> driver should do everything possible to stay in sync, and in case all fails
>> then disabling the port seems like the best option to me, to show that something is
>> clearly wrong and avoid further issues, but DSA maintainers can comment more
>> on how to handle failure.
>>
>> That being said:
>> This sounds a lot like the switchdev notifications vs callbacks discussions that we've
>> had in the past. Also what happened with the prepare+commit and all that ? If the hash_lock
>> is the main problem let's work towards improving that and making the fdb code handle
>> switchdev similar to the vlan code.
>>
>> Cheers,
>>  Nik
>>
> 
> Vlans can be only added by user under rtnl so its possible to sleep. On
> the other hand FDBs can be learned in atomic context, thus the
> notification chain is atomic. One Possible way I thought about doing it

Right, that's why I mentioned the hash_lock. :-)

> is to maintain bridge internal ordered workqueue for the FDBs learned in
> atomic context, furthermore the FDB table will be protected by mutex.
> The STATIC entries are added in user context so the user will add
> directly to this hash table and could sleep.

I was thinking in the same direction but instead just keep per-cpu
delayed learning lists that get emptied (i.e. learned) from a workqueue
that gets scheduled from atomic context, but it seems to me the
complexity is unjustified if the drivers can handle the errors, they're
the only reason for doing this right now.

So options so far look like:
1) return success & driver retry until op is successful or deal with
fallout (e.g. disable hw fwd, disable port etc)
2) move to mutex so we can fail the user requested op on hw failure
3) return success but don't actually delete fdb until hw succeeds

In the current situation 1) seems like a good option as we discussed, I
don't like 3). 2) and similar alternatives can be discussed further, I
have plans to migrate the fdb code to a rhashtable and can adjust the
change for it.

> 
> Its not very good, but I don't think about another solution here.
> 
> Regarding notification or not, drivers should know about FDBs that are
> not directly related to them like in case of vxlan (vxlan device is not
> upper device of some siwthcdev port) so notification is better approach
> in my opinion.
> 
> Regarding prepare/commit, it is not used in mlxsw. And we would like
> to remove it from DSA (in case of FDBs). The prepare phase cannot
> assure success because errors could happen unrelated to reserved space
> in the switch in the commit stage..
> 

Yeah, I figured as much.

> Thanks,
> Arkadi
>>

Cheers,
 Nik

>>
>>
>>
>>
>>
>>
>>
