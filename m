From: Shahar Klein <shahark@mellanox.com>
Subject: Re: Soft lockup in tc_classify
Date: Mon, 12 Dec 2016 18:04:06 +0200
Message-ID: <1e715873-34ba-0a76-c94e-064ca4cf895b@mellanox.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com>
 <584EA60B.80803@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <shahark@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0050.outbound.protection.outlook.com ([104.47.2.50]:5070
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753002AbcLLRhH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 12:37:07 -0500
In-Reply-To: <584EA60B.80803@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/12/2016 3:28 PM, Daniel Borkmann wrote:
> Hi Shahar,
>
> On 12/12/2016 10:43 AM, Shahar Klein wrote:
>> Hi All,
>>
>> sorry for the spam, the first time was sent with html part and was
>> rejected.
>>
>> We observed an issue where a classifier instance next member is
>> pointing back to itself, causing a CPU soft lockup.
>> We found it by running traffic on many udp connections and then adding
>> a new flower rule using tc.
>>
>> We added a quick workaround to verify it:
>>
>> In tc_classify:
>>
>>          for (; tp; tp = rcu_dereference_bh(tp->next)) {
>>                  int err;
>> +               if (tp == tp->next)
>> +                     RCU_INIT_POINTER(tp->next, NULL);
>>
>>
>> We also had a print here showing tp->next is pointing to tp. With this
>> workaround we are not hitting the issue anymore.
>> We are not sure we fully understand the mechanism here - with the rtnl
>> and rcu locks.
>> We'll appreciate your help solving this issue.
>
> Note that there's still the RCU fix missing for the deletion race that
> Cong will still send out, but you say that the only thing you do is to
> add a single rule, but no other operation in involved during that test?
>
> Do you have a script and kernel .config for reproducing this?

I'm using a user space socket 
app(https://github.com/shahar-klein/noodle)on a vm to push udp packets 
from ~2000 different udp src ports ramping up at ~100 per second towards 
another vm on the same Hypervisor. Once the traffic starts I'm pushing 
ingress flower tc udp rules(even_udp_src_port->mirred, odd->drop) on the 
relevant representor in the Hypervisor.

>
> Thanks,
> Daniel
