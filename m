From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Bug in netem reordering
Date: Wed, 4 Jan 2012 16:44:51 -0800
Message-ID: <CAGK4HS8YBBwPtPpQhi8gas=RBE6wao6KZ1dwbwo2rxn4qXggCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61751 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264Ab2AEAow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 19:44:52 -0500
Received: by vbbfc26 with SMTP id fc26so9723vbb.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 16:44:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am getting a crash when I test the reordering feature of netem. This
happens every time I run the following tc  command and then pass some
traffic through the
interface. I am using the latest net-next kernel.

#tc qdisc add dev eth0 root netem delay 10ms reorder 25% 50%

Then wait for several packets to go through.

The problem seems to be in netem_enqueue(). Part of the code for
reordering is as follows:

 } else {
                /*
                 * Do re-ordering by putting one out of N packets at the front
                 * of the queue.
                 */
                cb->time_to_send = psched_get_time();
                q->counter = 0;

                __skb_queue_head(&sch->q, skb);
                q->qdisc->qstats.backlog += qdisc_pkt_len(skb);
                q->qdisc->qstats.requeues++;
                ret = NET_XMIT_SUCCESS;
        }


The issue is that q->qdisc is initialized to NULL (by netem_init? ).
When the else branch is executed as above after a few packets,
q->qdisc is NULL and we get a crash.
Can anyone else reproduce the problem?

Regards,
Vijay Subramanian
