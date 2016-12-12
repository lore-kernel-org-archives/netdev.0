From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Soft lockup in tc_classify
Date: Mon, 12 Dec 2016 11:07:25 -0800
Message-ID: <CAM_iQpX=BtDCWxL+Kr2nTu=6pq11NYWSq5AftWhhCKLdERE0kA@mail.gmail.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com> <584EA60B.80803@iogearbox.net>
 <1e715873-34ba-0a76-c94e-064ca4cf895b@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Shahar Klein <shahark@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33973 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752096AbcLLTHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 14:07:46 -0500
Received: by mail-io0-f195.google.com with SMTP id y124so23631381iof.1
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 11:07:46 -0800 (PST)
In-Reply-To: <1e715873-34ba-0a76-c94e-064ca4cf895b@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 8:04 AM, Shahar Klein <shahark@mellanox.com> wrote:
>
>
> On 12/12/2016 3:28 PM, Daniel Borkmann wrote:
>>
>> Hi Shahar,
>>
>> On 12/12/2016 10:43 AM, Shahar Klein wrote:
>>>
>>> Hi All,
>>>
>>> sorry for the spam, the first time was sent with html part and was
>>> rejected.
>>>
>>> We observed an issue where a classifier instance next member is
>>> pointing back to itself, causing a CPU soft lockup.
>>> We found it by running traffic on many udp connections and then adding
>>> a new flower rule using tc.
>>>
>>> We added a quick workaround to verify it:
>>>
>>> In tc_classify:
>>>
>>>          for (; tp; tp = rcu_dereference_bh(tp->next)) {
>>>                  int err;
>>> +               if (tp == tp->next)
>>> +                     RCU_INIT_POINTER(tp->next, NULL);
>>>
>>>
>>> We also had a print here showing tp->next is pointing to tp. With this
>>> workaround we are not hitting the issue anymore.
>>> We are not sure we fully understand the mechanism here - with the rtnl
>>> and rcu locks.
>>> We'll appreciate your help solving this issue.
>>
>>
>> Note that there's still the RCU fix missing for the deletion race that
>> Cong will still send out, but you say that the only thing you do is to
>> add a single rule, but no other operation in involved during that test?

Hmm, I thought RCU_INIT_POINTER() respects readers, but seems no?
If so, that could be the cause since we play with the next pointer and
there is only one filter in this case, but I don't see why we could have
a loop here.

>>
>> Do you have a script and kernel .config for reproducing this?
>
>
> I'm using a user space socket app(https://github.com/shahar-klein/noodle)on
> a vm to push udp packets from ~2000 different udp src ports ramping up at
> ~100 per second towards another vm on the same Hypervisor. Once the traffic
> starts I'm pushing ingress flower tc udp rules(even_udp_src_port->mirred,
> odd->drop) on the relevant representor in the Hypervisor.

Do you mind to share your `tc filter show dev...` output? Also, since you
mentioned you only add one flower filter, just want to make sure you never
delete any filter before/when the bug happens? How reproducible is this?

Thanks!
