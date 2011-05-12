From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: af_packet: Don't initialize vnet_hdr
Date: Thu, 12 May 2011 14:55:48 -0700
Message-ID: <1305237348.6124.72.camel@Joe-Laptop>
References: <18a010357eb63dfd50751c5eb529f6261cf90ecd.1305232529.git.joe@perches.com>
	 <20110512.172623.220889608152651989.davem@davemloft.net>
	 <1305236000.6124.67.camel@Joe-Laptop>
	 <20110512.173608.1652572492952866283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110512.173608.1652572492952866283.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Save an initialization because when this structure
is used it's completely filled by memcpy_fromiovec.

Add a new variable used for the 0 sized allocation
when this structure is not used.

Signed-off-by: Joe Perches <joe@perches.com>

---

On Thu, 2011-05-12 at 17:36 -0400, David Miller wrote:
> I would rather see the code rearranged such that this sort of
> hackish scheme isn't necessary.

 net/packet/af_packet.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 549527b..cc1e83d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1123,9 +1123,10 @@ static int packet_snd(struct socket *sock,
 	__be16 proto;
 	unsigned char *addr;
 	int ifindex, err, reserve = 0;
-	struct virtio_net_hdr vnet_hdr = { 0 };
+	struct virtio_net_hdr vnet_hdr;
 	int offset = 0;
 	int vnet_hdr_len;
+	size_t alloc_vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned short gso_type = 0;
 
@@ -1206,7 +1207,10 @@ static int packet_snd(struct socket *sock,
 				goto out_unlock;
 
 		}
-	}
+		alloc_vnet_hdr_len = vnet_hdr.hdr_len;
+	} else
+		alloc_vnet_hdr_len = 0;
+
 
 	err = -EMSGSIZE;
 	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN))
@@ -1214,7 +1218,7 @@ static int packet_snd(struct socket *sock,
 
 	err = -ENOBUFS;
 	skb = packet_alloc_skb(sk, LL_ALLOCATED_SPACE(dev),
-			       LL_RESERVED_SPACE(dev), len, vnet_hdr.hdr_len,
+			       LL_RESERVED_SPACE(dev), len, alloc_vnet_hdr_len,
 			       msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto out_unlock;
