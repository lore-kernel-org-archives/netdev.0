From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Fri, 28 Nov 2014 02:33:12 -0800
Message-ID: <CAE4R7bBKvc-D=g4CN+uEL8En_6B2aE6gJfq=RO7qS-RusNGkAg@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-3-git-send-email-jiri@resnulli.us>
	<5474A25C.3080505@mojatatu.com>
	<5474A7EE.8000300@intel.com>
	<5474ABF0.60901@mojatatu.com>
	<5474AE9B.6000500@intel.com>
	<5474B353.10802@mojatatu.com>
	<CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com>
	<54784B1D.8090508@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
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
	John Linville <linville@tuxdriver.com>,
	"j
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:51077 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaK1KdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 05:33:17 -0500
Received: by mail-wi0-f178.google.com with SMTP id hi2so10757996wib.5
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 02:33:12 -0800 (PST)
In-Reply-To: <54784B1D.8090508@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 28, 2014 at 2:14 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> On 11/25/14, 6:36 PM, Scott Feldman wrote:
>>
>> On Tue, Nov 25, 2014 at 6:50 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>>>
>>> On 11/25/14 11:30, John Fastabend wrote:
>>>>
>>>> On 11/25/2014 08:18 AM, Jamal Hadi Salim wrote:
>>>>>
>>>>> On 11/25/14 11:01, John Fastabend wrote:
>>>>>>
>>>>>> On 11/25/2014 07:38 AM, Jamal Hadi Salim wrote:
>>>>>>>
>>>>>>> On 11/25/14 05:28, Jiri Pirko wrote:
>>>>>>>>
>>>>>>>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass
>>>>>>>> simple
>>>>>>>> u16 vid to drivers from there.
>>>>>>>>
>>>
>>>> Actually (after having some coffee) this becomes much more useful
>>>> if you return which items failed. Then you can slam the hardware
>>>> with your 100 entries, probably a lot more then that, and come back
>>>> later and clean it up.
>>>>
>>> Yes, that is the general use case.
>>> Unfortunately at the moment we only return codes on a netlink set
>>> direction - but would be a beauty if we could return what succeeded
>>> and didnt in some form of vector.
>>> Note: all is not lost because you can always do a get afterwards and
>>> find what is missing if you got a return code of "partial success".
>>> Just a little less efficient..
>>>
>>>
>>>> We return a bitmask of which operations were successful. So if SW fails
>>>> we have both bits cleared and we abort. When SW is successful we set the
>>>> SW bit and try to program the HW. If its sucessful we set the HW bit if
>>>> its not we abort with an err. Converting this to (1) is not much work
>>>> just skip the abort.
>>>>
>>> Ok, guess i am gonna have to go stare at the code some more.
>>> I thought we returned one of the error codes?
>>> A bitmask would work for a single entry - because you have two
>>> options add to h/ware and/or s/ware. So response is easy to encode.
>>> But if i have 1000 and they are sparsely populated (think an indexed
>>> table and i have indices 1, 23, 45, etc), then a bitmask would be
>>> hard to use.
>>
>> I'm confused by this discussion.  Do I have this right: You want to
>> send 1000 RTM_NEWNEIGHs to PF_BRIDGE with both NTF_MASTER and NTF_SELF
>> set such that 1000 new FBD entries are installed in both (SW) the
>> bridge's FDB and (HW) the port driver's FDB.  My first confusion is
>> why do you want these FBD entries in bridge's FDB?  We're offloading
>> the switching to HW so HW should be handling fwd plane.  If ctrl pkt
>> make it to SW, it can learn those FDB entries; no need for manual
>> install of FDB entry in SW.  It seems to me you only want to use
>> NTF_SELF to install the FDB entry in HW using the port driver.  And an
>> error code is returned for that install.  Since there is only one
>> target (NTF_SELF) there is no need for bitmask return.
>>
> scott, we do have such usecase today. ie , a fdb entry with both NTF_MASTER
> and NTF_SELF set.
> And these fdb entries can come from an external controller. The path to get
> them to the hw is via the kernel.
> The controller can use `bridge fdb add` to add the fdb entries to the kernel
> (with NTF_MASTER) and also indicate in the same message to add the fdb entry
> to hw (with NTF_SELF). And in this model it is assumed that the kernel fdb
> and hw fdb are in sync.

Ya, I understood that from Jamal's explanation.
