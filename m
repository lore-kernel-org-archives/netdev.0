From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Sun, 08 Mar 2015 07:19:12 -0700
Message-ID: <54FC5A60.7000800@cumulusnetworks.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com> <54F6C788.2010201@cumulusnetworks.com> <20150305080218.GB2033@nanopsycho.orion> <54F86E4B.9040403@cumulusnetworks.com> <CAE4R7bCQHcR4Ne-ssCRRvw0czKxRJfykcBFY6c_9haRF3pRJYA@mail.gmail.com> <54F8C00C.2010303@cumulusnetworks.com> <CAE4R7bAaLxCebc7cuYB9NQ_Duo8a6LvxWDwWOD9Wn8ROWjvDGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37076 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbbCHOTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 10:19:14 -0400
Received: by paceu11 with SMTP id eu11so51789590pac.4
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 07:19:14 -0700 (PDT)
In-Reply-To: <CAE4R7bAaLxCebc7cuYB9NQ_Duo8a6LvxWDwWOD9Wn8ROWjvDGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/6/15, 1:52 AM, Scott Feldman wrote:
> On Thu, Mar 5, 2015 at 12:43 PM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/5/15, 12:06 PM, Scott Feldman wrote:
>>> On Thu, Mar 5, 2015 at 6:55 AM, roopa <roopa@cumulusnetworks.com> wrote:
>>>> On 3/5/15, 12:02 AM, Jiri Pirko wrote:
>>>>> Wed, Mar 04, 2015 at 09:51:20AM CET, roopa@cumulusnetworks.com wrote:
>>>>>> On 3/3/15, 11:02 PM, Scott Feldman wrote:
>>> [cut]
>>>
>>>>>>> Rocker setlink wasn't broken prior to the NETIF_F_HW_SWITCH_OFFLOAD
>>>>>>> patches.
>>>>>>>     Now it is,
>>>>>> sure, I can submit a patch to remove the flag on rocker ports if thats
>>>>>> what
>>>>>> you prefer.
>>>>> I don't believe that Scott prefers that. The offload flag is there not
>>>>> only for this case, but also for many future switch offloading cases.
>>>> I very well understand that.
>>>>> Rocker port have to have that port set by default. I do not really
>>>>> understand why you suggest removing it...
>>>>>
>>>> I was just making sure scott is on board with the use of the flag.
>>>> I added it on rocker ports for l2 and learning might be broken because of
>>>> that. Which i am trying to fix.
>>>> also, scotts l3 patches dont seem to use the flag.
>>> That's an oversight due to work starting on L3 patches way before
>>> NETIF_F_HW_SWITCH_OFFLOAD was introduced ; I'll add checks for that
>>> flag to the L3 patches.
>> ok, i was not sure if you were planning to. I did post a comment on v2.
>>>> So, if the patch in this thread is not the right way to fix it..,.i was
>>>> just
>>>> trying to give scott an option to remove the flag to keep l2 working and
>>>> for
>>>> him to bring back the flag when he is ready.
>>> When I'm ready for what?  I ready for it to work like it did before
>>> NETIF_F_HW_SWITCH_OFFLOAD and your setlink changes went in.  ;-)
>> well, to be fair scott, my current patch in this thread is trying to get to
>> it, if you let me :)
>>
>>> We want two sets of IFLA_PROTINFO attrs for a bridge port.   The first
>>> set is the bridge side of the port, so these attrs like learning or
>>> flooding control the how the bridge (software) manages the port.  The
>>> second set is the device side of the port, so attrs here control how
>>> the (offload) device manages the port.  The two sets are independent.
>>> For example, you could have learning turned OFF on the bridge side and
>>> learning turned ON on the device side.  The device side will
>>> initialize its set.  The bridge will initialize its set.   The user
>>> can see both sets with cmd
>>>
>>>       bridge -d link show.
>>>
>>> The user can set the bridge's attr with one of cmds:
>>>
>>>       bridge link set <attr> dev <port>
>>>       bridge link set <attr> dev <port> master
>>>
>>> The user can set the device's attr with cmd:
>>>
>>>       bridge link set <attr> dev <port> self
>>>
>>> The driver setlink/getlink ops should only be called in the SELF
>>> context because the driver is the SELF side of the port.  Somehow we
>>> got away from that.
>> True, If all attributes that the bridge setlink sets need to go separately
>> to kernel and hardware and
>>   we will never mirror them. That is not the case however. vlans is an
>> example and there will be more bridge port attributes in the future.
>>
>>>    We talked about IFLA_AF_SPEC being handled
>>> differently for VLANs.  For IFLA_PROTINFO, what do we need to get back
>>> to what I have above?
>>
>> If I understand you correctly, you are saying that ndo_bridge_setlink when
>> it comes to offloads
>> should only be used for IFLA_PROTINFO ?
> I'm saying port driver's ndo_bridge_setlink shouldn't be called unless
> SELF is set.  The port driver shouldn't have to check if it's SELF,
> that's my main beef with this patch.  If the app (iproute2) wants to
> mirror an attribute, then it can set both MASTER and SELF.  This is
> consistent with ndo_fdb ops, where MASTER targets the bridge's FDB and
> SELF targets the device's FDB.

bridge setlink/dellink ndo sets/clears bridge port flags, vlans.

4 ways to the ndo op gets called (value in brackets is the bridge flags):

1. ndo_bridge_setlink ()
2. ndo_bridge_setlink (master)
3. ndo_bridge_setlink (self)
4. ndo_bridge_setlink (master | self)


in case of 1) and 2) today, bridge driver also calls into the port 
driver (as part of NETIF_F_HW_SWITCH_OFFLOAD) because vlans and other 
port flags need to be offloaded if they are set on master (I understand 
that rocker does not use bridge setlink ndo op for vlans. But it is 
completely valid for a switch driver to use the ndo setlink op for 
offloading vlan config)

One thing i can do is the NETIF_F_HW_SWITCH_OFFLOAD case only applies in 
case 1 above. ie when bridge flags is zero.

which leads to the following commands to disable learning in the bridge 
driver and enable it in hw,

1. bridge link learning on - enable learning in both rocker and bridge 
driver due to the NETIF_F_HW_SWITCH_OFFLOAD flag
2. bridge link learning off master - learning disable only in the bridge 
driver

With this i think we hit a compromise, rocker setlink can be called when 
flags is zero, but we still get a valid sequence of commands to 
enable/disable certain port flags only in the bridge driver or port 
driver without having an explicit self check in rocker.

(my work laptop is broken..., I will re-post the patch tomorrow if you 
are ok with the plan)
