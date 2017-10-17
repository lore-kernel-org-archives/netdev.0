From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: do not peel off an assoc from one netns to another one
Date: Tue, 17 Oct 2017 23:26:10 +0800
Message-ID: <e637d68ce6f4f94dce8cb30c647e672ebb1f0b7b.1508253970.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, chunwang@redhat.com,
        syzkaller@googlegroups.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:44336 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754455AbdJQP0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:26:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when peeling off an association to the sock in another netns, all
transports in this assoc are not to be rehashed and keep use the old
key in hashtable.

As a transport uses sk->net as the hash key to insert into hashtable,
it would miss removing these transports from hashtable due to the new
netns when closing the sock and all transports are being freeed, then
later an use-after-free issue could be caused when looking up an asoc
and dereferencing those transports.

This is a very old issue since very beginning, ChunYu found it with
syzkaller fuzz testing with this series:

  socket$inet6_sctp()
  bind$inet6()
  sendto$inet6()
  unshare(0x40000000)
  getsockopt$inet_sctp6_SCTP_GET_ASSOC_ID_LIST()
  getsockopt$inet_sctp6_SCTP_SOCKOPT_PEELOFF()

This patch is to block this call when peeling one assoc off from one
netns to another one, so that the netns of all transport would not
go out-sync with the key in hashtable.

Note that this patch didn't fix it by rehashing transports, as it's
difficult to handle the situation when the tuple is already in use
in the new netns. Besides, no one would like to peel off one assoc
to another netns, considering ipaddrs, ifaces, etc. are usually
different.

Reported-by: ChunYu Wang <chunwang@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d4730ad..17841ab 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4906,6 +4906,10 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 	struct socket *sock;
 	int err = 0;
 
+	/* Do not peel off from one netns to another one. */
+	if (!net_eq(current->nsproxy->net_ns, sock_net(sk)))
+		return -EINVAL;
+
 	if (!asoc)
 		return -EINVAL;
 
-- 
2.1.0
