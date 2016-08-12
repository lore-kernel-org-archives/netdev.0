From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] net: sched: convert qdisc linked list to hashtable
Date: Fri, 12 Aug 2016 16:26:19 +0200
Message-ID: <57ADDC8B.9010700@iogearbox.net>
References: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm> <alpine.LNX.2.00.1608101054320.22028@cbobk.fhfr.pm> <57ADC6AA.5070506@iogearbox.net> <alpine.LNX.2.00.1608121523020.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608121523020.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/2016 03:53 PM, Jiri Kosina wrote:
> On Fri, 12 Aug 2016, Daniel Borkmann wrote:
>
>> This results in below panic. Tested reverting this patch and it fixes
>> the panic.
>>
>> Did you test this also with ingress or clsact qdisc (just try adding
>> it to lo dev for example) ?
>
> Hi Daniel,
>
> thanks for the report. Hmm, I am pretty sure clsact worked for me, but
> I'll recheck.
>
>> What happens is the following in qdisc_match_from_root():
>>
>> [  995.422187] XXX qdisc:ffff88025e4fc800 queue:ffff880262759000
>> dev:ffff880261cc2000 handle:ffff0000
>> [  995.422200] XXX qdisc:ffffffff81cf8100 queue:ffffffff81cf8240 dev:
>> (null) handle:ffff0000
>>
>> I believe this is due to dev_ingress_queue_create() assigning the
>> global noop_qdisc instance as qdisc_sleeping, which later qdisc_lookup()
>> uses for qdisc_match_from_root().
>>
>> But everything that uses things like noop_qdisc cannot work with the
>> new qdisc_match_from_root(), because qdisc_dev(root) will always trigger
>> NULL pointer dereference there. Reason is because the dev is always
>> NULL for noop, it's a singleton, see noop_qdisc and noop_netdev_queue
>> in sch_generic.c.
>>
>> Now how to fix it? Creating separate noop instances each time it's set
>> would be quite a waste of memory. Even fuglier would be to hack a static
>> net device struct into sch_generic.c and let noop_netdev_queue point there
>> to get to the hash table. Or we just not use qdisc_dev().
>
> How about we actually extend a little bit the TCQ_F_BUILTIN special case
> test in qdisc_match_from_root()?
>
> After the change, the only way how qdisc_dev() could be NULL should be a
> TCQ_F_BUILTIN case, right?
>
> I was thinking about something like the patch below (the reasong being
> that ->dev would be NULL only in cases of singletonish qdiscs) ...
> wouldn't that also fix the issue you're seeing? Have to think it through a
> little bit more ..

Ahh, so this has the same effect as previously observed with the other fix.

Perhaps it's just a dumping issue, but to the below clsact, there shouldn't
be pfifo_fast instances appearing.

# tc qdisc show dev wlp2s0b1
qdisc mq 0: root
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
# tc qdisc add dev wlp2s0b1 clsact
# tc qdisc show dev wlp2s0b1
qdisc mq 0: root
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc clsact ffff: parent ffff:fff1
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 25aada7..1c9faed 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -260,6 +260,9 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
>   {
>   	struct Qdisc *q;
>
> +	if (!qdisc_dev(root))
> +		return (root->handle == handle ? root : NULL);
> +
>   	if (!(root->flags & TCQ_F_BUILTIN) &&
>   	    root->handle == handle)
>   		return root;
>
>
> Thanks!
>
