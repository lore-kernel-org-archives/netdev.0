From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Clarification regarding IFLA_BRPORT_LEARNING_SYNC and aging of
 fdb entries learnt via br_fdb_external_learn_add()
Date: Thu, 8 Jan 2015 17:46:46 -0800
Message-ID: <CAE4R7bBRboCfhRKFKgVVAGt1f-m6wkXNfaej4RjuaCKPypABeA@mail.gmail.com>
References: <CA+CtxLSv6Hg9kOmavqQKs+7y8b8+TBdW1dYwb3ZsTMOh=Ow8Ew@mail.gmail.com>
	<20150107125301.GE1888@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Siva Mannem <siva.mannem.lnx@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:39798 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbbAIBqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 20:46:48 -0500
Received: by mail-wg0-f42.google.com with SMTP id k14so5689978wgh.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 17:46:46 -0800 (PST)
In-Reply-To: <20150107125301.GE1888@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 4:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Dec 30, 2014 at 07:20:21PM CET, siva.mannem.lnx@gmail.com wrote:
>>Hi,
>>
>>I am trying to understand the ongoing switch device offload effort and
>>am following the discussions. I have a question regarding
>>IFLA_BRPORT_LEARNING_SYNC flag and how aging happens when this flag is
>>enabled on a port that is attached to a bridge that has vlan filtering
>>enabled.
>>
>>If I understand correctly, when  IFLA_BRPORT_LEARNING_SYNC is set on a
>>bridge port, fdb entries that are learnt externally(may be learnt by
>>hardware and driver is notified) are synced to bridges fdb using
>>br_fdb_external_learn_add(). The fdb
>>entries(fdb->added_by_external_learn set to true) that are learnt via
>>this method are also deleted by the aging logic after the aging time
>>even though L2 data forwadring  happens in hardware.

This is correct...

>> Is there a way
>>where aging can be disabled for these entries? and let the entries be
>>removed only via br_fdb_external_learn_delete()? or am I missing
>>something?
>
> Currently extenaly learned fdb entries are indeed removed during aging
> cleanup. I believe that br_fdb_cleanup should check added_by_external_learn
> and not remove that fdbs. What do you think Scott?

Something like that would work, if we added another brport flag to
control that.  With the current arrangement, using bridge for aging
out entries, we want br_fdb_cleanup removing the external_learned
fdbs, but if there was another brport flag we could fine tune that.
Say new flag is IFLA_BRPORT_AGING_OFFLOAD or something like that.  I'm
not sure how aging settings for the bridge are pushed down to offload
hw, or if there is a different set for hw.

But, isn't it nice to let Linux bridge control aging?  That way,
bridge -s fdb dump shows nice statistics on fdb entries.  Hardware
isn't involved in the aging processes (other than being told to remove
an entry).  Simple hardware equals simple driver.  Linux remains
control point.

-scott
