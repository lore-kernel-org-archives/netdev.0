From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Thu, 28 May 2015 22:37:14 -0700
Message-ID: <5567FB0A.1060900@cumulusnetworks.com>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com> <20150518.161916.2132217836491222672.davem@davemloft.net> <20150528094244.GA19629@nanopsycho.orion> <CAE4R7bB-LazvjPYZmPRE8e-mq_vML+jCBswMkOq-QeV-8ad41A@mail.gmail.com> <55673DF5.7060401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36165 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbbE2FhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 01:37:16 -0400
Received: by pacux9 with SMTP id ux9so1875462pac.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 22:37:16 -0700 (PDT)
In-Reply-To: <55673DF5.7060401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/28/15, 9:10 AM, John Fastabend wrote:
> On 05/28/2015 08:40 AM, Scott Feldman wrote:
>> On Thu, May 28, 2015 at 2:42 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Mon, May 18, 2015 at 10:19:16PM CEST, davem@davemloft.net wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>> Date: Sun, 17 May 2015 16:42:05 -0700
>>>>
>>>>> On most systems where you can offload routes to hardware,
>>>>> doing routing in software is not an option (the cpu limitations
>>>>> make routing impossible in software).
>>>>
>>>> You absolutely do not get to determine this policy, none of us
>>>> do.
>>>>
>>>> What matters is that by default the damn switch device being there
>>>> is %100 transparent to the user.
>>>>
>>>> And the way to achieve that default is to do software routes as
>>>> a fallback.
>>>>
>>>> I am not going to entertain changes of this nature which fail
>>>> route loading by default just because we've exceeded a device's
>>>> HW capacity to offload.
>>>>
>>>> I thought I was _really_ clear about this at netdev 0.1
>>>
>>> I certainly agree that by default, transparency 1:1 sw:hw mapping is
>>> what we need for fib. The current code is a good start!
>>>
>>> I see couple of issues regarding switchdev_fib_ipv4_abort:
>>> 1) If user adds and entry, switchdev_fib_ipv4_add fails, abort is
>>>     executed -> and, error returned. I would expect that route entry 
>>> should
>>>     be added in this case. The next attempt of adding the same entry 
>>> will
>>>     be successful.
>>>     The current behaviour breaks the transparency you are reffering to.
>>> 2) When switchdev_fib_ipv4_abort happens to be executed, the offload is
>>>     disabled for good (until reboot). That is certainly not nice, 
>>> alhough
>>>     I understand that is the easiest solution for now.
>>>
>>> I believe that we all agree that the 1:1 transparency, although it is a
>>> default, may not be optimal for real-life usage. HW resources are
>>> limited and user does not know them. The danger of hitting _abort and
>>> screwing-up the whole system is huge, unacceptable.
>>>
>>> So here, there are couple of more or less simple things that I 
>>> suggest to
>>> do in order to move a little bit forward:
>>> 1) Introduce system-wide option to switch _abort to just plain fail.
>>>     When HW does not have capacity, do not flush and fallback to sw, 
>>> but
>>>     rather just fail to add the entry. This would not break anything.
>>>     Userspace has to be prepared that entry add could fail.
>>> 2) Introduce a way to propagate resources to userspace. Driver knows 
>>> about
>>>     resources used/available/potentially_available. Switchdev infra 
>>> could
>>>     be extended in order to propagate the info to the user.
>>> 3) Introduce couple of flags for entry add that would alter the default
>>>     behaviour. Something like:
>>>          NLM_F_SKIP_KERNEL
>>>          NLM_F_SKIP_OFFLOAD
>>>     Again, this does not break the current users. On the other hand, 
>>> this
>>>     gives new users a leverage to instruct kernel where the entry 
>>> should
>>>     be added to (or not added to).
>>>
>>> Any thoughts? Objections?
>>
>> I don't like these.  Breaks transparency and forces the user in a
>> position of having to know hardware failures modes (unique to each
>> hardware device).  I presented an option d) which avoids this issues;
>> was it not understood?
>>
>
> Hi Scott,
>
> I understood your proposal. One caveat I had is in response to this,
>
> "Actually, now that I think of it, the device/driver could decide which
> related-prefix to evict from HW, if driver/device wanted to have a
> sense of which routes are more important to offload than other"
>
> hardware/driver/device shouldn't have a sense of which routes are more
> important than others. 

correct. The routing daemons know this best.
> I think this is where the NLM_F_* flags come in.
> If userspace _wants_ to push policy into the kernel about what is
> important it can. If it doesn't we get a sensible heuristic that does
> a reasonable job offloading rules transparently. This is how we did
> L2 and I think that seems to work fairly well. At least for me but,
> always interested to hear other use cases though.
agree.
>
> Also I guess I'm not seeing the multitude of hardware failure modes. I
> see two either the hardware doesn't support the operation or it is out
> of resources. Both can be learned if the hardware exports a model of its
> capabilities and resources.
agree, A switchdev api to query hardware resource and capability is due.
We can start with rocker. It gives an app the choice to control the policy.

But, for our usecase/deployments today,  i am more interested in a 
system wide policy because
it is easier on my apps today.

thanks.
