From: "David S. Miller" <davem@redhat.com>
Subject: Possible bluetooth HCI socket bug
Date: Mon, 24 Nov 2003 18:58:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124185837.50811788.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maxk@qualcomm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello Maxim.

I was auditing something independantly (sock_queue_rcv_skb() usage, some
protocols were racy) when I ran into some issues that might be bugs
we need to fix in the bluetooth stack.

In hci_send_frame(), I'm highly doubtful of the skb_orphan() call you
make there.

Socket ownership of the buffer should be sustained until the transmission
by the device is complete and it frees up the buffer via dev_kfree_skb()
or similar.

Even in the cases where hci_send_to_sock() is called, that code clones
a new SKB for those purposes so it does not change the situation as far
as hci_send_frame() is concerned.

If socket ownership of an SKB buffer is liberated too early, this gives
the socket a window in which to over-commit it's socket buffer queue
limits.
