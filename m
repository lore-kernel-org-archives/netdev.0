From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Clarification regarding IFLA_BRPORT_LEARNING_SYNC and aging of
 fdb entries learnt via br_fdb_external_learn_add()
Date: Sat, 10 Jan 2015 12:28:36 -0800
Message-ID: <CAE4R7bCLiD7qQX-YFp6be72_jWJM_T6Yf=-MQL_2udph46QD5w@mail.gmail.com>
References: <CA+CtxLSv6Hg9kOmavqQKs+7y8b8+TBdW1dYwb3ZsTMOh=Ow8Ew@mail.gmail.com>
	<20150107125301.GE1888@nanopsycho.orion>
	<CAE4R7bBRboCfhRKFKgVVAGt1f-m6wkXNfaej4RjuaCKPypABeA@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505DDA643@ORSMSX101.amr.corp.intel.com>
	<CAE4R7bCVCwPNq44_Ax2RQvtdZg_LCHGTQW0RrRAs-jCiDUduzQ@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505DDA81C@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>, marichika4@gmail.com
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:57789 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbbAJU2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 15:28:38 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so8190422wiv.2
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 12:28:36 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DDA81C@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perfect, I think we have a good working set of use-cases.  Thanks for
adding those.  Your case 3 seems do-able without too much work since
we already know which ones where externally added, just need another
per-bridge-port flag to turn off bridging aging of externally learned
entries.  This will address the performance issue you (and B
Viswanath) raised.  What about the entry stats, from the user's
'bridge -s fdb show" perspective for the bridge fdb entries?  Will
these numbers match expectations?  I think case 1 and case 4 provide a
coherent stats view.  Case 3 seems to be lacking in this regard.

On Fri, Jan 9, 2015 at 10:51 PM, Arad, Ronen <ronen.arad@intel.com> wrote:
> [...]
>>> It is indeed simpler. However, if the overhead of reading hit bits from the
>>HW
>>> and updating freshness of entries using br_fdb_external_learn_add() is too
>>> expensive, it would force such platforms to disable learning sync
>>altogether.
>>> Therefore, I believe aging offload flag (could be sufficient at bridge
>>level)
>>> and external aging interval (possibly longer than the software aging
>>interval)
>>> will encourage drivers to use leaning sync.
>>>>-scott
>>
>>I'm not sure I follow that last part.
>>
>>Can we list out the use-cases to see what's missing?
>>
>>Case 1: bridge ages out learned_sync'ed entries
>>
>>bridge port learning: off
>>offload port learning: on
>>offload port learning_sync: on
>>
>>Driver calls br_fdb_external_learn_add() periodically to refresh
>>bridge fdb entry
>>to keep it from going stale.
>>Bridge removes aged out fdb entries (and indirectly tells offload
>>device to do the same).
>>
>>Case 2: offload device/bridge age out entries independently
>>
>>bridge port learning: on
>>offload port learning: on
>>offload port learning_sync: off
>>
>>Bridge ages out its stale learned entries, independent of offload device.
>>Offload device ages out its stale learned entries, independent of bridge.
>>
>>Case 3: ?
>>
>>Please help me finish the use-case list so we can see what's missing.
>
>
> Case 3: offload device ages out external entries and notifies bridge
>
> bridge port learning: on or off (Bridge only learns from packets seen (Rx/Tx))
> offload port learning: on
> offload port learning_sync: on
> bridge aging of external learn: off
> offload device aging: on
>
> Switch port/device driver ages entries (could be by HW aging or soft aging in
> driver/firmware),
> notifies bridge about aged entries using br_fdb_externallearn_del().
> This allows efficient HW aging and batched notification at a pace independent
> of bridge aging interval.
> User still enjoys a single VLAN-aware FDB within the bridge module and having
> all entries in one place. Externally learned entries are identified as such by
> iproute2 "bridge fdb show" command. Device does not have to implement
> ndo_bridge_fdb_dump() for each offload port as the bridge module provides it
> for the common FDB.
>
> Case 4: bridge ages owned and external entries at different intervals
>
> bridge port learning: on (Effectively only for Rx/Tx traffic seen by
>                           software bridge)
> offload port learning: on (transient traffic and RxTx, overlap with bridge
>                            learned entries possible)
> offload port learning_sync: on
> bridge aging of external learn: on
> offload device aging: off
> bridge aging interval for owned entries: T1
> bridge aging interval for external entries: T2 (Typically T2 > T1)
>
> This allows for fine-tuning the overhead of periodic updates of entries
> freshness from offload port device.
>
> The bottom line of cases 3-4 is that it is desirable to use the common bridge
> FDB as long as bridge aging of externally learned entries could be controlled
> by the offload device: Either be at a longer interval or disabled.
>
>>
>>-scott
>>--
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
