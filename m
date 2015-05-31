From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Sat, 30 May 2015 23:34:07 -0700
Message-ID: <CAE4R7bAr1RM+p2Odc3gXmVoYVw7H3A3+iLAb53PHaTfB-d4pyA@mail.gmail.com>
References: <555AD11E.5040709@cumulusnetworks.com>
	<20150519.123418.481170679256206928.davem@davemloft.net>
	<20150519194731.GK9559@gospo.home.greyhouse.net>
	<20150519.162845.955021778058631119.davem@davemloft.net>
	<CAE4R7bAB2+Oy92w9RpLKL5LUq7gP1mBazBK9y4ZQ4b0k8t2WhQ@mail.gmail.com>
	<20150529075003.GA11638@nanopsycho.orion>
	<CAE4R7bDSbVo7ryzHktLWtA07RswT929bhWpYwpLZUkv1eQB1tw@mail.gmail.com>
	<20150530090057.GA1929@nanopsycho.orion>
	<556A8BD8.30604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:36429 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbbEaGeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:34:08 -0400
Received: by qkx62 with SMTP id 62so68066934qkx.3
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 23:34:08 -0700 (PDT)
In-Reply-To: <556A8BD8.30604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2015 at 9:19 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 05/30/2015 02:00 AM, Jiri Pirko wrote:
>>
>> Fri, May 29, 2015 at 05:39:46PM CEST, sfeldma@gmail.com wrote:
>>>
>>> On Fri, May 29, 2015 at 12:50 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>
>>>> Thu, May 21, 2015 at 07:46:54AM CEST, sfeldma@gmail.com wrote:
>>>>>
>>>>> On Tue, May 19, 2015 at 1:28 PM, David Miller <davem@davemloft.net>
>>>>> wrote:
>>>>>>
>>>>>> From: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>>>> Date: Tue, 19 May 2015 15:47:32 -0400
>>>>>>
>>>>>>> Are you actually saying that if users complain loudly enough about
>>>>>>> the current behavior (not the change Roopa has proposed) that you
>>>>>>> would be open to considering a change the current behavior?
>>>>>>
>>>>>>
>>>>>> I am saying that we have a contract with users not to break existing
>>>>>> behavior.  Full stop.
>>>>>
>>>>>
>>>>> After rehearing David's argument, we should probably explore option d)
>>>>> which is a refinement on the fib_offload_disable mechanism we have
>>>>> today.  fib_offload_disable is global for all routes.  Once we hit a
>>>>> HW install problem, the global flag is set and all routes fallback to
>>>>> SW.  We did this because we can't allow the failed route to exist in
>>>>> SW and not in HW because it could mess up LPM searches (HW could hit
>>>>> on a lesser prefix even when SW has the true LPM, because HW gets
>>>>> first shot at match).  The refinement on fib_offload_disable is this:
>>>>> make it per-related-prefix rather than global, and on a HW install
>>>>> problem, set the flag for the related-prefix and uninstall only those
>>>>> routes from HW.  Related-prefix (is there a correct term for this?)
>>>>> are routes to the same dst addr but with different prefix lengths.  I
>>>>> haven't parsed the fib_trie structure to see how routes are organized,
>>>>> but I suspect since it's optimized for lookup the related-prefix
>>>>> tracking is already there and we can build on that.
>>>>
>>>>
>>>> This looks interesting. However, I'm not sure that it is acceptable for
>>>> user to experience this hw evict of "random entries". User knows what
>>>> entries are essential to have in hw. With your solution, I can see no
>>>> way
>>>> user can actually say what should be offloaded or not. Kernel just
>>>> automagically decides.
>>>
>>>
>>> The default eviction policy could be based on RTA_PRIORITY: evict
>>> lower priority routes first.  It would be up to the device driver to
>>> decide between two routes of same priority.
>>>
>>> To help device driver make the decision, we could have eviction policy
>>> options:
>>>
>>>     Priority-base (default)
>>>     Prefer IPv6 over IPv4
>>>     Prefer IPv4 over IPv6
>>>     Prefer single path over multipath
>>>     Prefer longer prefix lengths over shorter
>>>     Optimize for resource utilization
>>>
>>> These are portable across different switches.   They're in terms a
>>> user understands.  It's up to the device driver which truly
>>> understands the device constraints to translates the user's eviction
>>> policy choices into something that makes sense to that device.
>>
>>
>> This sounds tempting... You plan to throw in some patches, or should I
>> take care of that?
>>
>
> This is encoding specific policies into the kernel. I was hoping to
> avoid this and let user space develop whatever policy it wants. If you
> use Jiri's proposed NLM_F_SKIP_{KERNEL|OFFLOAD} flags you get this.
>
> Also I don't understand the "truly  understands the device constraints"
> comment. We can export a model of the device and know how many rules
> of each type will fit exactly into the table. This doesn't seem like
> much of a problem to me. In fact the driver developer should know this
> anyway.
>
> Part of my motivation here is I really don't want to get stuck with a
> case where each driver writer gets to translate the eviction policy
> onto their device in some device specific and slightly different way.

But this is _exactly_ what I want.  Here's why: my claim is it will be
impossible for us (device vendors) to define a universal set of
resource constraints that works for all devices from all vendors.  I
was kind of hoping some vendor would throw out a set to get us
started.  Ok, I'll start with rocker: rocker will enforce in the
device these constraints listed below.  There will be a device command
to query the raw constraints.   So here goes:

VLAN table max entries: 16K     // a VLAN on a port takes one entry
Term MAC table max entries: no limit
Bridging table:
     Unicast max entries: 12K
     Multicast max entries: 4K
Unicast Routing table (shared for v4 and v6 entries):
     Prefix max slots: 16K
         IPv4 route takes one slot
         IPv6 prefix len <= 64 route takes two slots
         IPv6 prefix len > 64 takes four slots
    Nexthop max slots: 4K
         Max ECMP width: 32
         Each nexthop MAC takes one slot, but there is a stride of 4 slots
Multicast Routing table (shared for v4 and v6 entries):
    (same as unicast routing, except max slots are 1/2 as big)
ACL table:
    IPv4 max entries: 8K
    IPv6 max entries: 8K
    Combined IPv4 and IPv6 entries: 12K

The table names are OF-DPA-specific.  The limits are contrived,
obviously, but are representative of real-world devices.  The v4/v6
splits are a PITA, but a reality.

Ok, your turn.  Let's see a list of constraints for a device you care
about and see what the union between rocker and yours is.  Maybe
others can contribute their lists?  My expectation is the union of all
these lists is something not implementable.  And we want to push this
to the user so they can tune their application, and run their
application on multiple switches?

> It means every developer has to write a new mapping and get it correct.
> At very least we should put a layer in switchdev that reads the table
> out of the driver and does the mapping so we have it one spot. At least
> then the kernel is enforcing policy the same on all devices. Better
> still IMO would be to develop the policy in user space and have a
> library/tool that does this so we don't end up with a bunch of policy
> blobs in the kernel. The 6 above is a good start but over time we more
> policy blobs will surely pop up. I would for example put 'optimize for
> throughput' on the list.

I don't even know what 'optimize for throughput' means in the context
offloading fib entries.  I'm curious, what is an example?
