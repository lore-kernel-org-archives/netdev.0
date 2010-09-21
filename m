From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Deadlock in Bluetooth code in 2.6.36
Date: Tue, 21 Sep 2010 18:20:12 -0300
Message-ID: <1285104013-9946-1-git-send-email-padovan@profusion.mobi>
Cc: linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	padovan@profusion.mobi, marcel@holtmann.org, davem@davemloft.net,
	mathewm@codeaurora.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I would like to discuss here a problem we are having in the Bluetooth Layer.

There we have the Enhanced Retransmission Mode(ERTM) which is  a reliable mode
of operation of the Bluetooth L2CAP layer. Think on it like a simplified
version of TCP.

The problem we were facing was a deadlock. ERTM uses a backlog queue to
queue incoming packets while the user held the lock. The problem is that
at some moment the user doesn't have memory anymore to alloc new skbs and
sleeps to wait for memory with the lock held, that stalls the ERTM connection
because we can't read the acknowledgements packets in the backlog queue to
free memory and then make the allocation of outcoming skb successful.

Looks like the solution to this issue is release the lock before go to sleep
waiting for memory and then lock the sock lock again when we wake up and have
memory.  That's the solution TCP does through sk_stream_alloc_skb() and
sk_stream_wait_memory(). The sock lock is released and locked again inside
sk_wait_event() macro.
For bluetooth we do that in different way, we alloc memory through
sock_alloc_send_skb() which differently from sk_stream_alloc_skb() sleeps
with the lock held when waiting for memory.

The following patch is more like a proof of concept that sleeping
without the lock fixes the problem for L2CAP. Mat Martineau also found out
that some time ago.

My questions here is on how to fix this properly. Maybe
sock_alloc_send_skb() should not be used with SOCK_STREAM and reliable
protocols and I'm not aware of that? And should I use something like
sk_stream_alloc_skb() instead?

Any comments are welcome. With lucky we can fix that for 2.6.36 and
together with others fixes we have queued deliver a fully functional
L2CAP layer on 2.6.36.

Thanks,

---

Gustavo F. Padovan (1):
      Bluetooth: Fix deadlock in the ERTM logic

 net/bluetooth/l2cap.c |    4 ++++
  1 files changed, 4 insertions(+), 0 deletions(-)
