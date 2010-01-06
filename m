From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH alt.2] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 09:15:32 +0000
Message-ID: <20100106091532.GA10201@ff.dom.local>
References: <20100105230746.GA6612@del.dom.local> <4B43F72C.9090004@majjas.com> <20100106072208.GA6711@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755622Ab0AFJPm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100106072208.GA6711@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 06, 2010 at 07:22:08AM +0000, Jarek Poplawski wrote:
> On Tue, Jan 05, 2010 at 09:36:28PM -0500, Michael Breuer wrote:
> > Is it possible that this patch is causing the transmission to  
> > momentarily halt such that the overall utilization appears low at the  
> > time I see the interrupt errors, vs. the other patch which perhaps  
> > doesn't interrupt the traffic flow quite so much?
> 
> Yes, without this patch xmit could be stopped earlier on some kind of
> errors, with retransmit of the last message possible. On the other
> hand, other dev_queue_xmit() (negative) errors, are ignored. So this
> place could be still improved by adding proper err handling (or
> removing getting err return from dev_queue_xmit() at all).

On the other hand, returning just this one net_xmit_errno() would be
consistent with non-MMAP sendmsg, so here is an alternative version
for testing.

Thanks,
Jarek P.

-----------------> (alternative #2)

tpacket_snd() can change and kfree an skb after dev_queue_xmit(),
which is illegal.

With debugging by: Stephen Hemminger <shemminger@linux-foundation.org>

Reported-by: Michael Breuer <mbreuer@majjas.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/packet/af_packet.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e0516a2..aba2049 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1021,9 +1021,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 		status = TP_STATUS_SEND_REQUEST;
 		err = dev_queue_xmit(skb);
-		if (unlikely(err > 0 && (err = net_xmit_errno(err)) != 0))
-			goto out_xmit;
 		packet_increment_head(&po->tx_ring);
+		if (unlikely(err > 0 && (err = net_xmit_errno(err)) != 0))
+			goto out_put;
+
 		len_sum += tp_len;
 	} while (likely((ph != NULL) ||
 			((!(msg->msg_flags & MSG_DONTWAIT)) &&
@@ -1033,9 +1034,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	err = len_sum;
 	goto out_put;
 
-out_xmit:
-	skb->destructor = sock_wfree;
-	atomic_dec(&po->tx_ring.pending);
 out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
