From: dingtianhong <dingtianhong@huawei.com>
Subject: [PATCH Resend] af_unix: dont send SCM_CREDENTIAL when dest socket
 is NULL
Date: Tue, 26 Mar 2013 11:02:04 +0800
Message-ID: <51510FAC.5090605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Li Zefan <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:10042 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758799Ab3CZDCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 23:02:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCM_SCREDENTIALS should apply to write() syscalls only either source or destination
socket asserted SOCK_PASSCRED. The original implememtation in maybe_add_creds is wrong,
and breaks several LSB testcases ( i.e. /tset/LSB.os/netowkr/recvfrom/T.recvfrom).

Origionally-authored-by: Karel Srot <ksrot@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/unix/af_unix.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51be64f..99189fd 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1413,8 +1413,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 	if (UNIXCB(skb).cred)
 		return;
 	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
-	    !other->sk_socket ||
-	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
+	    (other->sk_socket &&
+	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags))) {
 		UNIXCB(skb).pid  = get_pid(task_tgid(current));
 		UNIXCB(skb).cred = get_current_cred();
 	}
-- 1.8.0
