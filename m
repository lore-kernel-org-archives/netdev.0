From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Deadlock in af_packet/packet_rcv
Date: Tue, 30 Nov 2004 11:48:04 +0100
Message-ID: <20041130104804.GC16970@suse.de>
References: <20041125205503.GA18083@suse.de> <20041129200220.25ff3f7a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041129200220.25ff3f7a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 29, 2004 at 08:02:20PM -0800, David S. Miller wrote:
> If it's only the dev_queue_xmit_nit() handlers which all want
> BHs disabled, why don't we just disable BHs in that function?

That was my original fix (see attachment), but Andi Kleen suggested to
actually disable BHs at that level; I think as a matter of caution.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=netdev-xmit

Index: linux-2.6.9/net/core/dev.c
===================================================================
--- linux-2.6.9.orig/net/core/dev.c	2004-10-18 23:54:08.000000000 +0200
+++ linux-2.6.9/net/core/dev.c	2004-11-30 11:46:39.000000000 +0100
@@ -1094,9 +1094,15 @@ void dev_queue_xmit_nit(struct sk_buff *
 				skb2->nh.raw = skb2->data;
 			}
 
+			/* The packet handler may expect BHs to be disabled,
+			 * so don't let them down */
+			local_bh_disable();
+
 			skb2->h.raw = skb2->nh.raw;
 			skb2->pkt_type = PACKET_OUTGOING;
 			ptype->func(skb2, skb->dev, ptype);
+
+			local_bh_enable();
 		}
 	}
 	rcu_read_unlock();

--YiEDa0DAkWCtVeE4--
