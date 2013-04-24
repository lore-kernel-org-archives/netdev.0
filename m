From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2] netlink: fix compilation after memory mapped patches
Date: Wed, 24 Apr 2013 10:36:23 +0200
Message-ID: <1366792583-10534-1-git-send-email-nicolas.dichtel@6wind.com>
References: <877gjtuqy2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	bhutchings@solarflare.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54141 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630Ab3DXIgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 04:36:46 -0400
In-Reply-To: <877gjtuqy2.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending of the kernel configuration (CONFIG_UIDGID_STRICT_TYPE_CHECKS=
), we can
get the following errors:

net/netlink/af_netlink.c: In function =E2=80=98netlink_queue_mmaped_skb=
=E2=80=99:
net/netlink/af_netlink.c:663:14: error: incompatible types when assigni=
ng to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kuid_t=E2=80=99
net/netlink/af_netlink.c:664:14: error: incompatible types when assigni=
ng to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kgid_t=E2=80=99
net/netlink/af_netlink.c: In function =E2=80=98netlink_ring_set_copied=E2=
=80=99:
net/netlink/af_netlink.c:693:14: error: incompatible types when assigni=
ng to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kuid_t=E2=80=99
net/netlink/af_netlink.c:694:14: error: incompatible types when assigni=
ng to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kgid_t=E2=80=99

We must use the helpers to get the uid and gid, and also take care of u=
ser_ns.

=46ix suggested by Eric W. Biederman <ebiederm@xmission.com>.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: use from_k{p,g}ui() functions to get the right {p,g}ui

 net/netlink/af_netlink.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index da5601d..d9c7869 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -660,8 +660,8 @@ static void netlink_queue_mmaped_skb(struct sock *s=
k, struct sk_buff *skb)
 	hdr->nm_len	=3D skb->len;
 	hdr->nm_group	=3D NETLINK_CB(skb).dst_group;
 	hdr->nm_pid	=3D NETLINK_CB(skb).creds.pid;
-	hdr->nm_uid	=3D NETLINK_CB(skb).creds.uid;
-	hdr->nm_gid	=3D NETLINK_CB(skb).creds.gid;
+	hdr->nm_uid	=3D from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
+	hdr->nm_gid	=3D from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);
 	netlink_frame_flush_dcache(hdr);
 	netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
=20
@@ -690,8 +690,8 @@ static void netlink_ring_set_copied(struct sock *sk=
, struct sk_buff *skb)
 	hdr->nm_len	=3D skb->len;
 	hdr->nm_group	=3D NETLINK_CB(skb).dst_group;
 	hdr->nm_pid	=3D NETLINK_CB(skb).creds.pid;
-	hdr->nm_uid	=3D NETLINK_CB(skb).creds.uid;
-	hdr->nm_gid	=3D NETLINK_CB(skb).creds.gid;
+	hdr->nm_uid	=3D from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
+	hdr->nm_gid	=3D from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);
 	netlink_set_status(hdr, NL_MMAP_STATUS_COPY);
 }
=20
--=20
1.8.2.1
