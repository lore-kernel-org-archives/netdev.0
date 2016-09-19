From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/2] fib4 offload: notifier to let hw to be
 aware of all prefixes
Date: Mon, 19 Sep 2016 09:44:07 -0700
Message-ID: <da14a1ab-5acf-fa04-c321-38b346a0abe7@gmail.com>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <fc177125-a9b8-fcce-281b-5fdc25639944@gmail.com>
 <20160919060854.GB1846@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33940 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751866AbcISQoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 12:44:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id 21so6074573pfy.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 09:44:09 -0700 (PDT)
In-Reply-To: <20160919060854.GB1846@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2016 11:08 PM, Jiri Pirko wrote:
> Sun, Sep 18, 2016 at 10:00:44PM CEST, f.fainelli@gmail.com wrote:
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
>>
>> Instead of introducing another specialization of a notifier_block
>> implementation, could we somehow have a kernel-based netlink listener
>> which receives the same kind of event information from rtmsg_fib()?
> 
> rtmsg_fib destination is userspace. The message format is netlink. I
> don't think it is wise to pass netlink messages inside kernel when we
> can pass nice structures.

True, which does not mean you cannot have a small piece of kernel code
that listens for netlink events and unmarshalls what you want to have
your drivers operate on a structure-based message. The point I am
getting it is that rtmsg_* exists all over the place, and with close to
zero modification in the networking stack you can get the notification
you want if you hook a netlink listener in kernel space. Just like the
notifier you are proposing, the interface drivers could work with can be
structure (and not netlink message) based. An argument could be made
that with the notifier approach and hooking where necessary you have
finer control of message delivery, especially for managing overhead and
potential subscribers to these messages (it is easier to compile out the
notifier code for what you are interested in).


> Lower overhead. This is how it is done in the
> rest of kernel. Not sure how your comment is related specifically to
> this patch.

This is not directly related to your patch, it just made me think about
it as I was considering adding a notifier for other purposes (turns out
we may be able to do differently, without one).
-- 
Florian
