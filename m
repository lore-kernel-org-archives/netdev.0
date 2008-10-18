From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: sch_generic: Fix oops in sch_teql
Date: Sun, 19 Oct 2008 01:09:38 +0200
Message-ID: <20081018230938.GC6048@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:19087 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbYJRXJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 19:09:44 -0400
Received: by nf-out-0910.google.com with SMTP id d3so632632nfc.21
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2008 16:09:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: sch_generic: Fix oops in sch_teql

After these commands:
# modprobe sch_teql
# tc qdisc add dev eth0 root teql0
# tc qdisc del dev eth0 root
we get an oops in teql_destroy() when spin_lock is taken from a null
qdisc_sleeping pointer. It's because at the moment teql0 dev haven't
been activated yet, and a qdisc_root_sleeping() is pointing to noop
qdisc's netdev_queue with qdisc_sleeping uninitialized. This patch
fixes this both for noop and noqueue netdev_queues to avoid similar
problems in the future.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
[regression in 2.6.27]
---

 net/sched/sch_generic.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7b5572d..93cd30c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -326,6 +326,7 @@ struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 
 static struct netdev_queue noop_netdev_queue = {
 	.qdisc		=	&noop_qdisc,
+	.qdisc_sleeping	=	&noop_qdisc,
 };
 
 struct Qdisc noop_qdisc = {
@@ -352,6 +353,7 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 static struct Qdisc noqueue_qdisc;
 static struct netdev_queue noqueue_netdev_queue = {
 	.qdisc		=	&noqueue_qdisc,
+	.qdisc_sleeping	=	&noqueue_qdisc,
 };
 
 static struct Qdisc noqueue_qdisc = {
