From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: FYI: Xen or kernel bug? (fwd)
Date: Fri, 20 Apr 2007 14:24:42 -0700
Message-ID: <20070420142442.5f621ebd@dxpl.pdx.osdl.net>
References: <Line.LNX.4.64.0704201638500.19208@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>, Mark Stier <markstier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:38717 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767255AbXDTVZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 17:25:33 -0400
In-Reply-To: <Line.LNX.4.64.0704201638500.19208@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Apr 2007 16:39:27 -0400 (EDT)
James Morris <jmorris@namei.org> wrote:

> Could be an upstream kernel issue lurking.
> 
> 
> ---------- Forwarded message ----------
> Date: Fri, 20 Apr 2007 22:21:26 +0200
> From: Mark Stier <markstier@gmail.com>
> To: linux-kernel@vger.kernel.org
> Subject: FYI: Xen or kernel bug?
> 
> Hello,
> 
> tcp_vegas produces division by zero kernel oopses in dom0 when running
> a Xen-patched 2.6.16.28 kernel. I have tracked down the problem to
> line #256 in tcp_vegas.c: presumably due to flaky Xen timing, the rtt
> seems to get zero from time to time (adding 1 to the rtt variable
> solves the problem for me). The same should apply to line #140 in
> tcp_veno.c, too.
> 
> Best regards,
> Mark

Something different is happening, it shouldn't be possible to get
zero there? Maybe Xen timing is so bad that you are seeing 32 bit
wraparound.

Given this, rtt can't be zero...
-----------
static void tcp_vegas_rtt_calc(struct sock *sk, u32 usrtt)
{
	struct vegas *vegas = inet_csk_ca(sk);
	u32 vrtt = usrtt + 1; /* Never allow zero rtt or baseRTT */

	/* Filter to find propagation delay: */
	if (vrtt < vegas->baseRTT)
		vegas->baseRTT = vrtt;

	/* Find the min RTT during the last RTT to find
	 * the current prop. delay + queuing delay:
	 */
	vegas->minRTT = min(vegas->minRTT, vrtt);
	vegas->cntRTT++;
--------

And we must have samples to get there.


static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack,
				 u32 seq_rtt, u32 in_flight, int flag)
{
...
		 * If  we have 3 samples, we should be OK.
		 */

		if (vegas->cntRTT <= 2) {
			/* We don't have enough RTT samples to do the Vegas
			 * calculation, so we'll behave like Reno.
			 */
			tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
		} else {
			u32 rtt, target_cwnd, diff;

			/* We have enough RTT samples, so, using the Vegas
			 * algorithm, we determine if we should increase or
			 * decrease cwnd, and by how much.
			 */
			/* Pluck out the RTT we are using for the Vegas
			 * calculations. This is the min RTT seen during the
			 * last RTT. Taking the min filters out the effects
			 * of delayed ACKs, at the cost of noticing congestion
			 * a bit later.
			 */
			rtt = vegas->minRTT;

			/* Calculate the cwnd we should have, if we weren't
			 * going too fast.
			 *
			 * This is:
			 *     (actual rate in segments) * baseRTT
			 * We keep it as a fixed point number with
			 * V_PARAM_SHIFT bits to the right of the binary point.
			 */
			target_cwnd = ((old_wnd * vegas->baseRTT)
				       << V_PARAM_SHIFT) / rtt;

So how does rtt get to zero?
There is a possible problem if RTT is ever > 4294 seconds but if you have that
big a RTT other stuff is happening.
