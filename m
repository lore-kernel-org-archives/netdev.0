From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 00/12] drop the qdisc lock for pfifo_fast/mq
Date: Wed, 30 Dec 2015 09:50:36 -0800
Message-ID: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34440 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216AbbL3Ru6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:50:58 -0500
Received: by mail-pa0-f51.google.com with SMTP id uo6so119557392pac.1
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:50:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is a first take at removing the qdisc lock on the xmit path
where qdiscs actually have queues of skbs. The ingress qdisc
which is already lockless was "easy" at least in the sense that
we did not need any lock-free data structures to hold skbs.

The series here is experimental at the moment I decided to dump
it to netdev list when the list of folks I wanted to send it to
privately grew to three or four. Hopefully more people will take
a look at it and give feedback/criticism/whatever. For now I've
only done very basic performance tests and it showed a slight
performance improvement with pfifo_fast but this is somewhat to
be expected as the dequeue operation in the qdisc is only removing
a single skb at a time a bulk dequeue would be better presumably
so I'm tinkering with a pfifo_bulk or option to pfifo_fast to make
that work. All that said I ran some traffic over night and my
kernel didn't crash, did a few interface resets and up/downs and
functionally everything is still up and running. On the TODO list
though is to review all the code paths into/out of sch_generic and
sch_api at the moment no promises I didn't miss a path.

The plan of attack here was

 - use the alf_queue (patch 1 from Jesper) and then convert
   pfifo_fast linked list of skbs over to the alf_queue.

 - fixup all the cases where pfifo fast uses qstats to be per-cpu

 - fixup qlen to support per cpu operations

 - make the gso_skb logic per cpu so any given cpu can park an
   skb when the driver throws an error or we get a cpu collision

 - wrap all the qdisc_lock calls in the xmit path with a wrapper
   that checks for a NOLOCK flag first

 - set the per cpu stats bit and nolock bit in pfifo fast and
   see if it works.

On the TODO list,

 - get some performance numbers for various cases all I've done
   so far is run some basic pktgen tests with a debug kernel and
   a few 'perf records'. Both seem to look positive but I'll do
   some more tests over the next few days.

 - review the code paths some more

 - have some cleanup/improvements/review to do in alf_queue

 - add helpers to remove nasty **void casts in alf_queue ops

 - support bulk dequeue from qdisc either pfifo_fast or new qdisc

 - support mqprio and multiq. multiq lets me run classifiers/actions
   and with the lockless bit lets multiple cpus run in parrallel
   for performance close to mq and mqprio.

Another note in my original take on this I tried to rework some of
the error handling out of the drivers and cpu_collision paths to drop
the gso_skb logic altogether. By using dql we could/should(?) know
if a pkt can be consumed at least in the ONETX case. I haven't given
up on this but it got a bit tricky so I dropped it for now.

---

John Fastabend (12):
      lib: array based lock free queue
      net: sched: free per cpu bstats
      net: sched: allow qdiscs to handle locking
      net: sched: provide per cpu qstat helpers
      net: sched: per cpu gso handlers
      net: sched: support qdisc_reset on NOLOCK qdisc
      net: sched: qdisc_qlen for per cpu logic
      net: sched: a dflt qdisc may be used with per cpu stats
      net: sched: pfifo_fast use alf_queue
      net: sched: helper to sum qlen
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mq
      net: sched: pfifo_fast new option to deque multiple pkts


 include/linux/alf_queue.h |  368 +++++++++++++++++++++++++++++++++++++++++++++
 include/net/gen_stats.h   |    3 
 include/net/sch_generic.h |  101 ++++++++++++
 lib/Makefile              |    2 
 lib/alf_queue.c           |   42 +++++
 net/core/dev.c            |   20 +-
 net/core/gen_stats.c      |    9 +
 net/sched/sch_generic.c   |  237 +++++++++++++++++++++--------
 net/sched/sch_mq.c        |   25 ++-
 9 files changed, 717 insertions(+), 90 deletions(-)
 create mode 100644 include/linux/alf_queue.h
 create mode 100644 lib/alf_queue.c

--
Signature
