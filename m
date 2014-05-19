From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next] net_sched: increase drop count when packets
 are dropped
Date: Mon, 19 May 2014 16:25:14 +0800
Message-ID: <5379BFEA.7040600@huawei.com>
References: <1399974163-8788-1-git-send-email-yangyingliang@huawei.com>	 <1399988959.7973.46.camel@edumazet-glaptop2.roam.corp.google.com>	 <5375D54C.4040108@huawei.com> <1400246525.7973.168.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <vtlam@google.com>, <nanditad@google.com>, <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:30661 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbaESI0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 04:26:06 -0400
In-Reply-To: <1400246525.7973.168.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/16 21:22, Eric Dumazet wrote:
> On Fri, 2014-05-16 at 17:07 +0800, Yang Yingliang wrote:
>> On 2014/5/13 21:49, Eric Dumazet wrote:
>>> On Tue, 2014-05-13 at 17:42 +0800, Yang Yingliang wrote:
>>>> When packets are dropped because of overlimit, the drop count
>>>> should be increased. Replace kfree_skb() with qdisc_drop() for
>>>> increasing drop count.
>>>>
>>>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>>>> ---
>>>>  net/sched/sch_fq.c       | 2 +-
>>>>  net/sched/sch_fq_codel.c | 3 ++-
>>>>  net/sched/sch_hhf.c      | 3 ++-
>>>>  3 files changed, 5 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
>>>> index 23c682b42f99..958ef7d4b825 100644
>>>> --- a/net/sched/sch_fq.c
>>>> +++ b/net/sched/sch_fq.c
>>>> @@ -714,7 +714,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
>>>>  
>>>>  		if (!skb)
>>>>  			break;
>>>> -		kfree_skb(skb);
>>>> +		qdisc_drop(skb, sch);
>>>>  		drop_count++;
>>>>  	}
>>>>  	qdisc_tree_decrease_qlen(sch, drop_count);
>>>> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
>>>> index 0bf432c782c1..bcfe4594470f 100644
>>>> --- a/net/sched/sch_fq_codel.c
>>>> +++ b/net/sched/sch_fq_codel.c
>>>> @@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
>>>>  	while (sch->q.qlen > sch->limit) {
>>>>  		struct sk_buff *skb = fq_codel_dequeue(sch);
>>>>  
>>>> -		kfree_skb(skb);
>>>> +		qdisc_drop(skb, sch);
>>>> +		q->drop_overlimit++;
>>>>  		q->cstats.drop_count++;
>>>>  	}
>>>
>>> Could you please refrain from adding random stuff in packet schedulers ?
>> OK :)
>>
>>>
>>> overlimit has a special meaning for HTB like qdisc, having a shapers.
>> I don't really catch up with you here. What's special meaning ?
>>
>>>
>>> fq_codel or hhf do not shape, there is no reason to increment
>>> 'overlimit' when they _drop_ a packet.
>>
>> Do you mean 'drop_overlimit' or 'overlimit' ?
>>
>> fq_codel has both 'overlimits' and 'drop_overlimit' :
>>
>> qdisc fq_codel 1: dev eth4 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
>>  Sent 834 bytes 5 pkt (dropped 0, overlimits 0 requeues 0) 
>>  backlog 0b 0p requeues 0 
>>   maxpacket 256 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>   new_flows_len 0 old_flows_len 0
>>
>> Could you please explain more explicitly ?
> 
> 
> Okay fair enough.
> 
> Read again the changelog you gave.
> 
> Where is this change mentioned or explained properly ?
> 
> You give a changelog, then you insert a 'random' change in the patch,
> not mentioned in the changelog. How I am supposed to be cool ?
> 
> Instead of cooking a clean patch, you have this tendency of putting
> 'random' things and expect me/us to carefully check you didn't add a
> bug. But you know what, its exhausting,
> 
> The quality of your patches dropped considerably in the last
> submissions.
> 
> I ask you to test your patches and prove you don't break things, because
> I do not trust you anymore.
> 
> I am going to ask you to give detailed Tested: sections for your next
> patches.
> 

First, thanks for explanation !
Then about the patch, I've tested this patch before I sent it. Precisely because of
the testing, I add the code that not mentioned in the changelog. Anyway, I'm sorry
for the bad changelog, I'll write more explicitly for my next patches.

Here is my test way :

Step 1. One terminal run iperf to send packets:
  # iperf -c $ip -i 1 -P 1 -t 6000

Step 2. Another terminal run the script:
#!/bin/sh
int=1
while(( $int<=5 ))
do
tc qdisc replace dev eth4 root handle 1: fq_codel limit 10
tc qdisc replace dev eth4 root handle 1: fq_codel limit 100000
done

(Besides, to make sure it has execute the code I've changed, I printed some
message after my changed code.)

Step 3. run '# tc qdisc -s -d show dev eth4'
qdisc fq_codel 1: dev eth4 root refcnt 2 limit 10p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 928883982 bytes 616651 pkt (*dropped 747*, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 1514 *drop_overlimit 654* new_flow_count 15 ecn_mark 0
  new_flows_len 0 old_flows_len 0

>From the test result, I found that _drop_overlimit_ are smaller than _dropped_ , so I increased
_drop_overlimit_ (not overlimits of qstats). Then I got the below result which  _drop_overlimit_
and _dropped_ are equal.

qdisc fq_codel 1: dev eth4 root refcnt 2 limit 10p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 3309408635 bytes 2196855 pkt (*dropped 4458*, overlimits 0 requeues 2) 
 backlog 0b 0p requeues 2 
  maxpacket 1514 *drop_overlimit 4458* new_flow_count 57 ecn_mark 0
  new_flows_len 0 old_flows_len 0
(For fq and hhf, I use the same test way)

I wonder if _overlimit_ that you mentioned in the earlier mail and _drop_overlimit_ I mentioned here
are same variable. If they're same , maybe I miss something, please let me know.

Thanks!
