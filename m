From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH/RFC] packet: fix sock_tx_timestamp() in packet_snd() via sendto syscall
Date: Fri, 15 Jul 2016 11:49:04 +0900
Message-ID: <1468550944-4584-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <daniel@iogearbox.net>, <willemb@google.com>, <ast@plumgrid.com>,
	<tklauser@distanz.ch>, <fruggeri@aristanetworks.com>,
	<netdev@vger.kernel.org>, <linux-renesas-soc@vger.kernel.org>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	<stable@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the sendto syscall doesn't have msg_control buffer,
the sock_tx_timestamp() in packet_snd() cannot work correctly because
the socks.fsflags is set to 0.
So, this patch sets the fsflags from sk.sk_tsflags if the msg_control
buffer doesn't exist.

Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
Cc: <stable@vger.kernel.org>
Reported-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Reported-by: Keita Kobayashi <keita.kobayashi.ym@renesas.com>
Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
I'm not sure the network stack world. So, I submit this patch as RFC.
This patch looks like a quick hack, but it could resolve an our issue.

This issue happens on our platform (r8a7795-salvator-x).
The test command is:
 # ptp4l -i eth0 -p /dev/ptp0 -m -q -f /etc/linuxptp/gPTP.cfg

The failure result:
ptp4l[26.815]: selected /dev/ptp0 as PTP clock
ptp4l[26.872]: port 1: INITIALIZING to LISTENING on INITIALIZE
ptp4l[26.872]: port 0: INITIALIZING to LISTENING on INITIALIZE
ptp4l[27.873]: timed out while polling for tx timestamp
ptp4l[27.873]: increasing tx_timestamp_timeout may correct this issue, but it is likely caused by a driver bug
ptp4l[27.873]: port 1: send peer delay request failed
ptp4l[27.873]: port 1: LISTENING to FAULTY on FAULT_DETECTED (FT_UNSPECIFIED)

The result after the patch is applied (or the c14ac9451c34 is reverted):
ptp4l[64.639]: selected /dev/ptp0 as PTP clock
ptp4l[64.688]: port 1: INITIALIZING to LISTENING on INITIALIZE
ptp4l[64.688]: port 0: INITIALIZING to LISTENING on INITIALIZE
ptp4l[71.841]: port 1: LISTENING to MASTER on ANNOUNCE_RECEIPT_TIMEOUT_EXPIRES
ptp4l[71.841]: selected best master clock 2e090a.fffe.00a2df
ptp4l[71.841]: assuming the grand master role

 net/packet/af_packet.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9f0983f..d76fd41 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2887,6 +2887,11 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		err = sock_cmsg_send(sk, msg, &sockc);
 		if (unlikely(err))
 			goto out_unlock;
+	} else {
+		/* Set tsflags from sk because a syscall (e.g. sendto) doesn't
+		 * have msg_control buffer.
+		 */
+		sockc.tsflags = sk->sk_tsflags;
 	}
 
 	if (sock->type == SOCK_RAW)
-- 
1.9.1
