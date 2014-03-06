From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/5] net_sched: Adjust qdisc_change() for command "#tc qdisc change/replace ..."
Date: Thu, 6 Mar 2014 21:08:36 +0800
Message-ID: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:13543 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaCFNIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:08:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current commands "#tc qdisc replace..." and "#tc qdisc change..."
are not doing what they're supposed to do.

E.g.

With "#tc qdisc replace ...", it won't clear old option if not specified in
qdisc of netem.

   # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
   # tc qdisc show
     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit

   # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
   # tc qdisc show
     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit
The old option "rate" is still there.

With "#tc qdisc change ... ", it will clear old options if not specified in
qdisc of tbf.

  # tc qdisc add dev eth4 handle 1: root tbf rate 10mbit burst 10kb latency 50ms mtu 64kb peakrate 20mbit
  # tc qdisc show
    qdisc tbf 1: dev eth4 root refcnt 2 rate 10Mbit burst 10Kb peakrate 20Mbit minburst 64Kb lat 50.0ms
  # tc qdisc change dev eth4 handle 1: root tbf rate 20mbit burst 10kb latency 50ms
  # tc qdisc show
    qdisc tbf 1: dev eth4 root refcnt 2 rate 20Mbit burst 10Kb lat 50.0ms
The old peakrate and minburst are cleared.

This patchset adds a flag parameter in qdisc_change and a replace func in struct Qdisc_ops.
If the flag has NLM_F_REPLACE, we call the replace function, or call the change function in
qdisc_change(). And, add tbf_replace() and netem_replace() needed by tbf and netem.

Yang Yingliang (5):
  net_sched: add flag parameter in qdisc_change
  net_sched: add replace func in struct Qdisc_ops
  sch_tbf: change name "tbf_change" to "tbf_replace"
  sch_tbf: add tbf_change for #tc qdisc change ...
  sch_netem: add netem_replace for #tc qdisc replace ...

 include/net/sch_generic.h |   1 +
 net/sched/sch_api.c       |  16 ++++--
 net/sched/sch_netem.c     | 127 ++++++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_tbf.c       | 120 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 258 insertions(+), 6 deletions(-)

-- 
1.8.0
