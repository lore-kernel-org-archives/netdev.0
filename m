From: Tom Herbert via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
	more
Date: Mon, 12 Sep 2016 14:45:08 -0700
Message-ID: <CALx6S35y8LXq6JECbKAifkxKgHGZ3cLDP_MNNkqwfhm0k8OWZQ@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<20160908101147.1b351432@redhat.com>
	<20160909032202.GA62966@ast-mbp.thefacebook.com>
	<CALzJLG_r0pDJgxqqak5=NatT8tF7UP2NkGS1wjeWcS5C=Zvv2A@mail.gmail.com>
	<20160912121530.4b4f0ad7@redhat.com>
Reply-To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160912121530.4b4f0ad7-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Mon, Sep 12, 2016 at 3:15 AM, Jesper Dangaard Brouer
<brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, 9 Sep 2016 18:03:09 +0300
> Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
>
>> On Fri, Sep 9, 2016 at 6:22 AM, Alexei Starovoitov via iovisor-dev
>> <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org> wrote:
>> > On Thu, Sep 08, 2016 at 10:11:47AM +0200, Jesper Dangaard Brouer wrote:
>> >>
>> >> I'm sorry but I have a problem with this patch!
>> >> Looking at this patch, I want to bring up a fundamental architectural
>> >> concern with the development direction of XDP transmit.
>> >>
>> >>
>> >> What you are trying to implement, with delaying the doorbell, is
>> >> basically TX bulking for TX_XDP.
>> >>
>> >>  Why not implement a TX bulking interface directly instead?!?
>> >>
>> >> Yes, the tailptr/doorbell is the most costly operation, but why not
>> >> also take advantage of the benefits of bulking for other parts of the
>> >> code? (benefit is smaller, by every cycles counts in this area)
>> >>
>> >> This hole XDP exercise is about avoiding having a transaction cost per
>> >> packet, that reads "bulking" or "bundling" of packets, where possible.
>> >>
>> >>  Lets do bundling/bulking from the start!
>>
>> Jesper, what we did here is also bulking, instead of bulking in a
>> temporary list in the driver we list the packets in the HW and once
>> done we transmit all at once via the xdp_doorbell indication.
>>
>> I agree with you that we can take advantage and improve the icache by
>> bulking first in software and then queue all at once in the hw then
>> ring one doorbell.
>>
>> but I also agree with Alexei that this will introduce an extra
>> pointer/list handling in the driver and we need to do the comparison
>> between both approaches before we decide which is better.
>
> I welcome implementing both approaches and benchmarking them against
> each-other, I'll gladly dedicate time for this!
>
Yes, please implement this so we can have something clear to evaluate
and compare. There is far to much spewing of "expert opinions"
happening here :-(

> I'm reacting so loudly, because this is a mental model switch, that
> need to be applied to the full drivers RX path. Also for normal stack
> delivery of SKBs. As both Edward Cree[1] and I[2] have demonstrated,
> there is between 10%-25% perf gain here.
>
> The key point is stop seeing the lowest driver RX as something that
> works on a per packet basis.  It might be easier to view this as a kind
> of vector processing.  This is about having a vector of packets, where
> we apply some action/operation.
>
> This is about using the CPU more efficiently, getting it to do more
> instructions per cycle.  The next level of optimization (for >= Sandy
> Bridge CPUs) is to make these vector processing stages small enough to fit
> into the CPUs decoded-I-cache section.
>
>
> It might also be important to mention, that for netstack delivery, I
> don't imagine bulking 64 packets.  Instead, I imagine doing 8-16
> packets.  Why, because the NIC-HW runs independently and have the
> opportunity to deliver more frames in the RX ring queue, while the
> stack "slow" processed packets.  You can view this as "bulking" from
> the RX ring queue, with a "look-back" before exiting the NAPI poll loop.
>
>
>> this must be marked as future work and not have this from the start.
>
> We both know that statement is BS, and the other approach will never be
> implemented once this patch is accepted upstream.
>
>
>> > mlx4 already does bulking and this proposed mlx5 set of patches
>> > does bulking as well.
>
> I'm reacting exactly because mlx4 is also doing "bulking" in the wrong
> way IMHO.  And now mlx5 is building on the same principle. That is why
> I'm yelling STOP.
>
>
>> >> The reason behind the xmit_more API is that we could not change the
>> >> API of all the drivers.  And we found that calling an explicit NDO
>> >> flush came at a cost (only approx 7 ns IIRC), but it still a cost that
>> >> would hit the common single packet use-case.
>> >>
>> >> It should be really easy to build a bundle of packets that need XDP_TX
>> >> action, especially given you only have a single destination "port".
>> >> And then you XDP_TX send this bundle before mlx5_cqwq_update_db_record.
>
>
> [1] http://lists.openwall.net/netdev/2016/04/19/89
> [2] http://lists.openwall.net/netdev/2016/01/15/51
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
