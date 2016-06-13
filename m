From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 0/5] skb_array: array based FIFO for skbs
Date: Mon, 13 Jun 2016 23:54:26 +0300
Message-ID: <20160613235426-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com, kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is in response to the proposal by Jason to make tun
rx packet queue lockless using a circular buffer.
My testing seems to show that at least for the common usecase
in networking, which isn't lockless, circular buffer
with indices does not perform that well, because
each index access causes a cache line to bounce between
CPUs, and index access causes stalls due to the dependency.

By comparison, an array of pointers where NULL means invalid
and !NULL means valid, can be updated without messing up barriers
at all and does not have this issue.

On the flip side, cache pressure may be caused by using large queues.
tun has a queue of 1000 entries by default and that's 8K.
At this point I'm not sure this can be solved efficiently.
The correct solution might be sizing the queues appropriately.

Here's an implementation of this idea: it can be used more
or less whenever sk_buff_head can be used, except you need
to know the queue size in advance.

As this might be useful outside of networking, I implemented
a generic array of void pointers, with a type-safe wrapper for skbs.

It remains to be seen whether resizing is required, in case it is
I included patches implementing resizing by holding both the
consumer and the producer locks.

I think this code works fine without any extra memory barriers since we
always read and write the same location, so the accesses can not be
reordered.
Multiple writes of the same value into memory would mess things up
for us, I don't think compilers would do it though.
But if people feel it's better to be safe wrt compiler optimizations,
specifying queue as volatile would probably do it in a cleaner way
than converting all accesses to READ_ONCE/WRITE_ONCE. Thoughts?

The only issue is with calls within a loop using the __ptr_ring_XXX
accessors - in theory compiler could hoist accesses out of the loop.

Following volatile-considered-harmful.txt I merely
documented that callers that busy-poll should invoke cpu_relax().
Most people will use the external skb_array_XXX APIs with a spinlock,
so this should not be an issue for them.

Eric Dumazet suggested adding an extra pointer to skb for when
we have a single outstanding packet. I could not figure out
a way to implement this without a shared consumer/producer lock
though, which would cause cache line bounces by itself.

Jesper, Jason, I know that both of you tested this,
please post Tested-by tags for whatever was tested.

changes since v7
	fix typos noticed by Jesper Brouer

changes since v6
	resize implemented. peek/full calls are no longer lockless

	replaced _FIELD macros with _CALL which invoke a function
	on the pointer rather than just returning a value

	destroy now scans the array and frees all queued skbs

changes since v5
	implemented a generic ptr_ring api, and
		made skb_array a type-safe wrapper
	apis for taking the spinlock in different contexts
		following expected usecase in tun
changes since v4 (v3 was never posted)
	documentation
	dropped SKB_ARRAY_MIN_SIZE heuristic
	unit test (in userspace, included as patch 2)

changes since v2:
        fixed integer overflow pointed out by Eric.
        added some comments.

changes since v1:
        fixed bug pointed out by Eric.

Michael S. Tsirkin (5):
  ptr_ring: array based FIFO for pointers
  ptr_ring: ring test
  skb_array: array based FIFO for skbs
  ptr_ring: resize support
  skb_array: resize support

 include/linux/ptr_ring.h         | 393 +++++++++++++++++++++++++++++++++++++++
 include/linux/skb_array.h        | 169 +++++++++++++++++
 tools/virtio/ringtest/ptr_ring.c | 192 +++++++++++++++++++
 tools/virtio/ringtest/Makefile   |   5 +-
 4 files changed, 758 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/ptr_ring.h
 create mode 100644 include/linux/skb_array.h
 create mode 100644 tools/virtio/ringtest/ptr_ring.c

-- 
MST
