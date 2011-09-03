From: kaber@trash.net
Subject: [PATCH RFC 0/11] netlink: memory mapped I/O
Date: Sat,  3 Sep 2011 19:26:00 +0200
Message-ID: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56148 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab1ICR0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 13:26:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following RFC patches contain an implementation of memory mapped I/O
for netlink. The implementation is modelled after AF_PACKET memory mapped
I/O with a few differences:

- In order to perform memory mapped I/O to userspace, the kernel allocates
  skbs with the data area pointing to the data area of the mapped frames.
  All netlink subsystems assume a linear data area, so for the sake of
  simplicity, the mapped data area is not attached to the paged area but
  to skb->data. This requires introduction of a special skb alloction
  function that just allocates an skb head without the data area. Since this
  is a quite rare use case, I introduced a new function based on __alloc_skb
  instead of splitting it up into head and data alloction. The alternative
  would be to   introduce an __alloc_skb_head and __alloc_skb_data function,
  which would actually be useful for a specific error case in memory mapped
  netlink, but would require a couple of extra instructions for the common
  skb allocation case, so it doesn't really seem worth it.

  In order to get the destination memory area for skb->data before message
  construction, memory mapped netlink I/O needs to look up the destination
  socket during allocation instead of during transmission because the
  ring is owned by the receiveing socket/process. A special skb allocation
  function (netlink_alloc_skb) taking the destination pid as an argument is
  used for this, all subsystems that want to support memory mapped I/O need
  to use this function, automatic fallback to the receive queue happens
  for unconverted subsystems. Dumps automatically use memory mapped I/O if
  the receiving socket has enabled it.

  The visible effect of looking up the destination socket during allocation
  instead of transmission is that message ordering in userspace might
  change in case allocation and transmission aren't performed atomically.
  This usually doesn't matter since most subsystems have a BKL-like lock
  like the rtnl mutex, to my knowledge the currently only existing case
  where it might matter is nfnetlink_queue combined with the recently
  introduced batched verdicts, but a) that subsystem already includes
  sequence numbers which allow userspace to reorder messages in case it
  cares to, also the reodering window is quite small and b) with memory
  mapped transmission batching can be performed in a subsystem indepandant
  manner.

- AF_NETLINK contains flow control for database dumps, with regular I/O
  dump continuation are triggered based on the sockets receive queue space
  and by recvmsg() calls. Since with memory mapped I/O there are no
  recvmsg() calls under normal operation, this is done in netlink_poll(),
  under the assumption that userspace has processed all pending frames
  before invoking poll(), thus the ring is expected to have room for new
  messages. Dumps currently don't benefit as much as they could from
  memory mapped I/O because each single continuation requires a poll()
  call. A more agressive approach seems like a good idea to me, especially
  in case the socket is not subscribed to any multicast groups (IOW only
  receiving explicitly requested data).

Besides that, the memory mapped netlink implementation extends the states
defined by AF_PACKET between userspace and the kernel by a SKIP status, this
is intended for the case that userspace wants to queue frames (specifically
when using nfnetlink_queue, an IDS and stream reassembly, requested by
Eric Leblond) for a longer period of time. The kernel skips over all frames
marked with SKIP when looking or unused frames and only fails when not finding
a free frame or when having skipped the entire ring.

Also noteworthy is memory mapped sendmsg: the kernel performs validation
of messages before accepting and processing them, in order to prevent
userspace from changing the messages contents after validation, the
kernel checks that the ring is only mapped once and the file descriptor
is not shared (in order to avoid having userspace set up another mapping
after the first mentioned check). If either of both is not true, the
message copied to an allocated skb and processed as with regular I/O.
I'd especially appreciate review of this part since I'm not really versed
in memory, file and process management,

The remaining interesting details are included in the changelogs of the
individual patches and the documentation, so I won't repeat them here.

As an example, nfnetlink_queue is convererted to support memory mapped
I/O. Other subsystems that would probably benefit are nfnetlink_log,
audit and maybe ISCSI, not sure. Since I don't own sufficiently powerful
hardware for real testing, my testcases where based on iperf over loopback.
Depending on the MTU, the latest patchset shows a 900% improvement for
an MTU of 1500 and a roughly 300% improvement for an MTU of 15000.

Jesper is taking benchmarks on real hardware sometime soon, for now I'd
just like to get the basic concept reviewed. An example implementation
for userspace-queueing is available at:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/libmnl-mmap.git

once master.kernel.org is up again. My git tree of the kernel parts
is not up to date anymore, the latest patches show way better
performance in my limited test setup.

Comments and rewiew highly welcome!

Cheers,
Patrick
