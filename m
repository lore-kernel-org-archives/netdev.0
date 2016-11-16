From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 2/4] bpf, mlx5: fix various refcount issues
 in mlx5e_xdp_set
Date: Wed, 16 Nov 2016 16:26:05 +0100
Message-ID: <582C7A8D.1020005@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net> <0899adb6ace97b7e7f94b04dd11a0e55270d2b54.1479253024.git.daniel@iogearbox.net> <CALzJLG_r9tujvSVysMXLSO8cRR6zHaHfmacmGq-hCqg5Ou7w_w@mail.gmail.com> <582C64FC.4010307@iogearbox.net> <CALzJLG8jYhp0EZS=oOTv-Oy6fJFTax8FSA6hh4EXXS1E5g-+uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>, zhiyisun@gmail.com,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35875 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753156AbcKPP0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:26:11 -0500
In-Reply-To: <CALzJLG8jYhp0EZS=oOTv-Oy6fJFTax8FSA6hh4EXXS1E5g-+uQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2016 03:30 PM, Saeed Mahameed wrote:
> On Wed, Nov 16, 2016 at 3:54 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 11/16/2016 01:25 PM, Saeed Mahameed wrote:
>>> On Wed, Nov 16, 2016 at 2:04 AM, Daniel Borkmann <daniel@iogearbox.net>
>>> wrote:
>>>>
>>>> There are multiple issues in mlx5e_xdp_set():
>>>>
>>>> 1) The batched bpf_prog_add() is currently not checked for errors! When
>>>>      doing so, it should be done at an earlier point in time to makes sure
>>>>      that we cannot fail anymore at the time we want to set the program
>>>> for
>>>>      each channel. This only means that we have to undo the bpf_prog_add()
>>>>      in case we return due to required reset.
>>>>
>>>> 2) When swapping the priv->xdp_prog, then no extra reference count must
>>>> be
>>>>      taken since we got that from call path via dev_change_xdp_fd()
>>>> already.
>>>>      Otherwise, we'd never be able to free the program. Also,
>>>> bpf_prog_add()
>>>>      without checking the return code could fail.
>>>>
>>>> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
>>>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>>>> ---
>>>>    drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 25
>>>> ++++++++++++++++++-----
>>>>    1 file changed, 20 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>>> b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>>> index ab0c336..cf26672 100644
>>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>>> @@ -3142,6 +3142,17 @@ static int mlx5e_xdp_set(struct net_device
>>>> *netdev, struct bpf_prog *prog)
>>>>                   goto unlock;
>>>>           }
>>>>
>>>> +       if (prog) {
>>>> +               /* num_channels is invariant here, so we can take the
>>>> +                * batched reference right upfront.
>>>> +                */
>>>> +               prog = bpf_prog_add(prog, priv->params.num_channels);
>>>> +               if (IS_ERR(prog)) {
>>>> +                       err = PTR_ERR(prog);
>>>> +                       goto unlock;
>>>> +               }
>>>> +       }
>>>> +
>>>
>>> With this approach you will end up taking a ref count twice per RQ! on
>>> the first time xdp_set is called i.e (old_prog = NULL, prog != NULL).
>>> One ref will be taken per RQ/Channel from the above code, and since
>>> reset will be TRUE mlx5e_open_locked will be called and another ref
>>> count will be taken on mlx5e_create_rq.
>>>
>>> The issue here is that we have two places for ref count accounting,
>>> xdp_set and  mlx5e_create_rq. Having ref-count updates in
>>> mlx5e_create_rq is essential for num_channels configuration changes
>>> (mlx5e_set_ringparam).
>>>
>>> Our previous approach made sure that only one path will do the ref
>>> counting (mlx5e_open_locked vs. mlx5e_xdp_set batch ref update when
>>> reset == false).
>>
>> That is correct, for a short time bpf_prog_add() was charged also when
>> we reset. When we reset, we will then jump to unlock_put and safely undo
>> this since we took ref from mlx5e_create_rq() already in that case, and
>> return successfully. That was intentional, so that eventually we end up
>> just taking a /single/ ref per RQ when we exit mlx5e_xdp_set(), but more
>> below ...
>>
>> [...]
>>>
>>> 2. Keep the current approach and make sure to not update the ref count
>>> twice, you can batch update only if (!reset && was_open) otherwise you
>>> can rely on mlx5e_open_locked to take the num_channels ref count for
>>> you.
>>>
>>> Personally I prefer option 2, since we will keep the current logic
>>> which will allow configuration updates such as (mlx5e_set_ringparam)
>>> to not worry about ref counting since it will be done in the reset
>>> flow.
>>
>> ... agree on keeping current approach. I actually like the idea, so we'd
>> end up with this simpler version for the batched ref then.
>
> Great :).
>
> So let's do the batched update only if we are not going to reset (we
> already know that in advance), instead of the current patch where you
> batch update unconditionally and then
>   unlock_put in case reset was performed (which is just redundant and confusing).
>
> Please note that if open_locked fails you need to goto unlock_put.

Sorry, I'm not quite sure I follow you here; are you /now/ commenting on
the original patch or on the already updated diff I did from my very last
email, that is, http://patchwork.ozlabs.org/patch/695564/ ?

>> Note, your "bpf_prog_add(prog, 1) // one ref for the device." is not needed
>> since this we already got that one through dev_change_xdp_fd() as mentioned.
>
> If it is not needed then why we need bpf_prog_put on mlx5e_nic_cleanup
> in your next patch? this doesn't look symmetric (right) !
> you shouldn't release a reference you didn't take.
> Overall with this series the driver can take num_channels refs and
> will release num_channels refs on mlx5e_close. we shouldn't release
> one extra ref on NIC cleanup.

I already explained this in the commit description; when dev_change_xdp_fd()
is called and sees a valid fd, it does bpf_prog_get_type(), which calls the
__bpf_prog_get() taking a ref on the program (bpf_prog_inc()). That is then
passed down to ops->ndo_xdp(). Only in case of error from the ->ndo_xdp()
callback, we bpf_prog_put() this reference from dev_change_xdp_fd() side.

For drivers that implement against this ndo, it means that you need N-1 refs
in addition. Have a look at the other two in-tree users, which do it correctly,
that is mlx4_xdp_set() and nfp_net_xdp_setup().

It's documented here (include/linux/netdevice.h) with ndo_xdp referring to it:

/* These structures hold the attributes of xdp state that are being passed
  * to the netdevice through the xdp op.
  */
enum xdp_netdev_command {
	/* Set or clear a bpf program used in the earliest stages of packet
	 * rx. The prog will have been loaded as BPF_PROG_TYPE_XDP. The callee
	 * is responsible for calling bpf_prog_put on any old progs that are
	 * stored. In case of error, the callee need not release the new prog
	 * reference, but on success it takes ownership and must bpf_prog_put
	 * when it is no longer used.
	 */
	XDP_SETUP_PROG,
[...]
};

I think reason why this is rather confusing would be that initially, it was
just a single prog for all queues, but it was requested along the way to move
prog pointer down to queues instead and let them have their own ref, so that
some time in future individual progs from a subset of the queues can be
exchanged.

Since the way xdp in mlx5 is implemented, you currently have the priv->xdp_prog
as the control prog. That's okay right now, but requires to drop the last ref
on priv->xdp_prog via bpf_prog_put() when netdev is dismantled and priv->xdp_prog
still present.
