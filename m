From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Thu, 27 Nov 2014 11:36:26 -0800
Message-ID: <54777D3A.6070903@gmail.com>
References: <E4CD12F19ABA0C4D8729E087A761DC3505D7E13E@ORSMSX101.amr.corp.intel.com> <CAE4R7bC9o4ucO_Erb0tU4EwJNYj8SrapbKxNWvUTL8YD=RMBJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36660 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbaK0Tgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 14:36:49 -0500
Received: by mail-ob0-f175.google.com with SMTP id wp4so4123093obc.20
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 11:36:48 -0800 (PST)
In-Reply-To: <CAE4R7bC9o4ucO_Erb0tU4EwJNYj8SrapbKxNWvUTL8YD=RMBJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 11:03 PM, Scott Feldman wrote:
> On Tue, Nov 25, 2014 at 9:37 PM, Arad, Ronen <ronen.arad@intel.com> wrote:
>>>>>>
>>>>>> Is there any case where this fdb entry gets re-used and is no
>>>>>> longer added by an external learning? Should we clear this flag somewhere?
>>>>>
>>>>> Once the FDB entry is marked "added_by_external_learn" it stays
>>>>> marked as such until removed by aging cleanup process (or flushed
>>>>> due to interface down, etc).  If aged out (and now deleted), the
>>>>> FDB entry may come back either by SW learn or by HW learn.  If SW
>>>>> learn comes first, and then HW learn, HW learn will override and
>>>>> mark the existing FDB entry "added_by_external_learn".  So there is
>>>>> take-over by HW but no give-back to SW.  And there is no explicit
>>>>> clearing of the mark short of deleting the FDB entry.  The mark is
>>>>> mostly for letting user's know which FDB entries where learned by
>>>>> HW and synced to the bridge's FDB.
>>>>
>>>> Thanks, makes sense now. This is probably obvious in this context,
>>>> but maybe it would not hurt to come up with a documentation that
>>>> describe the offload API, FDB entry lifetime and HW/SW ownership etc...
>>>
>>> I have an updated Documentation/networking/switchdev.txt that covers
>>> the swdev APIs and usage and notes, but Jiri is being stingy with it.
>>> Will get this out, either in v4 or follow-on patches.  There is enough
>>> going on just with L2 offload that we're going to need some good
>>> documentation to guide implementers.
>>> --
>>
>> To control the lifetime of an externally learned FDB entry, the bridge shall provide an API for the switch driver to update the freshness of externally learned entries. Otherwise, the bridge aging will age entries which are currently or frequently used by the HW.
>> Is this covered in the updated document?
>> Is this functionality planned for v4?
>
> Hi Ronen,
>
> It's already there: driver calls br_fdb_external_learn_add() to
> refresh FBD entry, which updates the fdb->updated and fdb->used
> timestamps, preventing bridge from prematurely aging out the entry.
> We'll make sure that detail gets in the doc.  It's up to the driver on
> how frequently it calls br_fdb_external_learn_add().  Maybe it just
> blindly makes the call every 1s.  That's what rocker driver does (as
> long as the FDB entry continues to get hits).  From the user's
> perspective, 1s update is nice when looking at the stats dump for
> fdbs, since the timestamps are in secs.
>
> -scott

We could at some point add a driver knob to set the timing of the
updates as well, but I don't see the need for it yet. Rocker switch
doesn't need it but if vendors devices want to do this it wouldn't
be difficult.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
