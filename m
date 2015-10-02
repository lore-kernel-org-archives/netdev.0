From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH] unix: fix use-after-free with unix_dgram_poll()
Date: Fri,  2 Oct 2015 19:10:39 +0000 (GMT)
Message-ID: <20151002191039.9124420ED@prod-mail-relay10.akamai.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Baron <jbaron@akamai.com>

The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
queue associated with the socket s that we've called poll() on, but it also
calls sock_poll_wait() for a remote peer socket's wait queue, if it's connected.
Thus, if we call poll()/select()/epoll() for the socket s, there are then
a couple of code paths in which the remote peer socket s2 and its associated
peer_wait queue can be freed before poll()/select()/epoll() have a chance
to remove themselves from this remote peer socket s2's wait queue.

The remote peer's socket and associated wait queues can be freed via:

1. If s calls connect() to connect to a new socket other than s2, it will
drop its reference on s2, and thus a close() on s2 will free it.

2. If we call close() on s2, then a subsequent sendmsg() from s, will drop
the final reference to s2, allowing it to be freed.

Address this issue, by reverting unix_dgram_poll() to only register with
the wait queue associated with s and simply drop the second sock_poll_wait()
registration for the remote peer socket wait queue. This then presents the
expected semantics to poll()/select()/epoll().

This works because we will continue to get POLLOUT wakeups from
unix_write_space(), which is called via sock_wfree(). In fact, we avoid having
two wakeup calls here for every buffer we read, since unix_dgram_recvmsg()
unconditionally calls wake_up_interruptible_sync_poll() on its 'peer_wait' queue
and we will no longer be in poll against that queue. So I think this should be
more performant than the current code. And we avoid the second poll() call here
as well during registration.

unix_write_space() should probably be enhanced such that it checks for the
unix_recvq_full() condition as well. In fact, it should probably look for
some fraction of that buffer being free, as is done in unix_writable(). But I'm
considering that a separate enhancement from fixing this issue.

I've tested this by specifically reproducing cases #1 and #2 above as well as
by running the test code here: https://lkml.org/lkml/2015/9/13/195

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/unix/af_unix.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..c1ae595 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2441,7 +2441,6 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	other = unix_peer_get(sk);
 	if (other) {
 		if (unix_peer(other) != sk) {
-			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
 			if (unix_recvq_full(other))
 				writable = 0;
 		}
-- 
1.8.2.rc2
