From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Various oopses seen in put_page from __kfree_skb()
Date: Fri, 11 Apr 2008 13:19:08 -0700
Message-ID: <47FFC7BC.6060108@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:42637 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759030AbYDKUYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 16:24:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

there have been a whole series of oopses in put_page() that come from __kfree_skb();
there is a poison pattern (basically use-after-free) in the oops all the time.

http://www.kerneloops.org/searchweek.php?search=put_page has various of the backtraces involved.
(note: there is also a bug in AGP there, ignore that one ;-)


It's a hard one to trace down, the trace looks like

put_page
skb_release_data
skb_release_all
_kfree_skb
tcp_recvmsg
sock_common_recvmsg
sock_recvmsg

I've not quite found what is happening here; but I found something
that looked a bit fishy; in tcp_recvmsg(), a variable called
copied_early is used to pass to sk_eat_skb(), which then either
frees the skb or queues it on a "to free later" list. (and sk_eat_skb()
seems to be the only inlined function there that would directly call
__kfree_skb() without going through kfree_skb() first, so it's a good suspect)

However the handling of this "copied_early" variable looks fishy to me;
it gets set for a certain skb under certain conditions. It also gets cleared
after (either) call to sk_eat_skb(). HOWEVER I fail to see very solid proof that
the skb for which it gets set is guaranteed to be the same skb for which sk_eat_skb() is called!
(Of course I can be totally wrong, I'm absolutely not familiar with the tcp code at all).
It appears to me that putting the wrong skb on the "process later" queue can lead to basically
a double free of the skb, which would explain the slab poison pattern.

So I came up with the patch below, which would fix the situation as described above
assuming the scenario is correct; if it's not correct it's only a small cleanup ;)
This patch moves the copied_early() variable inside the per-skb do-while loop,
including it's initialization. This will guarantee that the flag, when used, came
from THIS skb.

Does this look plausable for explaining the crashes?

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

---
  net/ipv4/tcp.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 39b629a..8edd523 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1269,7 +1269,6 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
  	int target;		/* Read at least this many bytes */
  	long timeo;
  	struct task_struct *user_recv = NULL;
-	int copied_early = 0;
  	struct sk_buff *skb;

  	lock_sock(sk);
@@ -1318,6 +1317,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,

  	do {
  		u32 offset;
+		int copied_early = 0;

  		/* Are we at urgent data? Stop if we have read anything or have SIGURG pending. */
  		if (tp->urg_data && tp->urg_seq == *seq) {
-- 
1.5.4.5


