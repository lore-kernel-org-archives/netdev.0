From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next RFC 05/12] net: dsa: Add support for learning FDB
 through notification
Date: Tue, 11 Jul 2017 13:26:47 +0300
Message-ID: <ccad80c4-2d1f-2efe-ebf6-29945d84f287@mellanox.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-6-git-send-email-arkadis@mellanox.com>
 <424fbf9a-f060-87d1-cad2-36e2ef732bd6@gmail.com>
 <87aa5f4c-748c-7a6f-b1ce-18625ef9418e@mellanox.com>
 <87r2xoross.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0077.outbound.protection.outlook.com ([104.47.1.77]:32231
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751052AbdGKK07 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 06:26:59 -0400
In-Reply-To: <87r2xoross.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/10/2017 11:59 PM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> Arkadi Sharshevsky <arkadis@mellanox.com> writes:
> 
>>>> +		err = dsa_port_fdb_add(p->dp, fdb_info->addr, fdb_info->vid);
>>>> +		if (err) {
>>>> +			netdev_dbg(dev, "fdb add failed err=%d\n", err);
>>>> +			break;
>>>> +		}
>>>> +		call_switchdev_notifiers(SWITCHDEV_FDB_OFFLOADED, dev,
>>>> +					 &fdb_info->info);
>>>> +		break;
>>>> +
>>>> +	case SWITCHDEV_FDB_DEL_TO_DEVICE:
>>>> +		fdb_info = &switchdev_work->fdb_info;
>>>> +		err = dsa_port_fdb_del(p->dp, fdb_info->addr, fdb_info->vid);
>>>> +		if (err)
>>>> +			netdev_dbg(dev, "fdb del failed err=%d\n", err);
>>>
>>> OK I must have missed from the off-list discussion why we are not
>>> calling the switchdev notifier here?
>>
>> We do not agree on it actually, that is why it was moved to the list.
>> I think that delete should succeed, you should retry until succession.
>>
>> The deletion is done under spinlock in the bridge so you cannot block,
>> thus delete cannot fail due to hardware failure. Calling it here doesn't
>> make sense because the bridge probably already deleted this FDB.
> 
> So as we discussed, the problem here is that if dsa_port_fdb_del fails
> for some probable reasons (MDIO timeout, weak GPIO lines, etc.), Linux
> bridge will delete the entry in software, dumping bridge fdb will show
> nothing, but the entry would still be programmed in hardware and the
> network can thus be inconsistent, unsupposedly switching frames.
> 
> IMHO the correct way for bridge to use the notification chain is to make
> SWITCHDEV_FDB_DEL_TO_DEVICE symmetrical to SWITCHDEV_FDB_ADD_TO_DEVICE:
> if an entry has been marked as offloaded, bridge must mark the entry as
> to-be-deleted and do not delete the software entry until the driver
> notifies back the successful deletion.
> 
> If that is hardly feasible due to some bridge limitations, we must
> explain this in a comment and use something more explosive than a simple
> netdev_dbg to warn the user about the broken network setup...
> 
> 
> Thanks,
> 
>         Vivien
> 

Hi Nikolay,

Vivien raised inconsistency issue with the current switchdev
notification chain in case of FDB del. In case of static FDB delete,
notification will be sent to the driver, followed by deletion of the
software entry without waiting for the hardware delete. In case of
hardware deletion failure the consecutive FDB dump will not show the
deleted entry, yet, the entry will stay in hardware.

The deletion is done under lock thus the hardware deletion is deferred,
and cannot fail due to hardware removal failure. Thus the above proposed
solution by Vivien can lead to confusing situation:

1. User deletes the entry
2. Deletion succeed
3. User dumps FDB and still sees this entry due to hardware failure,
   what should he do? retry to delete until the FDB dump will not show
   the entry?

Would like to hear you opinion about this solution.

IMHO in this case the driver should retry to delete, in case of
several retries the driver should maybe:
1. Trap the traffic to CPU (dint think it possible in case of DSA).
2. Disable the port (its more explosive then netdev_dbg).

Thanks,
Arkadi
