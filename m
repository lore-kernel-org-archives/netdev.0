From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH] net/mlx4_en: Fix bpf_prog_add ref_cnt in mlx4
Date: Wed, 09 Nov 2016 20:05:39 +0100
Message-ID: <58237383.4070506@iogearbox.net>
References: <20161109073544.jbufjqn7y7oa6ptg@ubuntu> <5822E6DB.40204@iogearbox.net> <20161109094546.jtmzc4xwtaavzcnt@ubuntu> <5822F30C.1050900@iogearbox.net> <20161109170615.GB10428@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zhiyi Sun <zhiyisun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Brenden Blanco <bblanco-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161109170615.GB10428-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/09/2016 06:06 PM, Brenden Blanco wrote:
> On Wed, Nov 09, 2016 at 10:57:32AM +0100, Daniel Borkmann wrote:
>> On 11/09/2016 10:45 AM, Zhiyi Sun wrote:
>>> On Wed, Nov 09, 2016 at 10:05:31AM +0100, Daniel Borkmann wrote:
>>>> On 11/09/2016 08:35 AM, Zhiyi Sun wrote:
>>>>> There are rx_ring_num queues. Each queue will load xdp prog. So
>>>>> bpf_prog_add() should add rx_ring_num to ref_cnt.
>>>>>
>>>>> Signed-off-by: Zhiyi Sun <zhiyisun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>
>>>> Your analysis looks incorrect to me. Please elaborate in more detail why
>>>> you think current code is buggy ...
>>>
>>> Yes, you are correct. My patch is incorrect. It is not a bug.
>>>
>>>> Call path is dev_change_xdp_fd(), which does bpf_prog_get_type() on the
>>>> fd. This already takes a ref and only drops it in case of error. Thus
>>>> in mlx4_xdp_set(), you only need priv->rx_ring_num - 1 refs for the rest
>>>> of the rings, so that dropping refs from old_prog makes sure we release
>>>> it again. Looks correct to me (maybe a comment would have helped there).
>>>
>>> I thought mlx4's code is incorrect because in mlx5's driver, function
>>> mlx5e_xdp_set() calls a pair of bpf_prog_add/put, the number of add and
>>> put to the refs are same. I didn't notice that one "add" has been called in its
>>> calller. So, it seems that mlx5's code is incorrect, right?
>>
>> Yep, I think the two attached patches are needed.
>>
>> The other thing I noticed in mlx5e_create_rq() is that it calls
>> bpf_prog_add(rq->xdp_prog, 1) without actually checking for errors.
>
>>  From d2bd6b3cd8636716a06b0ea3b1e041e16f87cce0 Mon Sep 17 00:00:00 2001
>> Message-Id: <d2bd6b3cd8636716a06b0ea3b1e041e16f87cce0.1478685278.git.daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> Date: Wed, 9 Nov 2016 10:31:19 +0100
>> Subject: [PATCH net-next 1/2] bpf, mlx4: fix prog refcount in mlx4_en_try_alloc_resources error path
>>
>> Commit 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings
>> scheme") added a bug in that the prog's reference count is not dropped
>> in the error path when mlx4_en_try_alloc_resources() is failing.
>>
>> We previously took bpf_prog_add(prog, priv->rx_ring_num - 1), that we
>> need to release again. Earlier in the call-path, dev_change_xdp_fd()
>> itself holds a ref to the prog as well, which is then released though
>> bpf_prog_put() due to the propagated error.
>>
>> Fixes: 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings scheme")
>> Signed-off-by: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  5 ++++-
>>   include/linux/bpf.h                            |  1 +
>>   kernel/bpf/syscall.c                           | 11 +++++++++++
>>   3 files changed, 16 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> index 0f6225c..4104aec 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> @@ -2747,8 +2747,11 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>>   	}
>>
>>   	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
>> -	if (err)
>> +	if (err) {
>> +		if (prog)
>> +			bpf_prog_add_undo(prog, priv->rx_ring_num - 1);
> Why not just move the above bpf_prog_add to be below the try_alloc?
> Nobody needs those references until all of the resources have been
> allocated, and then we can remove the need for bpf_prog_add_undo.

Right, looked into this and the convention is to call mlx4_en_try_alloc_resources()
plus mlx4_en_safe_replace_resources(), which must always succeed (currently).
Seems rather complex to go this route instead; bpf_prog_add_undo() or *_sub()
[however we name it] is safe and straight forward, since we're guaranteed to
have one reference already.

>>   		goto unlock_out;
>> +	}
>>
>>   	if (priv->port_up) {
>>   		port_up = 1;
>> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
>> index edcd96d..4f6a4f1 100644
>> --- a/include/linux/bpf.h
>> +++ b/include/linux/bpf.h
>> @@ -234,6 +234,7 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
>>   struct bpf_prog *bpf_prog_get(u32 ufd);
>>   struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
>>   struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i);
>> +void bpf_prog_add_undo(struct bpf_prog *prog, int i);
>>   struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog);
>>   void bpf_prog_put(struct bpf_prog *prog);
>>
>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> index 228f962..a6e4dd8 100644
>> --- a/kernel/bpf/syscall.c
>> +++ b/kernel/bpf/syscall.c
>> @@ -680,6 +680,17 @@ struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
>>   }
>>   EXPORT_SYMBOL_GPL(bpf_prog_add);
>>
>> +void bpf_prog_add_undo(struct bpf_prog *prog, int i)
>> +{
>> +	/* Only to be used for undoing previous bpf_prog_add() in some
>> +	 * error path. We still know that another entity in our call
>> +	 * path holds a reference to the program, thus atomic_sub() can
>> +	 * be safely used here!
>> +	 */
>> +	atomic_sub(i, &prog->aux->refcnt);
>> +}
>> +EXPORT_SYMBOL_GPL(bpf_prog_add_undo);
>> +
>>   struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
>>   {
>>   	return bpf_prog_add(prog, 1);
>> --
>> 1.9.3
>
>>  From f0789544432bbb89c53c3b8ac6575d48fed97786 Mon Sep 17 00:00:00 2001
>> Message-Id: <f0789544432bbb89c53c3b8ac6575d48fed97786.1478685278.git.daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> In-Reply-To: <d2bd6b3cd8636716a06b0ea3b1e041e16f87cce0.1478685278.git.daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> References: <d2bd6b3cd8636716a06b0ea3b1e041e16f87cce0.1478685278.git.daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> Date: Wed, 9 Nov 2016 10:51:26 +0100
>> Subject: [PATCH net-next 2/2] bpf, mlx5: fix prog refcount in mlx5e_xdp_set
>>
>> dev_change_xdp_fd() already holds a reference, so bpf_prog_add(prog, 1)
>> is not correct as it takes one reference too much and will thus leak
>> the prog eventually. Also, bpf_prog_add() can fail and is not checked
>> for errors here.
>>
>> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
>> Signed-off-by: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>> ---
>>   drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 --
>>   1 file changed, 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> index ba0c774..63309dd 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> @@ -3121,8 +3121,6 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
>>
>>   	/* exchange programs */
>>   	old_prog = xchg(&priv->xdp_prog, prog);
>> -	if (prog)
>> -		bpf_prog_add(prog, 1);
> There is also another use of bpf_prog_add down below, which does not
> check the error return. Same in mlx5e_create_rq.

Yeah, saw that, too. These two unchecked bpf_prog_add() would be another
issue to fix on top of this, ohh well.

For net-next, I'll just add a __must_check to these functions, so we can
avoid such issues in future and let the compiler complain early enough
instead.

Thanks,
Daniel
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
