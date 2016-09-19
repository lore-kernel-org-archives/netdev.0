From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/2] fib4 offload: notifier to let hw to be
 aware of all prefixes
Date: Mon, 19 Sep 2016 08:14:54 +0200
Message-ID: <20160919061454.GC1846@nanopsycho.orion>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <fc177125-a9b8-fcce-281b-5fdc25639944@gmail.com>
 <57DF2041.3040509@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35912 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932428AbcISGO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 02:14:59 -0400
Received: by mail-wm0-f67.google.com with SMTP id b184so13130484wma.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 23:14:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57DF2041.3040509@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 19, 2016 at 01:16:17AM CEST, roopa@cumulusnetworks.com wrote:
>On 9/18/16, 1:00 PM, Florian Fainelli wrote:
>> Le 06/09/2016 à 05:01, Jiri Pirko a écrit :
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This is RFC, unfinished. I came across some issues in the process so I would
>>> like to share those and restart the fib offload discussion in order to make it
>>> really usable.
>>>
>>> So the goal of this patchset is to allow driver to propagate all prefixes
>>> configured in kernel down HW. This is necessary for routing to work
>>> as expected. If we don't do that HW might forward prefixes known to kernel
>>> incorrectly. Take an example when default route is set in switch HW and there
>>> is an IP address set on a management (non-switch) port.
>>>
>>> Currently, only fibs related to the switch port netdev are offloaded using
>>> switchdev ops. This model is not extendable so the first patch introduces
>>> a replacement: notifier to propagate fib additions and removals to whoever
>>> interested. The second patch makes mlxsw to adopt this new way, registering
>>> one notifier block for each mlxsw (asic) instance.
>> Instead of introducing another specialization of a notifier_block
>> implementation, could we somehow have a kernel-based netlink listener
>> which receives the same kind of event information from rtmsg_fib()?
>>
>> The reason is that having such a facility would hook directly onto
>> existing rtmsg_* calls that exist throughout the stack, and that seems
>> to scale better.
>I was thinking along the same lines. Instead of proliferating notifier blocks
>through-out the stack for switchdev offload, putting existing events to use would be nice.
>
>But the problem though is drivers having to parse the netlink msg again. also, the intent
>here is to do the offload first ..before the route is added to the kernel (though i don't see that in
>the current series). existing netlink rmsg_fib events are generated after the route is added to the kernel.
>
>
>Jiri, instead of the notifier, do you see a problem with always calling the existing switchdev
>offload api for every route  for every asic instance ?. the first device where the route fits wins.

There is not list of asic instances. Therefore the notifier fits much better here.



>it seems similar to driver registering for notifier and looking at every route ...
>am i missing something ?
>and the policies you mention could help around selecting the asic instance (FCFS or mirror).
>you will need to abstract out the asic instance for switchdev api to call on, but I thought you
>already have that in some form in your devlink infrastructure.

switchdev asic instances and devlink instances are orthogonal.
