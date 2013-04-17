From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/14]: netlink: memory mapped I/O
Date: Wed, 17 Apr 2013 18:46:55 +0200
Message-ID: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60947 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756351Ab3DQQrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches contain an implementation of memory mapped I/O for
netlink. The implementation is modelled after AF_PACKET memory mapped I/O
with a few differences:

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
audit and maybe ISCSI, not sure.

Following are some numbers collected by Florian Westphal based on a
slightly older version, which included an experimental patch for the
nfnetlink_queue ordering issue.

===

Test hardware is a 12-core machine
Intel(R) Xeon(R) CPU E5-2620 0 @ 2.00GHz
ixgbe interfaces are used (i.e., multiqueue nics).
irqs are distributed across the cpus.

I've made several tests.

The simple one consists of 3GBit UDP traffic, packets are 1500 bytes
in size (i.e., no fragmentation), with a single nfqueue
and the test client programs in libmnl examples directory.
Packets are sent from one /24 net to another /24 net, i.e.
there are a few hundred flows active at any given time.

I've also tested with snort, but I disabled all rules.
6Gbit UDP traffic is generated in the snort case, and
6 nfqueues are used (i.e., 6 snorts run in parallel).

I've tested with 3 different kernels, all based on 3.7.1.
- 3.7.1, without the mmap patches
- 3.7.1, with Patricks mmap patches
- 3.7.1, with mmap patches and extended spinlock to ensure packet ids are
  monotonically increasing and cannot be re-ordered.  This is what we
  currently ship in our product.

  [ the spinlock that is extended is the per nfqueue spinlock, it will
    be held from the time the netlink skb is allocated until the netlink
    skb is sent to userspace:

    http://1984.lsi.us.es/git/nf-next/commit/?h=mmap-netlink3&id=b8eb19c46650fef4e9e4fe53f367f99bbf72afc9
  ]

snort is normally used in "batch mode", i.e., after processing 25 packets
a single "batch verdict" is sent to accept the packets seen so far.
"mmap snort" means RX_RING + sendmsg(), i.e. TX_RING is not used at this
time (except where noted below).

One reason is that snort has a reload thread, so kernel needs to copy;
also in the snort case no payload rewrite takes place, so compared
to the rx path the tx path is cheap.

Results:

3.7.1, without mmap patches, i.e. recv()+sendmsg() for everyone
nfq-queue:           1.7 gbit out
snort-recv-batch-25  5.1 gbit out
snort-recv-no-batch  3.1 gbit out

3.7.1 + mmap + without extended spinlocked section
nfq-queue:           1.7 gbit out (recv/sendmsg)
nfq-queue-mmap:      2.4 gbit out
snort-mmap-batch-25	 5.6 gbit out  (warning: since ids can be
                                        re-ordered, this version is "broken").
snort-recv-batch-25	 5.1 gbit out
snort-mmap-no-batch	 4.6 gbit out (i.e., one verdict per packet)

Kernel 3.7.1 + mmap + extended spinlock section:
nfq-queue:	1.4 gbit out
nfq-queue-mmap: 2.3 gbit out
snort:          5.6 gbit out

Conclusions:
- The "extended spinlocked section" hurts performance in the
  single queue case; with 6 snorts there is no measureable slowdown.
- I tried to re-write the mmap-snort to work without batch verdicts, but
  results were not very encouraging:

kernel 3.7.1 + mmap (without extended spinlocked section):

snort-mmap-batch-25      5.6 gbit out (what we currenlty ship)
snort-recv-batch-25      5.1 gbit out (without using mmap)
snort-mmap-batch-1       4.6 gbit out (with mmap but without batch verdicts)
snort-mmap-txring-25     5.2 gbit out (with mmap but without batch verdicts)
snort-mmap-txring-1      4.6 gbit out (with mmap but without batch verdicts)

The difference between the last two is that in the txring-25 case, we
put a verdict into the tx ring after every packet, but will only
invoke sendmsg(, NULL, 0) after processing 25 packets.  So the only
difference is the number of sendmsg calls/context switches.

So, i.o.w, kernel 3.7.1 + mmap + the extra locking crap is faster
than 3.7.1 + mmap-without-extra-locking and single-verdict-per packet.

===

I consider these patches ready for merging, so unless there are objections,
please apply.
