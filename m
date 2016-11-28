From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net, sched: respect rcu grace period on cls destruction
Date: Mon, 28 Nov 2016 10:09:16 +0100
Message-ID: <583BF43C.4020103@iogearbox.net>
References: <0d6d89f885033f1739e97f7f3372ae6e1db72892.1480204343.git.daniel@iogearbox.net> <CAM_iQpVRDnLM_Cmp63PVkpYtmdtNECP-2m89=DGdidkUYyHwug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Roi Dayan <roid@mellanox.com>, ast@fb.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32806 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcK1JJX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 04:09:23 -0500
In-Reply-To: <CAM_iQpVRDnLM_Cmp63PVkpYtmdtNECP-2m89=DGdidkUYyHwug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 07:57 AM, Cong Wang wrote:
> On Sat, Nov 26, 2016 at 4:18 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Roi reported a crash in flower where tp->root was NULL in ->classify()
>> callbacks. Reason is that in ->destroy() tp->root is set to NULL via
>> RCU_INIT_POINTER(). It's problematic for some of the classifiers, because
>> this doesn't respect RCU grace period for them, and as a result, still
>> outstanding readers from tc_classify() will try to blindly dereference
>> a NULL tp->root.
>>
>> The tp->root object is strictly private to the classifier implementation
>> and holds internal data the core such as tc_ctl_tfilter() doesn't know
>> about. Within some classifiers, such as cls_bpf, cls_basic, etc, tp->root
>> is only checked for NULL in ->get() callback, but nowhere else. This is
>> misleading and seemed to be copied from old classifier code that was not
>> cleaned up properly. For example, d3fa76ee6b4a ("[NET_SCHED]: cls_basic:
>> fix NULL pointer dereference") moved tp->root initialization into ->init()
>> routine, where before it was part of ->change(), so ->get() had to deal
>> with tp->root being NULL back then, so that was indeed a valid case, after
>> d3fa76ee6b4a, not really anymore. We used to set tp->root to NULL long
>> ago in ->destroy(), see 47a1a1d4be29 ("pkt_sched: remove unnecessary xchg()
>> in packet classifiers"); but the NULLifying was reintroduced with the
>> RCUification, but it's not correct for every classifier implementation.
>>
>> In the cases that are fixed here with one exception of cls_cgroup, tp->root
>> object is allocated and initialized inside ->init() callback, which is always
>> performed at a point in time after we allocate a new tp, which means tp and
>> thus tp->root was not globally visible in the tp chain yet (see tc_ctl_tfilter()).
>> Also, on destruction tp->root is strictly kfree_rcu()'ed in ->destroy()
>> handler, same for the tp which is kfree_rcu()'ed right when we return
>> from ->destroy() in tcf_destroy(). This means, the head object's lifetime
>> for such classifiers is always tied to the tp lifetime. The RCU callback
>> invocation for the two kfree_rcu() could be out of order, but that's fine
>> since both are independent.
>>
>> Dropping the RCU_INIT_POINTER(tp->root, NULL) for these classifiers here
>> means that 1) we don't need a useless NULL check in fast-path and, 2) that
>> outstanding readers of that tp in tc_classify() can still execute under
>> respect with RCU grace period as it is actually expected.
>>
>> Things that haven't been touched here: cls_fw and cls_route. They each
>> handle tp->root being NULL in ->classify() path for historic reasons, so
>> their ->destroy() implementation can stay as is. If someone actually
>> cares, they could get cleaned up at some point to avoid the test in fast
>> path. cls_u32 doesn't set tp->root to NULL. For cls_rsvp, I just added a
>> !head should anyone actually be using/testing it, so it at least aligns with
>> cls_fw and cls_route. For cls_flower we additionally need to defer rhashtable
>> destruction (to a sleepable context) after RCU grace period as concurrent
>> readers might still access it. (Note that in this case we need to hold module
>> reference to keep work callback address intact, since we only wait on module
>> unload for all call_rcu()s to finish.)
>>
>> This fixes one race to bring RCU grace period guarantees back. Next step
>> as worked on by Cong however is to fix 1e052be69d04 ("net_sched: destroy
>> proto tp when all filters are gone") to get the order of unlinking the tp
>> in tc_ctl_tfilter() for the RTM_DELTFILTER case right by moving
>> RCU_INIT_POINTER() before tcf_destroy() and let the notification for
>> removal be done through the prior ->delete() callback. Both are independant
>> issues. Once we have that right, we can then clean tp->root up for a number
>> of classifiers by not making them RCU pointers, which requires a new callback
>> (->uninit) that is triggered from tp's RCU callback, where we just kfree()
>> tp->root from there.
>
> Looks good to my eyes,
>
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks for the review (also to John)!

> The ugly part is the work struct, I am not an RCU expert so don't know if we
> have any API to execute an RCU callback in process context. Paul?

Same way we do this in BPF with prog destruction, by the way. I'm not aware
of any callback API for RCU that lets you do this, but maybe Paul knows.
