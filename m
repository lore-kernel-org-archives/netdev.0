From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/3] Bluetooth: Fix potential bad memory access with sysfs files
Date: Sun, 21 Mar 2010 06:41:35 +0100
Message-ID: <101545f6fef4a0a3ea8daf0b5b880df2c6a92a69.1269149356.git.marcel@holtmann.org>
References: <cover.1269149354.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35325 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab0CUFlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 01:41:47 -0400
In-Reply-To: <cover.1269149354.git.marcel@holtmann.org>
In-Reply-To: <cover.1269149354.git.marcel@holtmann.org>
References: <cover.1269149354.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a high number of Bluetooth sockets (L2CAP, SCO
and RFCOMM) it is possible to scribble repeatedly on arbitrary
pages of memory. Ensure that the content of these sysfs files is
always less than one page. Even if this means truncating. The
files in question are scheduled to be moved over to debugfs in
the future anyway.

Based on initial patches from Neil Brown and Linus Torvalds

Reported-by: Neil Brown <neilb@suse.de>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c       |   10 +++++++++-
 net/bluetooth/rfcomm/core.c |   13 ++++++++++++-
 net/bluetooth/rfcomm/sock.c |   11 ++++++++++-
 net/bluetooth/sco.c         |   11 ++++++++++-
 4 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 4db7ae2..2755182 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3944,16 +3944,24 @@ static ssize_t l2cap_sysfs_show(struct class *dev,
 	struct sock *sk;
 	struct hlist_node *node;
 	char *str = buf;
+	int size = PAGE_SIZE;
 
 	read_lock_bh(&l2cap_sk_list.lock);
 
 	sk_for_each(sk, node, &l2cap_sk_list.head) {
 		struct l2cap_pinfo *pi = l2cap_pi(sk);
+		int len;
 
-		str += sprintf(str, "%s %s %d %d 0x%4.4x 0x%4.4x %d %d %d\n",
+		len = snprintf(str, size, "%s %s %d %d 0x%4.4x 0x%4.4x %d %d %d\n",
 				batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
 				sk->sk_state, __le16_to_cpu(pi->psm), pi->scid,
 				pi->dcid, pi->imtu, pi->omtu, pi->sec_level);
+
+		size -= len;
+		if (size <= 0)
+			break;
+
+		str += len;
 	}
 
 	read_unlock_bh(&l2cap_sk_list.lock);
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index db8a68e..cf16407 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -2105,6 +2105,7 @@ static ssize_t rfcomm_dlc_sysfs_show(struct class *dev,
 	struct rfcomm_session *s;
 	struct list_head *pp, *p;
 	char *str = buf;
+	int size = PAGE_SIZE;
 
 	rfcomm_lock();
 
@@ -2113,11 +2114,21 @@ static ssize_t rfcomm_dlc_sysfs_show(struct class *dev,
 		list_for_each(pp, &s->dlcs) {
 			struct sock *sk = s->sock->sk;
 			struct rfcomm_dlc *d = list_entry(pp, struct rfcomm_dlc, list);
+			int len;
 
-			str += sprintf(str, "%s %s %ld %d %d %d %d\n",
+			len = snprintf(str, size, "%s %s %ld %d %d %d %d\n",
 					batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
 					d->state, d->dlci, d->mtu, d->rx_credits, d->tx_credits);
+
+			size -= len;
+			if (size <= 0)
+				break;
+
+			str += len;
 		}
+
+		if (size <= 0)
+			break;
 	}
 
 	rfcomm_unlock();
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index ca87d6a..8d0ee0b 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -1068,13 +1068,22 @@ static ssize_t rfcomm_sock_sysfs_show(struct class *dev,
 	struct sock *sk;
 	struct hlist_node *node;
 	char *str = buf;
+	int size = PAGE_SIZE;
 
 	read_lock_bh(&rfcomm_sk_list.lock);
 
 	sk_for_each(sk, node, &rfcomm_sk_list.head) {
-		str += sprintf(str, "%s %s %d %d\n",
+		int len;
+
+		len = snprintf(str, size, "%s %s %d %d\n",
 				batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
 				sk->sk_state, rfcomm_pi(sk)->channel);
+
+		size -= len;
+		if (size <= 0)
+			break;
+
+		str += len;
 	}
 
 	read_unlock_bh(&rfcomm_sk_list.lock);
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index f93b939..967a751 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -960,13 +960,22 @@ static ssize_t sco_sysfs_show(struct class *dev,
 	struct sock *sk;
 	struct hlist_node *node;
 	char *str = buf;
+	int size = PAGE_SIZE;
 
 	read_lock_bh(&sco_sk_list.lock);
 
 	sk_for_each(sk, node, &sco_sk_list.head) {
-		str += sprintf(str, "%s %s %d\n",
+		int len;
+
+		len = snprintf(str, size, "%s %s %d\n",
 				batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
 				sk->sk_state);
+
+		size -= len;
+		if (size <= 0)
+			break;
+
+		str += len;
 	}
 
 	read_unlock_bh(&sco_sk_list.lock);
-- 
1.6.6.1

