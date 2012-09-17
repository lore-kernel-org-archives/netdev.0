From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [TCP]: functionality of delayed_ack in Bic and Cubic Algorithm
 ?
Date: Mon, 17 Sep 2012 12:29:16 -0700
Message-ID: <20120917122916.4b2ccce3@nehalam.linuxnetplumber.net>
References: <5056897A.9010009@gmail.com>
	<50568C3A.9060908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yi Li <lovelylich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44153 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932417Ab2IQT3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 15:29:46 -0400
In-Reply-To: <50568C3A.9060908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Sep 2012 10:34:34 +0800
Yi Li <lovelylich@gmail.com> wrote:

> Hi All,
> I am try to understand the patch:
> http://patchwork.usersys.redhat.com/patch/43827/.
> But I am not sure of the functionality of delayed_ack filed in Bic and
> Cubic.
> I have found the following mails:
> http://oss.sgi.com/archives/netdev/2005-02/msg00808.html
> which is the first patch introducing the *delayed_ack* field.
> ( But I am not fully understand that material, That's why I have asked
> here.)
> 
> So, here is my understanding of this field, and I am not sure whether it
> is right. :-(
> Question One:
> From comment in *struct bictcp*, delayed_ack is "the ratio of
> Packets/ACKs << 4"
> and it's updating is in function bictcp_acked():
> 
>     /* Track delayed acknowledgment ratio using sliding window
>     * ratio = (15*ratio + sample) / 16
>     */
>     static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
>     {
>     const struct inet_connection_sock *icsk = inet_csk(sk);
>     const struct tcp_sock *tp = tcp_sk(sk);
>     struct bictcp *ca = inet_csk_ca(sk);
>     u32 delay;
> 
>     if (icsk->icsk_ca_state == TCP_CA_Open) {
>     cnt -= ca->delayed_ack >> ACK_RATIO_SHIFT;
>     ca->delayed_ack += cnt;
>     }
> 
> After googling, I know ratio == delayed_ack >> ACK_RATIO_SHIFT. so here
> we are updating
> the Packets/Acks ratio, basing on the history of ratio (15/16) and the
> current ratio(1/16).
> The current ratio is cnt packets acked by the current acknowledgement,
> divided by the current
> count of acknowledgements(of course it is 1 ack packet). Right?
> 
> Question Two:
> And we update the ca->cnt in function bictcp_update():
> ca->cnt = (ca->cnt << ACK_RATIO_SHIFT) / ca->delayed_ack;
> if (ca->cnt == 0) /* cannot be zero */
> ca->cnt = 1;
> It means ca->cnt= ca->cnt * Acks/Packets. Suppose normal delayed ack,
> Acks/Packets should be 1/2.
> So, ca->cnt will be cut in half. As a result, snd_cwnd will increase one
> times more rapidly, and this is just a
> compensation for delayed ack. So, TCP will still work normally. Right?
>


In Cubic, congestion window is always increased if the ack is okay,
and the flow is limited by the congestion window.  If the receiver
is using delayed acknowledgement, the code wants to adapt to that
problem. MacOS was particularly bad and would only ack every four
packets, and without this change, the window would grow very slowly.

The delayed_ack is maintained as a scaled value (instead of floating point)
because floating point is slow and not easily used in the kernel.

The update is a sliding average is updated while processing a TCP
acknowledgement. 1/16 of the average is the value cnt (the number
of packets acked in this pass) and the rest (15/16) is the
last sliding average.  If the receiver was acking every other packet
the field ca->delayed_ack would converge to 32 = 2<<4.

The ca->cnt update is first estimated based on curves an
the tcp_friendliness limitation.  The ca->cnt is then adjusted using
delayed_ack. The idea is that congestion window should grow at
the same rate independent of the delayed ack strategy used by the
receiver.


Note: Only look at the CUBIC code , ignore BIC, it is deprecated and should not be used.
It remains in Linux kernel only for historical reference.
