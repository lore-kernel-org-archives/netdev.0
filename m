From: Ilya Dryomov <idryomov@gmail.com>
Subject: SOCK_MEMALLOC vs loopback
Date: Wed, 4 Mar 2015 21:38:48 +0300
Message-ID: <CAOi1vP8tJTMhbCyKVD66pc_Tz7+aOS236KgvQnA-S63yv1P-sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sage Weil <sage@redhat.com>, Mike Christie <mchristi@redhat.com>,
	Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.de>,
	netdev@vger.kernel.org
To: ceph-devel@vger.kernel.org, Eric Dumazet <edumazet@google.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

A short while ago Mike added a patch to libceph to set SOCK_MEMALLOC on
libceph sockets and PF_MEMALLOC around send/receive paths (commit
89baaa570ab0, "libceph: use memalloc flags for net IO").  rbd is much
like nbd and is succeptible to all the same memory allocation
deadlocks, so it seemed like a step in the right direction.

However that turned out to not play nice with loopback - such a simple
workload as 'dd if=/dev/zero of=/dev/rbd0 bs=4M' would now lock up in
no time if one or more ceph-osd (think nbd-server) processes are
running on the same box - as soon as memory gets tight and
__alloc_skb() dips into PF_MEMALLOC reserves and marks skb as
pfmemalloc, packets start being dropped on the receiving side:

int sk_filter(struct sock *sk, struct sk_buff *skb)
{
        ...

        /*
         * If the skb was allocated from pfmemalloc reserves, only
         * allow SOCK_MEMALLOC sockets to use it as this socket is
         * helping free memory
         */
        if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
                return -ENOMEM;

as the receiving ceph-osd socket is not a SOCK_MEMALLOC socket.

The motivation behind this is clear but this makes loopback rbd just
plain unusable and while we never recommended it to our users and
advised against it, we had a few "it worked for us for more than
a year" kind of reports.  It's also very useful for testing.

Some googling revealed that I'm not the first one to hit this.  SUSE
guys carried (are carrying?) a patch to sk_filter() to allow pfmemalloc
skbs through to make up for GPFS's misuse of PF_MEMALLOC [1], this was
mentioned tangentially by Eric in [2] and he suggested a possible fix
in [3].

"When I discussed with David on this issue, I said that one possibility
would be to accept a pfmemalloc skb on regular skb if no other packet is
in a receive queue, to get a chance to make progress (and limit memory
consumption to no more than one skb per TCP socket)"

Eric, was there any progress on this front?  We would like to work on
fixing this, but need some mm and net input.

(I also CC'ed Neil as he did the NFS loopback series recently and this
may touch on swap-on-nfs.)

[1] https://gitorious.org/opensuse/kernel-source/commit/a78bfd6
[2] http://article.gmane.org/gmane.linux.kernel/1418791
[3] http://article.gmane.org/gmane.linux.kernel.stable/46128

Thanks,

                Ilya
