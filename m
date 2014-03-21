From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH RFC 0/3] tcp: allow to repair a tcp connections in closing states
Date: Fri, 21 Mar 2014 17:32:58 +0400
Message-ID: <1395408781-8145-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, netdev@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48724 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760783AbaCUNdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 09:33:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently connections only in the TCP_ESTABLISHED state can be dumped and
restored. This series allows to restore connections in the FIN_WAIT_1,
FIN_WAIT_2, LAST_ACK, CLOSE_WAIT or CLOSING states.

For restoring closing states we need an ability to restore a fin packet
in a queue. In this series I suggest to use the interface of control
messages for that.

Here is an example of user-space code:

msg.msg_control = buf;
msg.msg_controllen = sizeof buf;
cmsg = CMSG_FIRSTHDR(&msg);
cmsg->cmsg_level = SOL_TCP;
cmsg->cmsg_type = TCP_CMSG_SEND_FIN;
cmsg->cmsg_len = CMSG_LEN(0);
msg.msg_controllen = cmsg->cmsg_len;
if (sendmsg(sk, &msg, 0) < 0) {
	pr_perror("sendmsg");
	return -1;
}

Andrey Vagin (3):
  tcp: allow to enable repair mode for sockets in any state
  tcp: check repair before fastopen in tcp_sendmsg
  tcp: add ability to restore a fin packet

 include/net/tcp.h        |  1 +
 include/uapi/linux/tcp.h |  3 +++
 net/ipv4/tcp.c           | 69 +++++++++++++++++++++++++++++++++++++-----------
 net/ipv4/tcp_input.c     |  2 +-
 4 files changed, 59 insertions(+), 16 deletions(-)

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>

-- 
1.8.5.3
