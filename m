From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: hang in ip_finish_output
Date: Mon, 18 Jan 2016 18:20:24 -0800
Message-ID: <1453170024.1223.251.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEfhGiwsgd7-10ggn1EP4zTg3_mpqphWUnCo_7dSkRf=-jtmXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32871 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756738AbcASCU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 21:20:27 -0500
In-Reply-To: <CAEfhGiwsgd7-10ggn1EP4zTg3_mpqphWUnCo_7dSkRf=-jtmXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-18 at 13:33 -0500, Craig Gallek wrote:

> Thanks Eric, I'm still scratching my head over this one.  Your patches
> make sense, but I don't think they solve this particular issue.  I was
> still able to trigger the soft lockup with them applied.
> 
> I thought it has something to do with relying on RCU to dereference
> the sk_reuseport_cb pointer from a soft interrupt.  As far as I can
> tell, though, the only difference between rcu_dereference and
> rcu_dereference_bh (and rcu_read_lock and rcu_read_lock_bh) is the
> lock analysis code that gets compiled in in debug mode (in which case
> we should almost certainly be using the bh versions of the rcu
> functions).  However, I can still trigger the soft lookup even when I
> completely remove the RCU functions and use the (racy) raw pointer.
> 
> Below is a stack with your patches applied and the RCU functions
> completely removed.  I'm able to trigger it using a bunch of parallel
> instances of Dmitry's test program running on separate CPU sockets (eg
> for i in `seq 100`; do taskset -c 10,40 /tmp/rcu_stall & done)

Same reason really.

Right after sk2=socket(), setsockopt(sk2,...,SO_REUSEPORT, on) and
bind(sk2, ...), but _before_ the connect(sk2) is done, sk2 is added into
the soreuseport array, with a score which is smaller than the score of
first socket sk1 found in hash table (I am speaking of the regular UDP
hash table), if sk1 had the connect() done, giving a +8 to its score.

So the bug has nothing to do with rcu or rcu_bh, it is just an infinite
loop caused by different scores.


hash bucket [X] -> sk1 -> sk2 -> NULL

sk1 score = 14  (because it did a connect())
sk2 score = 6

I guess we should relax the test done after atomic_inc_not_zero_hint()
to only test the base keys : 
(net, ipv6_only_sock, inet->inet_rcv_saddr & inet->inet_num)
