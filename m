From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Tx timestamp for packet mmap.
Date: Fri, 07 Dec 2012 16:28:29 +0100
Message-ID: <50C20B1D.5050808@onera.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030500060502020400090809"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:54273 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756567Ab2LGPat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 10:30:49 -0500
Received: from neree.onecert.fr (thetis.onecert.fr [134.212.178.12])
	by briaree.onecert.fr (8.14.3/8.14.3/ONERA-SRI) with ESMTP id qB7FUk4Q026423
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 16:30:46 +0100
Received: from neree.onecert.fr (thetis.antiviral [127.0.0.1])
	by neree.onecert.fr (8.14.3/8.14.3/ONERA-SRI) with ESMTP id qB7FUjAx007484
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 16:30:46 +0100
Received: from [134.212.241.58] (wdcsd911h.cert.fr [134.212.241.58])
	by neree.onecert.fr (8.14.3/8.14.3/ONERA-SRI) with ESMTP id qB7FUjsX007481
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 16:30:45 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030500060502020400090809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

I would like to be able to get tx timestamps of packets sent by the 
packet mmap interface...

Actually, I try to get them with the sample code below.

The problem is that it doesn't work without the joined patch.

I wonder if my current implementation is good. And if not, how should i 
get the timestamps ?

Wouldn't be a good idea to put timestamps in the ring buffer frame 
before give back the frame to the user ?

Thanks for your help and advices.

Paul.

8<-------------------------------


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
   for(cmsg = CMSG_FIRSTHDR(&msghdr); cmsg != NULL; cmsg = 
CMSG_NXTHDR(&msghdr, cmsg))
     {
       if(cmsg->cmsg_level == SOL_SOCKET && cmsg->cmsg_type == 
SCM_TIMESTAMPING)
         {
           ts = *(struct timespec *)CMSG_DATA(cmsg);
#if !defined(NDEBUG)
           if(itf->debug)
             {
               fprintf(stderr, "SCM_TIMESTAMPING available\n");
             }
#else
           break;
#endif
         }
       else if (cmsg->cmsg_level == SOL_PACKET && cmsg->cmsg_type == 
PACKET_TX_TIMESTAMP)
         {
           ts = *(struct timespec *)CMSG_DATA(cmsg);
#if !defined(NDEBUG)
           if(itf->debug)
             {
               fprintf(stderr, "PACKET_TX_TIMESTAMP available\n");
             }
#else
           break;
#endif
         }
     }

--------------030500060502020400090809
Content-Type: text/x-patch;
 name="0002-net-add-tx-timestamp-to-packet-mmap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0002-net-add-tx-timestamp-to-packet-mmap.patch"

>From 762a8e89d1453e629bbe9c255c0ba4ec207cca25 Mon Sep 17 00:00:00 2001
From: Paul Chavent <paul.chavent@onera.fr>
Date: Fri, 7 Dec 2012 16:15:44 +0100
Subject: [PATCH 2/2] net : add tx timestamp to packet mmap.

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


--------------030500060502020400090809--
