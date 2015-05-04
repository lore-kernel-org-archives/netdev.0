From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Sun, 03 May 2015 20:56:53 -0700
Message-ID: <5546EE05.1060206@cumulusnetworks.com>
References: <1430583883-3514-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCDG614esO1UByPYoX47+zzjr=Ed6LNPbqTKG7Nvnsm3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	john fastabend <john.fastabend@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34251 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbbEDD4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 23:56:55 -0400
Received: by pdbqa5 with SMTP id qa5so152041145pdb.1
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 20:56:55 -0700 (PDT)
In-Reply-To: <CAE4R7bCDG614esO1UByPYoX47+zzjr=Ed6LNPbqTKG7Nvnsm3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/15, 10:45 AM, Scott Feldman wrote:
> On Sat, May 2, 2015 at 9:24 AM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This basically removes the calls to netdev_switch_fib_ipv4_abort when
>> there is an error in programming fib entry in hardware.
>>
>> On most systems where you can offload routes to hardware,
>> doing routing in software is not an option (the cpu's are not powerful
>> to route in software).
>>
>> I understand that this was added to keep the first fib offload support
>> simple. This RFC patch is to start a discussion around why the fib
>> abort will not work for most hardware and to discuss alternate options
>> for default behaviour.
> Thanks for revisiting this topic.  Agreed, current arrangement isn't
> practical for real offload devices with limited CPU support.
>
>> Available options:
>> a) Dont abort hardware offload and return appropriate error to the user on
>> fib offload failure by default (this patch)
>> b) make the behaviour in a) conditional on a global flag/sysctl (a per fib
>> entry flag will not work because by default user/routing-daemons dont care
>> if they are hardware offloaded)
>> c) for the users/routing-daemons interested in controlling the hardware
>> offload behaviour there is always the per fib entry flag RTF_F_EXTERNAL
>> (and special error codes -EOFFLOAD could perhaps indicate that the
>> hardware offload failed)
>>
>> Considering the characteristics of the systems that support fib offloads,
>> a) above seems to be the right default.
> Going with option a) puts a burden on the user: on failure, the user
> may or may not understand why the operation failed.  Or worse, the
> routing protocol may not make the failure obvious to the user, so the
> user is unaware or unsure why routes aren't getting installed.  With
> the current solution, routes are still installed even if there was a
> failure to offload, so the user doesn't care (yes, whimpy CPU would
> make the user care :).
>
> Anyway, I'd prefer to see an option c) -like solution where we force
> user to explicitly indicate route offload (by setting
> RTNH_F_EXTERNAL).  The default would be no offload.  The apps
> (iproute2 + routing protocols) would need to be updated to support
> setting this new flag.  This way, the user participates at the app
> level in setting the flag and if there is a failure, the user would be
> aware and can react.
I agree with you that there should be an option c), but making it the 
default is a problem
which i am trying to avoid. An example routing daemon like quagga should 
work
on a server with no l3  acceleration and the same app should continue
working on a switch with l3 acceleration. Changing apps to use
hardware acceleration will not be a welcomed IMO. I am afraid it will slow
down adoption of these apps on switches. And we do want to see these
linux networking apps running on switches the same way they ran on a server.

As you know, we (@cumulus) can run many networking apps (more than one 
routing daemon)
on our switches today only because apps can use the existing kernel API 
without
having to change to use special flags.

>    (switchdev driver can return meaningful err
> codes, such as ENOSPC for hw route tables full, for example).
>
> With c), the user must be aware that offloaded routes take priority
> over non-offloaded routes.  It's as if there is a new ip rule -1
> that's higher priority than the kernel's ip rule 0.  ip rule -1 says
> look up in offload device first.
I see that some systems could maybe use this (I dont know of any right 
now..but
maybe in the future ?).

I can submit patches with the required implementation to cover option c) ...
but i would prefer a way to see a) being the default to enable more apps 
to run
on a switch seamlessly.

>
>> PS: This patch currently removes use of the netdev_switch_fib_ipv4_abort
>> function but not the function itself. This will be fixed if we converge
>> on the default behaviour.
> I'd prefer a full cleanup, including removal of
> ipv4.fib_offload_disabled, rather than leaving orphaned code.
ack, I will post a full patch once we converge.

Thanks for the review.
