From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v5 0/2] skb_array: array based FIFO for skbs
Date: Mon, 23 May 2016 13:43:39 +0300
Message-ID: <1464000201-15560-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com
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

It's using skb pointers but we switching to void * would be easy at cost
of type safety, though it appears that people want lockless  push
etc so I'm not sure of the value.

I didn't implement resizing but it's possible by holding
both consumer and producer locks.

I think this code works fine without any extra memory barriers since we
always read and write the same location, so the accesses can not be
reordered.
Multiple writes of the same value into memory would mess things up
for us, I don't think compilers would do it though.
But if people feel it's better to be safe wrt compiler optimizations,
specifying queue as volatile would probably do it in a cleaner way
than converting all accesses to READ_ONCE/WRITE_ONCE. Thoughts?

The only issue is with calls within a loop using the __skb_array_XXX
accessors - in theory compiler could hoist accesses out of the loop.

Following volatile-considered-harmful.txt I merely
documented that callers that busy-poll should invoke cpu_relax().
Most people will use the external skb_array_XXX APIs with a spinlock,
so this should not be an issue for them.

changes since v4 (v3 was never posted)
	documentation
	dropped SKB_ARRAY_MIN_SIZE heuristic
	unit test (in userspace, included as patch 2)

changes since v2:
        fixed integer overflow pointed out by Eric.
        added some comments.

changes since v1:
        fixed bug pointed out by Eric.


Michael S. Tsirkin (2):
  skb_array: array based FIFO for skbs
  skb_array: ring test

 include/linux/skb_array.h         | 127 +++++++++++++++++++++++++++++
 tools/virtio/ringtest/skb_array.c | 167 ++++++++++++++++++++++++++++++++++++++
 tools/virtio/ringtest/Makefile    |   4 +-
 3 files changed, 297 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/skb_array.h
 create mode 100644 tools/virtio/ringtest/skb_array.c

-- 
MST
