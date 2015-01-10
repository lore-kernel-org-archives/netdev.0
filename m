From: B Viswanath <marichika4@gmail.com>
Subject: Re: Clarification regarding IFLA_BRPORT_LEARNING_SYNC and aging of
 fdb entries learnt via br_fdb_external_learn_add()
Date: Sat, 10 Jan 2015 08:01:25 +0530
Message-ID: <CAN+pFwKfss3m7+B1ZkauKwvHFEdsO_sUMfYixDc8+vevRhYHbA@mail.gmail.com>
References: <CA+CtxLSv6Hg9kOmavqQKs+7y8b8+TBdW1dYwb3ZsTMOh=Ow8Ew@mail.gmail.com>
	<20150107125301.GE1888@nanopsycho.orion>
	<CAE4R7bBRboCfhRKFKgVVAGt1f-m6wkXNfaej4RjuaCKPypABeA@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505DDA643@ORSMSX101.amr.corp.intel.com>
	<CAE4R7bCVCwPNq44_Ax2RQvtdZg_LCHGTQW0RrRAs-jCiDUduzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:44543 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbbAJCb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 21:31:26 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so11813451qcr.0
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 18:31:25 -0800 (PST)
In-Reply-To: <CAE4R7bCVCwPNq44_Ax2RQvtdZg_LCHGTQW0RrRAs-jCiDUduzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scot,

I think we can see the problem in case 1 itself.

Driver's can't periodically update kernel about refreshing the fdb
entry in reality. Some of the switches I worked on a while ago have
16K entries in a MAC table, Surely it has grown folds now. For the
driver to be able to refresh kernel periodically would be a nightmare,
performance wise, to poll this many entries from hardware, see which
of them is updated.

The driver is updating the kernel about learnt entry. I think it makes
sence to have driver update the kernel about ageing too.

Thanks
Viswanath

On 10 January 2015 at 00:17, Scott Feldman <sfeldma@gmail.com> wrote:
> On Fri, Jan 9, 2015 at 8:15 AM, Arad, Ronen <ronen.arad@intel.com> wrote:
>>
>>
>>>-----Original Message-----
>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>>Behalf Of Scott Feldman
>>>Sent: Friday, January 09, 2015 3:47 AM
>>>To: Jiri Pirko
>>>Cc: Siva Mannem; Netdev
>>>Subject: Re: Clarification regarding IFLA_BRPORT_LEARNING_SYNC and aging of
>>>fdb entries learnt via br_fdb_external_learn_add()
>>>
>>>On Wed, Jan 7, 2015 at 4:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Tue, Dec 30, 2014 at 07:20:21PM CET, siva.mannem.lnx@gmail.com wrote:
>>>>>Hi,
>>>>>
>>>>>I am trying to understand the ongoing switch device offload effort and
>>>>>am following the discussions. I have a question regarding
>>>>>IFLA_BRPORT_LEARNING_SYNC flag and how aging happens when this flag is
>>>>>enabled on a port that is attached to a bridge that has vlan filtering
>>>>>enabled.
>>>>>
>>>>>If I understand correctly, when  IFLA_BRPORT_LEARNING_SYNC is set on a
>>>>>bridge port, fdb entries that are learnt externally(may be learnt by
>>>>>hardware and driver is notified) are synced to bridges fdb using
>>>>>br_fdb_external_learn_add(). The fdb
>>>>>entries(fdb->added_by_external_learn set to true) that are learnt via
>>>>>this method are also deleted by the aging logic after the aging time
>>>>>even though L2 data forwadring  happens in hardware.
>>>
>>>This is correct...
>>>
>>>>> Is there a way
>>>>>where aging can be disabled for these entries? and let the entries be
>>>>>removed only via br_fdb_external_learn_delete()? or am I missing
>>>>>something?
>>>>
>>>> Currently extenaly learned fdb entries are indeed removed during aging
>>>> cleanup. I believe that br_fdb_cleanup should check added_by_external_learn
>>>> and not remove that fdbs. What do you think Scott?
>>>
>>>Something like that would work, if we added another brport flag to
>>>control that.  With the current arrangement, using bridge for aging
>>>out entries, we want br_fdb_cleanup removing the external_learned
>>>fdbs, but if there was another brport flag we could fine tune that.
>>>Say new flag is IFLA_BRPORT_AGING_OFFLOAD or something like that.  I'm
>>>not sure how aging settings for the bridge are pushed down to offload
>>>hw, or if there is a different set for hw.
>>>
>>>But, isn't it nice to let Linux bridge control aging?  That way,
>>>bridge -s fdb dump shows nice statistics on fdb entries.  Hardware
>>>isn't involved in the aging processes (other than being told to remove
>>>an entry).  Simple hardware equals simple driver.  Linux remains
>>>control point.
>>>
>> It is indeed simpler. However, if the overhead of reading hit bits from the HW
>> and updating freshness of entries using br_fdb_external_learn_add() is too
>> expensive, it would force such platforms to disable learning sync altogether.
>> Therefore, I believe aging offload flag (could be sufficient at bridge level)
>> and external aging interval (possibly longer than the software aging interval)
>> will encourage drivers to use leaning sync.
>>>-scott
>
> I'm not sure I follow that last part.
>
> Can we list out the use-cases to see what's missing?
>
> Case 1: bridge ages out learned_sync'ed entries
>
> bridge port learning: off
> offload port learning: on
> offload port learning_sync: on
>
> Driver calls br_fdb_external_learn_add() periodically to refresh
> bridge fdb entry
> to keep it from going stale.
> Bridge removes aged out fdb entries (and indirectly tells offload
> device to do the same).
>
> Case 2: offload device/bridge age out entries independently
>
> bridge port learning: on
> offload port learning: on
> offload port learning_sync: off
>
> Bridge ages out its stale learned entries, independent of offload device.
> Offload device ages out its stale learned entries, independent of bridge.
>
> Case 3: ?
>
> Please help me finish the use-case list so we can see what's missing.
>
> -scott
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
