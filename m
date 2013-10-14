From: Bandan Das <bsd@redhat.com>
Subject: [RFC PATCH v2 0/1] Workqueue based vhost work scheduling
Date: Sun, 13 Oct 2013 21:55:42 -0400
Message-ID: <1381715743-13672-1-git-send-email-bsd@redhat.com>
Cc: netdev@vger.kernel.org, Michael Tsirkin <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
To: kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498Ab3JNB6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Oct 2013 21:58:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a followup to RFC posted by Shirley Ma on 22 March 2012 :
NUMA aware scheduling per vhost thread patch [1]. This patch is against
3.12-rc4.

This is a step-down from the previous version in the sense that
this patch utilizes the workqueue mechanism instead of creating per-cpu
vhost threads, or in other words, the per-cpu threads are completely invisible
to vhost as they are the responsibility of the cmwq implementation. 

The workqueue implementation [2] maintains a pool of dedicated threads per CPU
that are used when work is queued. The user can control certain aspects of the 
work execution using special flags that can be passed along during the call
to alloc_workqueue. Based on this description, the approach is that instead of 
vhost creating per-cpu thread to address issues pointed out
in RFC v1, we just let the cmwq mechanism do the heavy lifting for us.
The end result is that the changes in v2 are substantially smaller compared
to v1.

The major changes wrt v1 :
 - A module param called cmwq_worker, that when enabled, uses the wq 
   backend
 - vhost doesn't manage any per cpu threads anymore, trust wq backend to 
   do the right thing.
 - A significant part of v1 was to decide where to run the job - this is 
   gone now for reasons discussed above.

Testing :

As of now, some basic netperf testing varying only the message sizes 
keeping all other factors constant (to keep it simple) I however agree that 
this needs more testing for more concrete conclusions. 

The host is Nehalem 4 cores x 4 sockets with 4G memory, cpu 0-7 - numa node0
and cpu 8-16 = numa node1.
The host is running 4 guests with -smp 4 and -m 1G to keep it somewhat 
realistic. netperf in Guest 0 interacts with netserv running in the host
for our test results.

Results :

I noticed a common signature in all the tests except UDP_RR - 
for small message sizes, the workqueue implementation has a slightly better
throughput, however with increase in message size, the throughput
degrades slightly compared to the unpatched version. I suspect that the 
vhost_submission_workfn can be modified to make this better or there could be 
other factors that I still haven't thought about. Ofcourse, we shouldn't 
forget the important condition that we are not running on a vhost 
specific dedicated thread anymore.

UDP_RR however, exhibited better results constantly for the wq version.

I include the figures for just TCP_STREAM and UDP_RR below :

TCP_STREAM

Size      Throughput (Without patch)      Throughput (With patch)
bytes          10^6bytes/sec                 10^6bytes/sec
--------------------------------------------------------------------------
256                2695.22                     2793.14
512                5682.10                     5896.34
1024               7511.18                     7295.96
2048               8197.94                     7564.50
4096               8764.95                     7822.98
8192               8205.89                     8046.49
16384              11495.72                    11101.35

UDP_RR
Size            (Without patch)            (With patch)
bytes            Trans/sec                  Trans/sec
--------------------------------------------------------------------------
256                10966.77	             14842.16
512                9930.06                   14747.76
1024               10587.85	             14544.10
2048               7172.34		     13790.56
4096               7628.35		     13333.39
8192               5663.10                   11916.82
16384              6807.25		     9994.11

I had already discussed my results with Michael privately, so sorry for 
the duplicate information, Michael!

[1] http://www.mail-archive.com/kvm@vger.kernel.org/msg69868.html
[2] Documentation/workqueue.txt 

Bandan Das (1):
  Workqueue based vhost workers

 drivers/vhost/net.c   |  25 +++++++++++
 drivers/vhost/vhost.c | 115 +++++++++++++++++++++++++++++++++++++++++++-------
 drivers/vhost/vhost.h |   6 +++
 3 files changed, 130 insertions(+), 16 deletions(-)

-- 
1.8.3.1
