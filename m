From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next 0/3] ipv6: per netns FIB6 walkers and garbage collector
Date: Fri,  4 Mar 2016 11:59:05 +0100 (CET)
Message-ID: <cover.1457085016.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Martin KaFai Lau <kafai@fb.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 2ac3ac8f86f2 ("ipv6: prevent fib6_run_gc() contention") reduced
the risk of contention on FIB6 garbage collector lock on systems with
many CPUs. However, one of our customers can still observe heavy
contention on fib6_gc_lock which can even trigger the soft lockup
detector.

This is caused by garbage collector running in forced mode from a timer.
While there is one timer per network namespace, the instances of
fib6_run_gc() running from them are protected by one global spinlock so
that only one garbage collector can run at any moment and other
namespaces have to wait. As most relevant data structures are separated
per netns, there is little reason for garbage collectors blocking each
other.

Similar problem exists for walkers: changes in one tree do not need to
adjust (and block) walkers traversing FIB trees in other namespaces.

This series separates both the walkers infrastructure and garbage
collector so that they work independently in network namespaces.

Michal Kubecek (3):
  ipv6: replace global gc_args with local variable
  ipv6: per netns fib6 walkers
  ipv6: per netns FIB garbage collection

 include/net/netns/ipv6.h |  3 ++
 net/ipv6/ip6_fib.c       | 90 +++++++++++++++++++++++++++---------------------
 2 files changed, 53 insertions(+), 40 deletions(-)

-- 
2.7.2
