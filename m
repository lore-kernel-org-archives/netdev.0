From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] netlink: Don't reorder loads/stores before marking mmap
 netlink frame as available
Date: Thu, 18 Dec 2014 10:30:26 +0000
Message-ID: <20141218103026.GA16239@casper.infradead.org>
References: <20141014.220908.123550384430402000.davem@davemloft.net>
 <543F6998.5090000@redhat.com>
 <20141016070753.GA16738@casper.infradead.org>
 <20141216.175817.576861457076632402.davem@davemloft.net>
 <1418774579.9773.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dborkman@redhat.com,
	luto@amacapital.net, torvalds@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33738 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbaLRKa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 05:30:29 -0500
Content-Disposition: inline
In-Reply-To: <1418774579.9773.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each mmap Netlink frame contains a status field which indicates
whether the frame is unused, reserved, contains data or needs to
be skipped. Both loads and stores may not be reordeded and must
complete before the status field is changed and another CPU might
pick up the frame for use. Use an smp_mb() to cover needs of both
types of callers to netlink_set_status(), callers which have been
reading data frame from the frame, and callers which have been
filling or releasing and thus writing to the frame.

- Example code path requiring a smp_rmb():
  memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, hdr->nm_len);
  netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);

- Example code path requiring a smp_wmb():
  hdr->nm_uid	= from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
  hdr->nm_gid	= from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);
  netlink_frame_flush_dcache(hdr);
  netlink_set_status(hdr, NL_MMAP_STATUS_VALID);

Fixes: f9c228 ("netlink: implement memory mapped recvmsg()")
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ef5f77b..2662821 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -550,9 +550,9 @@ static enum nl_mmap_status netlink_get_status(const struct nl_mmap_hdr *hdr)
 static void netlink_set_status(struct nl_mmap_hdr *hdr,
 			       enum nl_mmap_status status)
 {
+	smp_mb();
 	hdr->nm_status = status;
 	flush_dcache_page(pgvec_to_page(hdr));
-	smp_wmb();
 }
 
 static struct nl_mmap_hdr *
