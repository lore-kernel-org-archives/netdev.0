From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Sun, 28 Jun 2009 13:10:45 +0200
Message-ID: <4A474FB5.4070901@gmail.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com> <4A443033.8060401@gmail.com> <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com> <20090626135742.GB3845@redhat.com> <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com> <20090626145027.GA6534@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:61042 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbZF1LLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 07:11:09 -0400
In-Reply-To: <20090626145027.GA6534@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oleg Nesterov wrote, On 06/26/2009 04:50 PM:

> On 06/26, Davide Libenzi wrote:
>> On Fri, 26 Jun 2009, Oleg Nesterov wrote:
>>
>>> And if we remove waitqueue_active() in xxx_update(), then lock/unlock is
>>> not needed too.
>>>
>>> If xxx_poll() takes q->lock first, it can safely miss the changes in ->status
>>> and schedule(): xxx_update() will take q->lock, notice the sleeper and wake
>>> it up (ok, it will set ->triggered but this doesn't matter).
>>>
>>> If xxx_update() takes q->lock first, xxx_poll() must see the changes in
>>> status after poll_wait()->unlock(&q->lock) (in fact, after lock, not unlock).
>> Sure. The snippet above was just to show what typically the code does, not
>> a suggestion on how to solve the socket case.
> 
> Yes, yes. I just meant you are right imho, we shouldn't add mb() into
> add_wait_queue().
> 
>> But yeah, the problem in this case is the waitqueue_active() call. Without
>> that, the wait queue lock/unlock in poll_wait() and the one in wake_up()
>> guarantees the necessary barriers.
>> Some might argue the costs of the lock/unlock of q->lock, and wonder if
>> MBs are a more efficient solution. This is something I'm not going into.
>> To me, it just looked not right having cross-matching MB in different
>> subsystems.
> 
> This is subjective and thus up to maintainers, but personally I think you
> are very, very right.
> 
> Perhaps we can add
> 
> 	void sock_poll_wait(struct file *file, struct sock *sk, poll_table *pt)
> 	{
> 		if (pt) {
> 			poll_wait(file, sk->sk_sleep, pt);
> 			/*
> 			 * fat comment
> 			 */
> 			smp_mb(); // or smp_mb__after_unlock();
> 		}
> 	}
> 
> Oleg.


Maybe 'a bit' further?:

static inline void __poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
{
	p->qproc(filp, wait_address, p);
}

static inline void poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
{
	if (p && wait_address)
		__poll_wait(filp, wait_address, p);
}

static inline void sock_poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
{
	if (p && wait_address) {
		__poll_wait(filp, wait_address, p);
		/*
		 * fat comment
		 */
		smp_mb(); // or smp_mb__after_unlock();
	}
}

Jarek P.
