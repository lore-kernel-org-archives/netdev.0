From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH] HFSC - initialize parent's cl_cfmin properly in init_vf()
Date: Mon, 30 Aug 2010 23:33:15 +0200
Message-ID: <cover.1283197803.git.soltys@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:4083 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754528Ab0H3Vm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 17:42:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider following hierarchy:

      A(u)
     /  \
    X    Y(u)

A and Y have upperlimit curve defined, X - doesn't. We'll assume that no
realtime curve is present in either of the classes, for the sake of
simplicity.

Assume that Y is constantly backlogged, and then a new traffic gets
assigned to X - 1st packet will trigger set_active() and init_vf().

The problem: although init_vf() will properly add X to A's cftree, A's
cfmin will never be updated. The reason for that is - cftree_insert()
only inserts, but doesn't really care for that variable. On the other
hand, last condition in init_vf() function will never be true, thus
update_cfmin(cl->cl_parent) will not be called as X has no upperlimit
curve, and all three cl_f, cl_myf, cl_cfmin are always 0 for X.

When some packet from Y gets dequeued, it will update cl_cfmin()
accordingly, and X's packets will get dequeued in a bursty fashion.

The best way to experience the practical effects of this bug: create the
above hierarchy in highly assymetric fashion - e.g.:

#tc qdisc add dev eth0 root handle 1:0 hfsc default 301
#tc class add dev eth0 parent 1:0 classid 1:300 hfsc ls m2 90mbit ul m2 90mbit

#tc class add dev eth0 parent 1:300 classid 1:301 hfsc ls m2 99950kbit
#tc class add dev eth0 parent 1:300 classid 1:302 hfsc ls m2 50kbit ul m2 50kbit

...and then assign ssh session to 1:301, making sure 1:302 is constantly
backlogged. Do ls -alR / or edit some file, the effect will be evident.

The problem naturally extends to any hierarchy of classes, where some of
the leafs have no upperlimit curve. Realtime curve can help a bit - but
update_vf() doesn't call update_cfmin() unconditionally either, so we're
left on the mercy of other classes to do so.

Furthermore, each time such a class becomes passive - the problem will
reappear once we become backlogged again.

The fix is very simple - init_vf() should always call update_cfmin() at
the end of the for loop. It seems it's not necessary to make update_vf()
do the same - init_vf() will guarantee the call on the beginning of
every new backlog period, and the further calls are only necessary if
cl_f changes.


Michal Soltys (1):
  net/sched/sch_hfsc.c: initialize parent's cl_cfmin properly in init_vf()

 net/sched/sch_hfsc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

-- 
1.7.2.1

