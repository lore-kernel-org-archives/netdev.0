From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [RFC PATCH net-next 2/5] net: split skb_checksum_help
Date: Thu, 02 Feb 2017 16:07:23 +0100
Message-ID: <1486048043.2556.4.camel@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
         <532e1db70b6c40f1b1e5c60b5b51be9f3437a30b.1485177252.git.dcaratti@redhat.com>
         <CALx6S37E=OEkRego_u=oDuUgQUn9-NZLpupvbN_dge1rqF92CQ@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DB026CEA4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "'Tom Herbert'" <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35920 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751528AbdBBPH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 10:07:26 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB026CEA4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello Tom and David,

thank you for the attention.

> From: Tom Herbert
> > 
> > Sent: 23 January 2017 21:00
> ..
> > 
> > skb_checksum_help is specific to the Internet checksum. For instance,
> > CHECKSUM_COMPLETE can _only_ refer to Internet checksum calculation
> > nothing else will work. Checksums and CRCs are very different things
> > with very different processing. They are not interchangeable, have
> > very different properties, and hence it is a mistake to try to shoe
> > horn things so that they use a common infrastructure.
> > 

true, we don't need to test CHECKSUM_COMPLETE on skbs carrying SCTP.
So maybe we can simply replace patches 2/5 and 3/5 with the smaller one at
the bottom of this message.

> > It might make sense to create some CRC helper functions, but last time
> > I checked there are so few users of CRC in skbufs I'm not even sure
> > that would make sense.

This is exactly the cause of issues I see with SCTP. These packets can be
wrongly checksummed using skb_checksum_help, or simply not checksummed at
all; and in both cases, the packet goes out from the NIC with wrong L4
checksum.

For example: there are scenarios, even the trivial one below, where skb
carrying SCTP packets are wrongly checksummed, because the originating
socket read NETIF_F_SCTP_CRC bit in the underlying device features.
Then, after the kernel forwards the skb, the final transmission
happens on another device where CRC offload is not available: this
typically leads to bad checksums on transmitted SCTP packets.



namespace 1 |                   namespace 2
            |
            |                      br0
            |         +------- Linux bridge -------+
            |         |                            |
            |         V                            V
vethA <-----------> vethB                        eth0
            |
            |

when a socket bound to vethA in namespace 1 generates an INIT packet,
it's not checksummed since veth devices have NETIF_F_SCTP_CRC set [1].
Then, after vethB receives the packet in namespace 2, linux bridge
forwards it to eth0, and (depending on eth0 driver code), it will be
transmitted with wrong CRC32c or simply dropped.

On Tue, 2017-01-24 at 16:35 +0000, David Laight wrote:
> 
> I can imagine horrid things happening if someone tries to encapsulate
> SCTP/IP in UDP (or worse UDP/IP in SCTP).
> 
> For UDP in UDP I suspect that CHECKSUM_COMPLETE on an inner UDP packet
> allows the outer checksum be calculated by ignoring the inner packet
> (since it sums to zero).
> This just isn't true if SCTP is involved.
> There are tricks to generate a crc of a longer packet, but they'd only
> work for SCTP in SCTP.
> 
> For non-encapsulated packets it is a different matter.

If we limit the scope to skbs having ip_summed equal to CHECKSUM_PARTIAL,
like it's done in patch 4, we only need checksumming the packet starting
from csum_start to its end, and copy the computed value to csum_offset.
The difficult thing is discriminating skbs that need CRC32c, namely SCTP,
from the rest of the traffic (that will likely be checksummed by
skb_checksum_help).

Currently, the only way to fix wrong CRCs in the scenario above is to
configure tc filter with "csum" action on eth0 egress, to compensate the
missing capability of eth0 driver to deal with SCTP packets having
ip_summed equal to CHECKSUM_PARTIAL [2].

Patch 4 in the series is an attempt to solve the issue, both for
encapsulated and non-encapsulated skbs, calling skb_csum_hwoffload_help()
inside validate_xmit_skb. In order to look for unchecksummed SCTP packets,
I took inspiration from a Linux-4.4 commit (6ae23ad36253 "net: Add driver
helper functions ...) to implement skb_csum_hwoffload_help, then I called
it in validate_xmit_skb() to fix situations that can't be recovered by the
NIC driver (it's the case where NETIF_F_CSUM_MASK bits are all zero).

Today most NICs can provide at least HW offload for Internet Checksum:
that's why I'm a bit doubtful if it's ok to spend extra CPU cycles in
validate_xmit_skb() to ensure correct CRC in some scenarios. 
Since this issue affects some (not all) NICs, maybe it's better to drop
patch 4, or part of it, and provide a fix for individual drivers that
don't currently handle non-checksummed SCTP packets. But to do that, we
need at least patch 1 and the small code below.

------------------- 8< --------------------------
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -200,7 +200,8 @@
  *     accordingly. Note the there is no indication in the skbuff that the
  *     CHECKSUM_PARTIAL refers to an FCOE checksum, a driver that supports
  *     both IP checksum offload and FCOE CRC offload must verify which offload
- *     is configured for a packet presumably by inspecting packet headers.
+ *     is configured for a packet presumably by inspecting packet headers; in
+ *     case, skb_sctp_csum_help is provided to compute CRC on SCTP packets.
  *
  * E. Checksumming on output with GSO.
  *
diff --git a/net/core/dev.c b/net/core/dev.c
index ad5959e..fa9be6d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2580,6 +2580,42 @@ int skb_checksum_help(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+int skb_sctp_csum_help(struct sk_buff *skb)
+{
+	__le32 crc32c_csum;
+	int ret = 0, offset;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		goto out;
+	if (unlikely(skb_is_gso(skb)))
+		goto out;
+	if (skb_has_shared_frag(skb)) {
+		ret = __skb_linearize(skb);
+		if (ret)
+			goto out;
+	}
+
+	offset = skb_checksum_start_offset(skb);
+	crc32c_csum = cpu_to_le32(~__skb_checksum(skb, offset,
+				  skb->len - offset, ~(__u32)0,
+				  sctp_csum_stub));
+
+	offset += offsetof(struct sctphdr, checksum);
+	BUG_ON(offset >= skb_headlen(skb));
+
+	if (skb_cloned(skb) &&
+	    !skb_clone_writable(skb, offset + sizeof(__le32))) {
+		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (ret)
+			goto out;
+	}
+	*(__le32 *)(skb->data + offset) = crc32c_csum;
+	skb->ip_summed = CHECKSUM_NONE;
+out:
+	return ret;
+}
+EXPORT_SYMBOL(skb_sctp_csum_help);
+
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
-- 
2.7.4
------------------- >8 --------------------------

Thank you again for paying attention to this, and I would appreciate if
you share your opinion.

Notes:

[1] see commit c80fafbbb59e ("veth: sctp: add NETIF_F_SCTP_CRC to device
features")
[2] see commit c008b33f3ef ("net/sched: act_csum: compute crc32c on SCTP
packets").  We could also turn off NETIF_F_SCTP_CRC bit from vethA, but
this would generate useless crc32c calculations if the SCTP server is not
outside the physical node (e.g. it is bound to br0), leading to a
throughput degradation.
