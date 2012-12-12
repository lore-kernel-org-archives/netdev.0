From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: [RFC] net : add tx timestamp to packet mmap.
Date: Wed, 12 Dec 2012 16:29:25 +0100
Message-ID: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
Cc: Paul Chavent <Paul.Chavent@onera.fr>
To: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:50096 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125Ab2LLPdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 10:33:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allow to generate tx timestamps of packets sent by the packet mmap interface.

Actually, you can't get tx timestamps with the sample code below.

I wonder if my current implementation is good. And if not, how should i get the timestamps ?

Wouldn't be a good idea to put timestamps in the ring buffer frame before give it back to the user ?

Thanks for your comments.

/* BEGIN OF SAMPLE CODE */
struct timespec ts = {0,0};
struct sockaddr from_addr;
static uint8_t tmp_data[256];
struct iovec msg_iov = {tmp_data, sizeof(tmp_data)};
static uint8_t cmsg_buff[256];
struct msghdr msghdr = {&from_addr, sizeof(from_addr),
                        &msg_iov, 1,
                        cmsg_buff, sizeof(cmsg_buff),
                        0};

ssize_t err = recvmsg(itf->sock_fd, &msghdr, MSG_ERRQUEUE);
if(err < 0)
  {
    perror("recvmsg failed");
    return -1;
  }

struct cmsghdr *cmsg;
for(cmsg = CMSG_FIRSTHDR(&msghdr); cmsg != NULL; cmsg = CMSG_NXTHDR(&msghdr, cmsg))
{
  if(cmsg->cmsg_level == SOL_SOCKET && cmsg->cmsg_type == SCM_TIMESTAMPING)
    {
      ts = *(struct timespec *)CMSG_DATA(cmsg);
      fprintf(stderr, "SCM_TIMESTAMPING available\n");
    }
  else if (cmsg->cmsg_level == SOL_PACKET && cmsg->cmsg_type == PACKET_TX_TIMESTAMP)
      {
        ts = *(struct timespec *)CMSG_DATA(cmsg);
        fprintf(stderr, "PACKET_TX_TIMESTAMP available\n");
      }
} 
/* END OF SAMPLE CODE */

Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
---
 net/packet/af_packet.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e639645..948748b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1857,6 +1857,10 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	void *data;
 	int err;
 
+	err = sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
+	if (err < 0)
+		return err;
+
 	ph.raw = frame;
 
 	skb->protocol = proto;
-- 
1.7.12.1
