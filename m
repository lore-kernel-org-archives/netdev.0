From: "Ali Ozyagci" <ali.ozyagci@gmail.com>
Subject: Help on token bucket filter queue
Date: Wed, 23 May 2007 18:57:11 +0200
Message-ID: <6dac5d1b0705230957q2237b51ct7c0a59b3931cf775@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bert.hubert@netherlabs.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:2987 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756514AbXEWQ5O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 12:57:14 -0400
Received: by an-out-0708.google.com with SMTP id d31so69418and
        for <netdev@vger.kernel.org>; Wed, 23 May 2007 09:57:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am trying to imitate the medium access behavior in HSDPA using wired
ethernet in my research in order to see how TCP behaves under such a
MAC. What I want to do is to send packets (if there are any in the
queue) for the duration of about 2 milliseconds and then keep silent
for some time, in the order of 100milliseconds.

I managed to modify sch_tbf.c to prevent the interface from sending
packets if microseconds in the system clock is not between 3000 and
5000. These particular numbers are irrelevant, I just found it easier
to implement like this. So, for 2 milliseconds the interface can send
packets, otherwise it is silent. What I did was to read the system
time in tbf_dequeue funciton and return a NULL pointer if microseconds
didn't fall in the specified interval.

This is my first attempt to do any kernel programming, so I could
really use some advice on style and approach with this. Is it sensible
to use udelay in kernel code? Is there a more appropriate way of
programming the device to sleep for a number of milliseconds? Should I
try to implement this behavior in the network code rather than queuing
disciplines?

Also a I noticed that every time a packet is enqueued, tbf_dequeue is
called immediately, but I could not track down where exactly this was
called. Is this the expected behavior, or did I forget to set some
flags?

The modified version of tbf_dequeue function follows, only minor
changes. Thanks in advance for any help and suggestions.
Ali =D6zyagci


Here is the function:

static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
{
	struct tbf_sched_data *q =3D qdisc_priv(sch);

/* Modifications to tbf_dequeue function to keep the queue silent (alth=
ough
   there are backlogged packets) until the beginning of the next timesl=
ot.
   The timeslot during which I can send packets is (3, 5) milliseconds =
of each
   100 milliseconds.
*/
	psched_time_t currentTime;
	PSCHED_GET_TIME(currentTime);
	int excess_usecs =3D currentTime.tv_usec % 100000;
=09
	if ( excess_usecs  > 5000) {
	/* Missed this slot for transmission. Sleep until the beginning of
	the next 100msec interval, so do not send the packet now (therefore
	return NULL), but set the timer so we return to tbf_dequeue near the
	beginning of the next 100msec timeslot. Ideally next time tbf_dequeue
	is called, this block should not execute but the else block below shou=
ld
	 execute. */
		mod_timer(&q->wd_timer, jiffies+ 101 - (int)(excess_usecs/1000));
	/* I'm not sure if this is needed, I got to study the network code
	more. */
		sch->flags |=3D TCQ_F_THROTTLED;
		return NULL;
	}
	else if ( excess_usecs < 3000 ){
	/* tv_usec is less than 3000, sleep until 3000 usecs have passed into =
this
	   interval. I used udelay instead of programming the watchdog because=
 I
	   didn't want to miss some microseconds in the beginning of this time=
slot
	   because of timer tick jitters.*/
		udelay(3000 - excess_usecs);
	}
	/* Here, 3000<tv_usec<5000 so proceed with transmission. I didn't make=
 any
	   further changes to the code.*/

	struct sk_buff *skb;

	skb =3D q->qdisc->dequeue(q->qdisc);

	if (skb) {
		psched_time_t now;
		long toks, delay;
		long ptoks =3D 0;
		unsigned int len =3D skb->len;

		PSCHED_GET_TIME(now);
		toks =3D PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer);
		if (q->P_tab) {
			ptoks =3D toks + q->ptokens;
			if (ptoks > (long)q->mtu)
				ptoks =3D q->mtu;
			ptoks -=3D L2T_P(q, len);
		}
		toks +=3D q->tokens;
		if (toks > (long)q->buffer)
			toks =3D q->buffer;
		toks -=3D L2T(q, len);

		if ((toks|ptoks) >=3D 0) {
			q->t_c =3D now;
			q->tokens =3D toks;
			q->ptokens =3D ptoks;
			sch->q.qlen--;
			sch->flags &=3D ~TCQ_F_THROTTLED;
			return skb;
		}

		delay =3D PSCHED_US2JIFFIE(max_t(long, -toks, -ptoks));

		if (delay =3D=3D 0)
			delay =3D 1;

		mod_timer(&q->wd_timer, jiffies+delay);

		/* Maybe we have a shorter packet in the queue,
		   which can be sent now. It sounds cool,
		   but, however, this is wrong in principle.
		   We MUST NOT reorder packets under these circumstances.

		   Really, if we split the flow into independent
		   subflows, it would be a very good solution.
		   This is the main idea of all FQ algorithms
		   (cf. CSZ, HPFQ, HFSC)
		 */

		if (q->qdisc->ops->requeue(skb, q->qdisc) !=3D NET_XMIT_SUCCESS) {
			/* When requeue fails skb is dropped */
			sch->q.qlen--;
			sch->qstats.drops++;
		}

		sch->flags |=3D TCQ_F_THROTTLED;
		sch->qstats.overlimits++;
	}
	return NULL;
}
