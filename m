From: Or Gerlitz via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf
	programs support
Date: Wed, 7 Sep 2016 23:55:42 +0300
Message-ID: <CAJ3xEMgsGHqQ7x8wky6Sfs34Ry67PnZEhYmnK=g8XnnXbgWagg@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-9-git-send-email-saeedm@mellanox.com>
Reply-To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>, Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <1473252152-11379-9-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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

On Wed, Sep 7, 2016 at 3:42 PM, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> From: Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>
> Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx5e driver.
>
> When XDP is on we make sure to change channels RQs type to
> MLX5_WQ_TYPE_LINKED_LIST rather than "striding RQ" type to
> ensure "page per packet".
>
> On XDP set, we fail if HW LRO is set and request from user to turn it
> off.  Since on ConnectX4-LX HW LRO is always on by default, this will be
> annoying, but we prefer not to enforce LRO off from XDP set function.
>
> Full channels reset (close/open) is required only when setting XDP
> on/off.
>
> When XDP set is called just to exchange programs, we will update
> each RQ xdp program on the fly and for synchronization with current
> data path RX activity of that RQ, we temporally disable that RQ and
> ensure RX path is not running, quickly update and re-enable that RQ,
> for that we do:
>         - rq.state = disabled
>         - napi_synnchronize
>         - xchg(rq->xdp_prg)
>         - rq.state = enabled
>         - napi_schedule // Just in case we've missed an IRQ
>
> Packet rate performance testing was done with pktgen 64B packets and on
> TX side and, TC drop action on RX side compared to XDP fast drop.
>
> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>
> Comparison is done between:
>         1. Baseline, Before this patch with TC drop action
>         2. This patch with TC drop action
>         3. This patch with XDP RX fast drop
>
> Streams    Baseline(TC drop)    TC drop    XDP fast Drop
> --------------------------------------------------------------
> 1           5.51Mpps            5.14Mpps     13.5Mpps

This (13.5 M PPS) is less than 50% of the result we presented @ the
XDP summit which was obtained by Rana. Please see if/how much does
this grows if you use more sender threads, but all of them to xmit the
same stream/flows, so we're on one ring. That (XDP with single RX ring
getting packets from N remote TX rings) would be your canonical
base-line for any further numbers.
