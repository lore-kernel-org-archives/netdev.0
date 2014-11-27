From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Wed, 26 Nov 2014 20:50:50 -1000
Message-ID: <CAE4R7bAM+orLXdEn0qCu2rKj+W5_681RHmvgW4CY5H7jZ0ijfQ@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-3-git-send-email-jiri@resnulli.us>
	<5474A25C.3080505@mojatatu.com>
	<5474A7EE.8000300@intel.com>
	<5474ABF0.60901@mojatatu.com>
	<5474AE9B.6000500@intel.com>
	<5474B353.10802@mojatatu.com>
	<CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com>
	<547546C5.3060207@mojatatu.com>
	<CAE4R7bA2VPZ3tm2MrsXAm4XfNX0TguT=vUma-3HrZSu98hBGyA@mail.gmail.com>
	<5475B952.2080500@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:62094 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaK0Guv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 01:50:51 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so17335801wib.3
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 22:50:50 -0800 (PST)
In-Reply-To: <5475B952.2080500@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 1:28 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/25/14 22:59, Scott Feldman wrote:
>>
>> On Tue, Nov 25, 2014 at 5:19 PM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>>>
>>> On 11/25/14 21:36, Scott Feldman wrote:
>
>
>>>
>>>>> Ok, guess i am gonna have to go stare at the code some more.
>>>>> I thought we returned one of the error codes?
>>>>> A bitmask would work for a single entry - because you have two
>>>>> options add to h/ware and/or s/ware. So response is easy to encode.
>>>>> But if i have 1000 and they are sparsely populated (think an indexed
>>>>> table and i have indices 1, 23, 45, etc), then a bitmask would be
>>>>> hard to use.
>>>>
>>>>
>>>>
>>>> I'm confused by this discussion.
>>>
>>>
>>>
>>> This is about the policy which states "install as many as you can, dont
>>> worry about failures". In such a case, how do you tell user space back
>>> "oh, btw you know your request #1, #23, and 45 went ok, but nothing else
>>> worked". A simple return code wont work. You could return a code to
>>> say "some worked". At which case user space could dump and find out only
>>> #1, #23 and #45 worked.
>>
>>
>> You request for what?  That's my confusion.
>
>
> Scott, you are gonna make do this all over again?;->
> The summary is there are three possible policies that could be
> identified by the user asking for a kernel operation.
> One use case example was to send a bunch of (for example)
> create/updates and request that the kernel should not abort on a
> failure of a single one but to keep going and create/update as many
> as possible. Is that part clear? I know it is not what you do,
> but there are use cases for that (Read John's response).
> Now assuming someone wants this and some entries failed;
> how do you tell user space back what was actually updated vs not?
> You could return a code which says "partial success".
> Forget whether the table is keyed or indexed but if you wanted
> to return more detailed info you would return an array/vector of some
> sort with status code per entry. Something netlink cant do.
> Is that a better description?
>
>> Are you trying to install
>> FDB entry into both SW and HW at same time?
>
>
>
> What is wrong with installing on both hardware and software? The
> point was to identify what kind of policies could be requested by
> the user; but even for the bridge why is it bad that i ask for
> both master&self?
> It is something I can do today with none of these patches.
>
>> And then do a bunch in a
>> batch?  I'm saying use MASTER for SW and SELF for HW in two steps,
>
>
> But that would be enforcing your policy on me.

Ok, I get it now.  I'm looking forward to see what solution people
come up with to solve this.

>
>> if
>> you want FDB entry installed in both Sw and HW.  Check your return
>> code each step.  Batch all to HW first, then batch all that PASSED to
>> SW.  I don't even know really why you're trying to install to both HW
>> and SW.  Install it to HW and be done. fdb_dump will set HW entries
>> via SELF.
>>
>
> First off: bad performance, but your call to do it that way
> (just please please dont enforce it on me;->)
>
> Lets take the hardware batching you mentioned above and see if
> i can help to clarify in the third policy choice (continue-on-failure).
> Lets say you have a keyed table such as the fdb table is.
> You send 10 entries to be created/added in hardware. #3 and #5 failed
> because you made a mistake and sent them with the same key. #9 and #10
> failed because the hardware doesnt have any more space.
> we didnt stop and go back for #3 and #5 because the user told
> us to continue and do the rest when we fail. And s/he did that because
> she wanted to put as many entries in hardware as possible without
> necessarily needing to know how much space exists.
>
>
>> Ah, Jamal, look again at patches 13-17/17 in last v3 set.  That was a
>> big steaming snickerdoodle just for you!  Now you can push policy
>> knobs down to port driver and or bridge to fine tune what ever you
>> want.  You'll find knobs for learning, flooding, learning sync to hw,
>> etc.  I thought you even ACKed some of these.
>
>
> I think it almost there.
> What you are missing is the policy decision to only sync when i
> say so. Having an ndo_ops is a necessity but i dont want the driver
> to decide for me just because it can ;->
> Telling hardware to learn is instructing it to self update its entries
> based on source lookup failure. That is distinctly different from
> telling to sync to the kernel. So if you add that knob we are in good
> shape.

It's there: IFLA_BRPORT_LEARNING_SYNC.  From iproute2:

$ bridge -d link show dev swp1
2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
master br0 state forwarding priority 32 cost 2
    hairpin off guard off root_block off fastleave off learning off flood off
2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0
    learning on learning_sync on hwmode swdev

Turn it off:

$ bridge link set dev swp1 hwmode swdev learning_sync off

And now:

$ bridge -d link show dev swp1
2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
master br0 state forwarding priority 32 cost 2
    hairpin off guard off root_block off fastleave off learning off flood off
2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0
    learning on learning_sync off hwmode swdev


> cheers,
> jamal
>
>
>> a) above knob is 14/17
>> patch, b) above is using existing learning knob on bridge, c) above I
>> don't get...no point in syncing that direction.
>>
>
