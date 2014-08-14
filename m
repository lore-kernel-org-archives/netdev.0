From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH net v2 0/2] cbq: incorrectly low bandwidth blocks limited
 traffic
Date: Thu, 14 Aug 2014 12:27:29 +0400
Message-ID: <53EC72F1.5000501@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19593 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440AbaHNI31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 04:29:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: patch description changes
Fixes: f0f6ee1f70c4 ("cbq: incorrect processing of high limits")

Mainstream commit f0f6ee1f70c4 ("cbq: incorrect processing of high limits")
have side effect: if cbq bandwidth setting is less than real interface
throughput non-limited traffic can delay limited traffic for a very long time.

This happen because of q->now changes incorrectly in cbq_dequeue():
in described scenario L2T is much greater than real time delay,
and q->now gets an extra boost for each transmitted packet.

Accumulated boost prevents update q->now, and blocked class can wait
very long time until (q->now >= cl->undertime) will be true again.

More detailed problem description can be found here:
http://www.spinics.net/lists/netdev/msg292493.html

Following patches should fix the problem.

Vasily Averin (2):
  cbq: incorrectly low bandwidth setting blocks limited traffic
  cbq: now_rt removal

 net/sched/sch_cbq.c |   48 ++++++++++++++----------------------------------
 1 files changed, 14 insertions(+), 34 deletions(-)

My testing confirmed that it fixes the problem and did not discover
any side-effects.
