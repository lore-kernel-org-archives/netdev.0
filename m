From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 5/6] net: fix sock locking for sk_err field in netlink.
Date: Thu, 17 Sep 2009 17:58:32 -0700
Message-ID: <20090918005832.25594.45086.stgit@localhost.localdomain>
References: <20090918005708.25594.52575.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090918005708.25594.52575.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>

This adds the sock lock around setting the sk_err field
in sock struct. Without the lock multiple threads may
write to this field.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/netlink/af_netlink.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index aa74011..1669dfc 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -732,7 +732,9 @@ static void netlink_overrun(struct sock *sk)
 
 	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
 		if (!test_and_set_bit(0, &nlk_sk(sk)->state)) {
+			lock_sock(sk);
 			sk->sk_err = ENOBUFS;
+			release_sock(sk);
 			sk->sk_error_report(sk);
 		}
 	}
@@ -1101,7 +1103,9 @@ static inline int do_one_set_err(struct sock *sk,
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
+	lock_sock(sk);
 	sk->sk_err = p->code;
+	release_sock(sk);
 	sk->sk_error_report(sk);
 out:
 	return 0;
@@ -1780,7 +1784,9 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 				    in_skb->sk->sk_protocol,
 				    NETLINK_CB(in_skb).pid);
 		if (sk) {
+			lock_sock(sk);
 			sk->sk_err = ENOBUFS;
+			release_sock(sk);
 			sk->sk_error_report(sk);
 			sock_put(sk);
 		}

