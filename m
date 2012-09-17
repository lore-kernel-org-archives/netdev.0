From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Mon, 17 Sep 2012 09:58:22 +0200
Message-ID: <1347868702.26523.79.camel@edumazet-glaptop>
References: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAHXqBFJZnGUSUutN=L-_LpCN7dXLPFY0ndJnQJ10NCcbzPVLww@mail.gmail.com>
	 <061C8A8601E8EE4CA8D8FD6990CEA89130DC20AA@ORSMSX102.amr.corp.intel.com>
	 <50552FF1.5030708@intel.com>
	 <061C8A8601E8EE4CA8D8FD6990CEA89130DC3631@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Fastabend, John R" <john.r.fastabend@intel.com>,
	Michal Miroslaw <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51166 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2IQH62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 03:58:28 -0400
Received: by bkwj10 with SMTP id j10so2304930bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 00:58:27 -0700 (PDT)
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89130DC3631@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-17 at 07:33 +0000, Dave, Tushar N wrote:
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> >On Behalf Of John Fastabend

> >Also wouldn't you want an unlikely() in your patch?
> 
> No because it is quite normal to have packet < ETH_ZLEN. e.g. ARP packets.

ARP packets ? Hardly a performance problem.

Or make sure all these packets have enough tailroom, or else you are
going to hit the cost of reallocating packets.

I would better point TCP pure ACK packets, since their size can be 54
bytes.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cfe6ffe..aefc681 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3083,8 +3083,9 @@ void tcp_send_ack(struct sock *sk)
 	/* We are not putting this on the write queue, so
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
+	 * Add 64 bytes of tailroom so that some drivers can use skb_pad()
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
+	buff = alloc_skb(MAX_TCP_HEADER + 64, sk_gfp_atomic(sk, GFP_ATOMIC));
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
