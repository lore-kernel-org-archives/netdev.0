From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH] linux: Signal datapath that unaligned Netlink
 message can be received
Date: Fri, 15 Nov 2013 18:29:21 +0800
Message-ID: <CAEP_g=8oWD5Vy7BWpvAT0HA_rVWgrXs2f0nyfYR07Tvzc3SXuA@mail.gmail.com>
References: <51e10053434e3afdf9940d9be7d9f0ff4788d1f7.1384184155.git.tgraf@redhat.com>
 <20131111155014.GC32602@nicira.com> <5280FD6D.9000609@redhat.com>
 <CAEP_g=_KWgmfVkNLPGYr=WjNR=UKSt3PhkqU8PE6Ug3ju2R3ig@mail.gmail.com>
 <52834A8D.9040009@redhat.com> <CAEP_g=_AN7d94XEoXBaurzTttMHVFii+8hfT0b=tHWBkA-hicw@mail.gmail.com>
 <5285EDA1.5060609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Pfaff <blp@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Ben Hutchings <bhutchings@solarflare.com>, fleitner@redhat.com,
	dborkmann@redhat.com, netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:58583 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753347Ab3KOK3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 05:29:42 -0500
Received: by mail-ie0-f177.google.com with SMTP id qd12so4320025ieb.22
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 02:29:42 -0800 (PST)
In-Reply-To: <5285EDA1.5060609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 15, 2013 at 5:47 PM, Thomas Graf <tgraf@redhat.com> wrote:
> On 11/15/2013 10:32 AM, Jesse Gross wrote:
>>
>> On Wed, Nov 13, 2013 at 5:46 PM, Thomas Graf <tgraf@redhat.com> wrote:
>>>
>>> On 11/13/2013 07:11 AM, Jesse Gross wrote:
>>>>
>>>>
>>>> On Mon, Nov 11, 2013 at 11:53 PM, Thomas Graf <tgraf@redhat.com> wrote:
>>>>>
>>>>>
>>>>> On 11/11/2013 04:50 PM, Ben Pfaff wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>> On Mon, Nov 11, 2013 at 04:36:24PM +0100, Thomas Graf wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> Following commit (''netlink: Do not enforce alignment of last Netlink
>>>>>>> attribute''), signal the ability to receive unaligned Netlink
>>>>>>> messages
>>>>>>> to the datapath to enable utilization of zerocopy optimizations.
>>>>>>>
>>>>>>> Signed-off-by: Thomas Graf <tgraf@redhat.com>
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>> Seems OK from a userspace point of view.  I am a little concerned that
>>>>>> downgrading userspace without deleting and re-creating the datapath
>>>>>> (e.g. via "force-reload-kmod") will result in a totally broken setup
>>>>>> since userspace will then drop every packet from the kernel.
>>>>>
>>>>>
>>>>>
>>>>>
>>>>> Is that something that occurs occasionally in installations? Utilizing
>>>>> the version field in the genl header could be used to track this and
>>>>> clear user_features.
>>>>
>>>>
>>>>
>>>> It's probably a good idea. I could see us having more of these
>>>> features flags in the future (although obviously we should try to
>>>> avoid them if possible) and, as Ben said, it would potentially lead to
>>>> a bad state otherwise.
>>>>
>>>> I'm not sure exactly what you have in mind though, can you elaborate a
>>>> little?
>>>
>>>
>>>
>>> My initial thought was to use a version field to notice the replacement
>>> of user space. On second thought that is not required, modifying user
>>> space to provide the user features in OVS_DP_CMD_GET as well will
>>> overwrite the features. Resetting user_features to 0 if not features are
>>> provided will provide backwards compatibility to versions not aware of
>>> user features yet. Thoughts?
>>
>>
>> Hmm, it doesn't really seem ideal to make DP_CMD_GET change settings
>> as it's probably not the expected behavior for most users of the
>> command. One example of where this could be a problem is if it is
>> called from both ovs-dpctl and ovs-vswitch. Usually these would be
>> have the same capabilities but I'm not sure that it's strictly
>> required in all cases. DP_CMD_SET seems like the ideal place to put it
>> but I guess we don't use that at all on existing versions of OVS
>> userspace.
>
>
> Agreed. Ideal and clean is a DP_CMD_SET lookup-or-create that updates
> the user features. That will leave one OVS version to be non backwards
> compatible in terms of downgrading user features.
>
> For that reason we can bump OVS_DATAPATH_VERSION to version 2 and reset
> the user features if we receive a DP_CMD_GET version 1.
>
> It's not a problem if we reset the user features unnecessarily in some
> corner cases such as mismatching ovs-dpctl and vswitchd. The next
> iteration of the patchset has support for memory mapped netlink i/o
> which would still apply.
>
> If you agree to this then I will cook this up.

That seems like a reasonable solution to me.
