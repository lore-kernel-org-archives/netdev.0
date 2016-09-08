From: Or Gerlitz via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf
 programs support
Date: Thu, 8 Sep 2016 10:10:28 +0300
Message-ID: <CAJ3xEMgfFAA71UUsCvh=ZfnCBGegq_o6qT+RWw_WE55=LqQK4g@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-9-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMgsGHqQ7x8wky6Sfs34Ry67PnZEhYmnK=g8XnnXbgWagg@mail.gmail.com>
	<CALzJLG9C0PgJWFi9hc7LrhZJejOHmWOjn0Lu-jiPekoyTGq1Ng@mail.gmail.com>
Reply-To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <CALzJLG9C0PgJWFi9hc7LrhZJejOHmWOjn0Lu-jiPekoyTGq1Ng-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 8, 2016 at 12:53 AM, Saeed Mahameed
<saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
> On Wed, Sep 7, 2016 at 11:55 PM, Or Gerlitz via iovisor-dev
> <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org> wrote:
>> On Wed, Sep 7, 2016 at 3:42 PM, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>>> From: Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>>
>>> Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx5e driver.
>>>
>>> When XDP is on we make sure to change channels RQs type to
>>> MLX5_WQ_TYPE_LINKED_LIST rather than "striding RQ" type to
>>> ensure "page per packet".
>>>
>>> On XDP set, we fail if HW LRO is set and request from user to turn it
>>> off.  Since on ConnectX4-LX HW LRO is always on by default, this will be
>>> annoying, but we prefer not to enforce LRO off from XDP set function.
>>>
>>> Full channels reset (close/open) is required only when setting XDP
>>> on/off.
>>>
>>> When XDP set is called just to exchange programs, we will update
>>> each RQ xdp program on the fly and for synchronization with current
>>> data path RX activity of that RQ, we temporally disable that RQ and
>>> ensure RX path is not running, quickly update and re-enable that RQ,
>>> for that we do:
>>>         - rq.state = disabled
>>>         - napi_synnchronize
>>>         - xchg(rq->xdp_prg)
>>>         - rq.state = enabled
>>>         - napi_schedule // Just in case we've missed an IRQ
>>>
>>> Packet rate performance testing was done with pktgen 64B packets and on
>>> TX side and, TC drop action on RX side compared to XDP fast drop.
>>>
>>> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>>>
>>> Comparison is done between:
>>>         1. Baseline, Before this patch with TC drop action
>>>         2. This patch with TC drop action
>>>         3. This patch with XDP RX fast drop
>>>
>>> Streams    Baseline(TC drop)    TC drop    XDP fast Drop
>>> --------------------------------------------------------------
>>> 1           5.51Mpps            5.14Mpps     13.5Mpps
>>
>> This (13.5 M PPS) is less than 50% of the result we presented @ the
>> XDP summit which was obtained by Rana. Please see if/how much does
>> this grows if you use more sender threads, but all of them to xmit the
>> same stream/flows, so we're on one ring. That (XDP with single RX ring
>> getting packets from N remote TX rings) would be your canonical
>> base-line for any further numbers.
>>
>
> I used N TX senders sending 48Mpps to a single RX core.
> The single RX core could handle only 13.5Mpps.
>
> The implementation here is different from the one we presented at the
> summit, before, it was with striding RQ, now it is regular linked list
> RQ, (Striding RQ ring can handle 32K 64B packets and regular RQ rings
> handles only 1K)

> In striding RQ we register only 16 HW descriptors for every 32K
> packets. I.e for
> every 32K packets we access the HW only 16 times.  on the other hand,
> regular RQ will access the HW (register descriptors) once per packet,
> i.e we write to HW 1K time for 1K packets. i think this explains the
> difference.

> the catch here is that we can't use striding RQ for XDP, bummer!

yep, sounds like a bum bum bum (we went from >30M PPS to 13.5M PPS).

We used striding RQ for XDP with the prev impl. and I don't see a real
deep reason not to do so also when striding RQ doesn't use compound
pages any more.  I guess there are more details I need to catch up with
here, but the bottom result is not good and we need to re-think.

> As i said, we will have the full and final performance results on V1.
> This is just a RFC with barely quick and dirty testing

Yep, understood. But in parallel, you need to reconsider how to get along
without that bumming down of numbers.

Or.
