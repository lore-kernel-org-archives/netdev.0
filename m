From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 00:07:46 +0100
Message-ID: <20100105230746.GA6612@del.dom.local>
References: <20091226.201107.35060733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, mbreuer@majjas.com,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755573Ab0AEXHy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091226.201107.35060733.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote, On 12/27/2009 05:11 AM:

> From: David Miller <davem@davemloft.net>
> Date: Sat, 26 Dec 2009 19:44:18 -0800 (PST)
> 
>> From: Stephen Hemminger <shemminger@linux-foundation.org>
>> Date: Sat, 26 Dec 2009 14:05:44 -0800
>>
>>> Other drivers may have same problem, I really think this ought
>>> to be done at higher level.
>> I tend to agree with you, and I thought we had handled all
>> cases.  Let's simply make AF_PACKET linearize the link
>> level header before sending things out to the transmit path.
>>
>> I can work on this if you want.
> 
> Actually Stephen, I took a look and I can't see how AF_PACKET
> can create this situation.
> 
> It always copies into the linear area of the SKB it allocates
> for sendmsg() processing.  Whether the data comes from sendmsg
> data or the mmap() ring buffer.

Actually, I think there is a bug in this place, but of course this
might be unconnected. Anyway, Michael, could you try this patch?
BTW, did you try with CONFIG_PACKET_MMAP disabled?

Thanks,
Jarek P.
----------------->

Changing an skb after dev_queue_xmit() is illegal. And since it's
inconsistent to treat specially net_xmit_errno() non-zero return,
while ignoring other dev_queue_xmit() errors, there is no reason
to break the loop in tpacket_snd() in this case.

With debugging by: Stephen Hemminger <shemminger@linux-foundation.org>

Reported-by: Michael Breuer <mbreuer@majjas.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/packet/af_packet.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e0516a2..984a1fa 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1021,8 +1021,9 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 		status = TP_STATUS_SEND_REQUEST;
 		err = dev_queue_xmit(skb);
-		if (unlikely(err > 0 && (err = net_xmit_errno(err)) != 0))
-			goto out_xmit;
+		if (unlikely(err > 0))
+			err = net_xmit_errno(err);
+
 		packet_increment_head(&po->tx_ring);
 		len_sum += tp_len;
 	} while (likely((ph != NULL) ||
@@ -1033,9 +1034,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	err = len_sum;
 	goto out_put;
 
-out_xmit:
-	skb->destructor = sock_wfree;
-	atomic_dec(&po->tx_ring.pending);
 out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
