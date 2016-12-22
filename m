From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Fri, 23 Dec 2016 00:20:18 +0100
Message-ID: <585C5FB2.2000909@iogearbox.net>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net> <7033ed3d-0665-1a38-7631-a1346d46e1b4@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, gerlitz.or@gmail.com, roid@mellanox.com,
        jiri@mellanox.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: Shahar Klein <shahark@mellanox.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36347 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941898AbcLVXUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 18:20:49 -0500
In-Reply-To: <7033ed3d-0665-1a38-7631-a1346d46e1b4@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2016 02:16 PM, Shahar Klein wrote:
> On 12/21/2016 7:04 PM, Daniel Borkmann wrote:
>> Shahar reported a soft lockup in tc_classify(), where we run into an
>> endless loop when walking the classifier chain due to tp->next == tp
>> which is a state we should never run into. The issue only seems to
>> trigger under load in the tc control path.
>>
>> What happens is that in tc_ctl_tfilter(), thread A allocates a new
>> tp, initializes it, sets tp_created to 1, and calls into tp->ops->change()
>> with it. In that classifier callback we had to unlock/lock the rtnl
>> mutex and returned with -EAGAIN. One reason why we need to drop there
>> is, for example, that we need to request an action module to be loaded.
>>
>> This happens via tcf_exts_validate() -> tcf_action_init/_1() meaning
>> after we loaded and found the requested action, we need to redo the
>> whole request so we don't race against others. While we had to unlock
>> rtnl in that time, thread B's request was processed next on that CPU.
>> Thread B added a new tp instance successfully to the classifier chain.
>> When thread A returned grabbing the rtnl mutex again, propagating -EAGAIN
>> and destroying its tp instance which never got linked, we goto replay
>> and redo A's request.
>>
>> This time when walking the classifier chain in tc_ctl_tfilter() for
>> checking for existing tp instances we had a priority match and found
>> the tp instance that was created and linked by thread B. Now calling
>> again into tp->ops->change() with that tp was successful and returned
>> without error.
>>
>> tp_created was never cleared in the second round, thus kernel thinks
>> that we need to link it into the classifier chain (once again). tp and
>> *back point to the same object due to the match we had earlier on. Thus
>> for thread B's already public tp, we reset tp->next to tp itself and
>> link it into the chain, which eventually causes the mentioned endless
>> loop in tc_classify() once a packet hits the data path.
>>
>> Fix is to clear tp_created at the beginning of each request, also when
>> we replay it. On the paths that can cause -EAGAIN we already destroy
>> the original tp instance we had and on replay we really need to start
>> from scratch. It seems that this issue was first introduced in commit
>> 12186be7d2e1 ("net_cls: fix unconfigured struct tcf_proto keeps chaining
>> and avoid kernel panic when we use cls_cgroup").
>>
>> Fixes: 12186be7d2e1 ("net_cls: fix unconfigured struct tcf_proto keeps chaining and avoid kernel panic when we use cls_cgroup")
>> Reported-by: Shahar Klein <shahark@mellanox.com>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Cong Wang <xiyou.wangcong@gmail.com>
[...]
> I've tested this specific patch (without cong's patch and without the many prints) many times and in many test permutations today and it didn't lock
>
> Thanks again Daniel!

Just catching up with email (traveling whole day), thanks a bunch for
your effort, Shahar! In that case lets then add:

Tested-by: Shahar Klein <shahark@mellanox.com>
