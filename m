From: "Fastabend, John R" <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Wed, 3 Feb 2016 10:48:43 -0800
Message-ID: <56B24B8B.1010205@gmail.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203101109.GB20905@office.Home> <56B1D4A9.3050801@gmail.com>
 <56B1D713.3080803@mellanox.com> <56B1F0C9.3020802@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jiri@resnulli.us, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33809 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965788AbcBCStI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 13:49:08 -0500
Received: by mail-ob0-f169.google.com with SMTP id wb13so43833848obb.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 10:49:07 -0800 (PST)
In-Reply-To: <56B1F0C9.3020802@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/2016 4:21 AM, Jamal Hadi Salim wrote:
> On 16-02-03 05:31 AM, Or Gerlitz wrote:
>> On 2/3/2016 12:21 PM, John Fastabend wrote:
>>> Thanks, we will need at least a v2 to fixup some build errors
>>> with various compile flags caught by build_bot and missed by me.
>> Hi John,
>>
>> You didn't mark that as RFC... but we said this direction/approach yet
>> to be talked @ netdev next-week, so.. can you clarify?

Yeah I think this set of patches is ready and it really is what we've
been talking about doing for two or three conferences now. Also I don't
know where "we" decided to talk about this @ netdev or how that became
a prereq for patches. I think this is the correct approach and I am not
seeing any contentious pieces here so why not consider it for inclusion.
Do you have some issue with the approach? I don't recall any when we
talked about this last time.

>>
>> I suggest not to rush and asking pulling this, lets have the tc workshop
>> beforehand...
>>

rush? we've been talking about it for a year+

> 
> Yes, the tc workshop is a good place for this.
> I think we can spill some of it into the switchdev workshop (which is a
> nice flow since that happens later).
> 

Sure but this patch is really the basic stuff we should move on to
some of the more interesting pieces. I have ~30 or so patches behind
this that do the fun stuff like resource allocation, capababilities,
support for the divisor > 1, some new actions, etc.

> Some comments:
> 1) "priorities" for filters and some form of "index" for actions is
> is needed. I think index (which tends to be a 32 bit value is what
> Amir's patches refered to as "cookie" - or at least some hardware
> can be used to query the action with). Priorities maybe implicit in
> the order in which they are added. And th idea of appending vs
> exclusivity vs replace (which  netlink already supports)
> is important to worry about (TCAMS tend to assume an append mode
> for example).

The code denotes add/del/replace already. I'm not sure why a TCAM
would assume an append mode but OK maybe that is some API you have
the APIs I use don't have these semantics.

For this series using cls_u32 the handle gives you everything you need
to put entries in the right table and row. Namely the ht # and order #
from 'tc'. Take a look at u32_change and u32_classify its the handle
that places the filter into the list and the handle that is matched in
classify. We should place the filters in the hardware in the same order
that is used by u32_change.

Also ran a few tests and can't see how priority works in u32 maybe you
can shed some light but as best I can tell it doesn't have any effect
on rule execution.

> 
> 2) I like the u32 approach where it makes sense; but sometimes it
> doesnt make sense from a usability pov. I work with some ASICs
> that have 10 tuples that are  fixed. Yes, a user can describe a policy
> with u32 but flower would be more  usable say with flower (both
> programmatic and cli)

Sure so create a set of offload hooks for flower we don't need only
one hardware classifier any more than we would like a single software
classifiers. I'll send out my flower patches when I get to a real system
I'm on a corporate laptop at the moment.

> 
> 3) The concept of "hook address" is important to be able to express.
> Amir's patches seemed to miss that (and John brought it up in an
> email). It could be as simple as ifindex + hookid. With ifindex of
> 0 meaning all ports and maybe hookid of 0 meaning all hooks.
> Hook semantics are as mentioned by John (as it stands right now
> in/egress)
> 

Again I'm trying to faithfully implement what we have in software
and load that into the hardware. The handle today gives ingress/egres
hook. If you want an all ports hook we should add it to 'tc' software
first and then push that to the hardware not create magic hardware
bits. See I've drank the cool aid software first than hardware.

> 4) Why are we forsaking switchdev John?
> This is certainly re-usable beyond NICs and SRIOV.
> 

Sure and switchdev can use it just like they use fdb_add and friends.
I just don't want to require switchdev infrastructure on things that
really are not switches. I think Amir indicated he would take a try
at the switchdev integration. If not I'm willing to do it but it
doesn't block this series in any way imo.

> 5)What happened to being both able to hardware and/or software?

Follow up patch once we get the basic infrastructure in place with
the big feature flag bit. I have a patch I'm testing for this now
but again I want to move in logical and somewhat minimal sets.

> 
> Anyways, I think Seville would be a blast! Come one, come all.
> 

I'll be there but lets be sure to follow up with this online I
know folks are following this who wont be at Seville and I don't
see any reason to block these patches and stop the thread for a
week or more.

> cheers,
> jamal
> 
> 
