From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/11] netlink: memory mapped I/O
Date: Mon, 20 Aug 2012 08:18:41 +0200
Message-ID: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches contain an implementation of memory mapped I/O for
netlink, rebased onto the current net-next tree. The implementation is
modelled after AF_PACKET memory mapped I/O with a few differences:

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

As an example, nfnetlink_queue is convererted to support memory mapped
I/O. Other subsystems that would probably benefit are nfnetlink_log,
audit and maybe ISCSI.

Since the last posting only a minor bug in ring teardown has been fixed.
I'm still working with Florian on solving the nfnetlink_queue ordering
issue, besides that there are no known issues.

Some older performance numbers with nfnetlink_queue from Florian:

nfq recv: regular netlink I/O
mnl recv: mmap'ed netlink I/O
batch: number of batched verdicts

1400 byte UDP packets, 8 cores, NFQUEUE balancing using 4 queues, only
mmap'ed RX, regular TX, userspace running inline Snort with all rules
and preprocessors enabled:

nfq recv, batch 0  1250 MBit total rx
mnl recv, batch 0  1230 MBit total rx
nfq recv, batch 10 1590 MBit total rx
mnl recv, batch 10 1770 MBit total rx

I'll try to get some new numbers soon, including TX and dumps.


The patches are available in a git tree at:

git://github.com/kaber/netlink-mmap master

once git push has finished.


Patrick McHardy (11):
      netlink: add symbolic value for congested state
      net: add function to allocate skbuff head without data area
      netlink: don't orphan skb in netlink_trim()
      netlink: add netlink_skb_set_owner_r()
      netlink: mmaped netlink: ring setup
      netlink: add mmap'ed netlink helper functions
      netlink: implement memory mapped sendmsg()
      netlink: implement memory mapped recvmsg()
      nfnetlink: add support for memory mapped netlink
      netlink: add flow control for memory mapped I/O
      netlink: add documentation for memory mapped I/O

 Documentation/networking/netlink_mmap.txt |  337 ++++++++++++
 include/linux/netfilter/nfnetlink.h       |    2 +
 include/linux/netlink.h                   |   42 ++
 include/linux/skbuff.h                    |    6 +
 net/Kconfig                               |    9 +
 net/core/skbuff.c                         |   31 +-
 net/netfilter/nfnetlink.c                 |    7 +
 net/netfilter/nfnetlink_log.c             |    9 +-
 net/netfilter/nfnetlink_queue_core.c      |    2 +-
 net/netlink/af_netlink.c                  |  849 +++++++++++++++++++++++++++--
 10 files changed, 1250 insertions(+), 44 deletions(-)

