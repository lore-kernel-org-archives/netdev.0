From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 15:33:30 +0300
Message-ID: <5519429A.8050000@cogentembedded.com>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1427652564-32181-2-git-send-email-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/29/2015 9:09 PM, Oliver Hartkopp wrote:

> The CAN_RAW socket can set multiple CAN identifier specific filters that lead
> to multiple filters in the af_can.c filter processing. These filters are
> indenpendent from each other which leads to logical OR'ed filters when applied.

> This patch makes sure that every CAN frame which is filtered for a specific
> socket is only delivered once to the user space. This is independent from the
> number of matching CAN filters of this socket.

> As the can_raw() function is executed from NET_RX softirq the introduced
> variables are implemented as per-CPU variables to avoid extensive locking at
> CAN frame reception time.

> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>   net/can/raw.c | 28 ++++++++++++++++++++++++++++
>   1 file changed, 28 insertions(+)

> diff --git a/net/can/raw.c b/net/can/raw.c
> index 00c13ef..866a9b3 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
[...]
> @@ -123,6 +125,15 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
>   	if (!ro->fd_frames && oskb->len != CAN_MTU)
>   		return;
>
> +	/* eliminate multiple filter matches for the same skb */
> +	if (*this_cpu_ptr(ro->uniq_skb) == oskb &&
> +	    ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
> +			return;

    Over-indented.

> +	} else {
> +		*this_cpu_ptr(ro->uniq_skb) = oskb;
> +		*this_cpu_ptr(ro->uniq_tstamp) = oskb->tstamp;
> +	}
> +
>   	/* clone the given skb to be able to enqueue it into the rcv queue */
>   	skb = skb_clone(oskb, GFP_ATOMIC);
>   	if (!skb)
[...]
> @@ -297,6 +309,20 @@ static int raw_init(struct sock *sk)
>   	ro->recv_own_msgs    = 0;
>   	ro->fd_frames        = 0;
>
> +	ro->uniq_skb = alloc_percpu(struct sk_buff *);
> +	if (unlikely(ro->uniq_skb == NULL))
> +		return -ENOMEM;
> +	for_each_possible_cpu(cpu)
> +		*per_cpu_ptr(ro->uniq_skb, cpu) = NULL;
> +
> +	ro->uniq_tstamp = alloc_percpu(ktime_t);
> +	if (unlikely(ro->uniq_tstamp == NULL)) {

    !ro->uniq_tstamp is preferred in the networking code.

[...]

WBR, Sergei

