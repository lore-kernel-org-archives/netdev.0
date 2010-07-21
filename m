From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH for-2.6.35] tun: avoid BUG, dump packet on GSO errors
Date: Wed, 21 Jul 2010 17:32:45 +0300
Message-ID: <20100721143245.GA8423@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab0GUOiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 10:38:01 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o6LEc0ua021814
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 10:38:01 -0400
Received: from redhat.com (vpn-6-219.tlv.redhat.com [10.35.6.219])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id o6LEbxRS032105
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 10:38:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are still some LRO cards that cause GSO errors in tun,
and BUG on this is an unfriendly way to tell the admin
to disable LRO.

Further, experience shows we might have more GSO bugs lurking.
See https://bugzilla.kernel.org/show_bug.cgi?id=16413
as a recent example.
dumping a packet will make it easier to figure it out.

Replace BUG with warning+dump+drop the packet to make
GSO errors in tun less critical and easier to debug.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Tested-by: Alex Unigovsky <unik@compot.ru>

---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6ad6fe7..6304259 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -736,8 +736,18 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
 			else if (sinfo->gso_type & SKB_GSO_UDP)
 				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
-			else
-				BUG();
+			else {
+				printk(KERN_ERR "tun: unexpected GSO type: "
+				       "0x%x, gso_size %d, hdr_len %d\n",
+				       sinfo->gso_type, gso.gso_size,
+				       gso.hdr_len);
+				print_hex_dump(KERN_ERR, "tun: ",
+					       DUMP_PREFIX_NONE,
+					       16, 1, skb->head,
+					       min((int)gso.hdr_len, 64), true);
+				WARN_ON_ONCE(1);
+				return -EINVAL;
+			}
 			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
 				gso.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
 		} else
