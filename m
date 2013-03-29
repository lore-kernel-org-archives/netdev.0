From: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] man: packet.7: document fanout, ring and auxiliary options
Date: Fri, 29 Mar 2013 09:29:58 -0400
Message-ID: <1364563798-20221-1-git-send-email-willemb@google.com>
References: <CA+FuTScjf2nkPykOkscuWXMuUSfAhDtQGCBhByxcyJ_cSsOPcQ@mail.gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, scott.a.mcmillan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	johann.baudy-1YmjpbiIw0bR7s880joybQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+FuTScjf2nkPykOkscuWXMuUSfAhDtQGCBhByxcyJ_cSsOPcQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The packet socket manual page does not list all socket options.

This patch adds descriptions of the common packet socket options
  PACKET_AUXDATA, PACKET_FANOUT, PACKET_RX_RING, PACKET_STATISTICS,
  PACKET_TX_RING

and the ring-specific options
  PACKET_LOSS, PACKET_RESERVE, PACKET_TIMESTAMP, PACKET_VERSION

It does not yet add descriptions for
  PACKET_COPY_THRESH, PACKET_HDRLEN, PACKET_ORIGDEV,
  PACKET_TX_HAS_OFF, PACKET_TX_TIMESTAMP, PACKET_VNET_HDR

It tries to balance being informative with exposing kernel detail
that is unlikely to be used by most readers or that may change
frequently. For implementation details, the manpage points to the
documentation in kernel Documentation/networking. Let me know if
options should be added or removed.

Source: PACKET_FANOUT, PACKET_RX_RING and PACKET_VERSION are in
/tools/testing/net/psock_fanout.c in the latest Linux kernel source
tree. PACKET_STATISTICS was in the first version of that test.
PACKET_TX_RING I have used elsewhere. The other options are based
on reading kernel code.

If you are on the CC: list, then you are the author of one of
the commits referred to in this manpage. If you can, please
check whether my description of your change is correct. Thanks.

Signed-off-by: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 man7/packet.7 | 207 +++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 198 insertions(+), 9 deletions(-)

diff --git a/man7/packet.7 b/man7/packet.7
index 006f2ac..a84ebee 100644
--- a/man7/packet.7
+++ b/man7/packet.7
@@ -177,17 +177,22 @@ and
 .I sll_ifindex
 are used.
 .SS Socket options
+Packet socket options are configured by calling
+.BR setsockopt (2)
+with level
+.BR SOL_PACKET .
+.TP
+.BR PACKET_ADD_MEMBERSHIP
+.PD 0
+.TP
+.BR PACKET_DROP_MEMBERSHIP
+.PD
 Packet sockets can be used to configure physical layer multicasting
 and promiscuous mode.
-It works by calling
-.BR setsockopt (2)
-on a packet socket for
-.B SOL_PACKET
-and one of the options
 .B PACKET_ADD_MEMBERSHIP
-to add a binding or
+adds a binding and
 .B PACKET_DROP_MEMBERSHIP
-to drop it.
+drops it.
 They both expect a
 .B packet_mreq
 structure as argument:
@@ -227,11 +232,195 @@ In addition the traditional ioctls
 .BR SIOCADDMULTI ,
 .B SIOCDELMULTI
 can be used for the same purpose.
+.TP
+.BR PACKET_AUXDATA " (since Linux 2.6.21)"
+.\" commit 8dc4194474159660d7f37c495e3fc3f10d0db8cc
+If this binary option is enabled, the packet socket passes a metadata
+structure along with each packet in the
+.BR recvmsg (2)
+control field.
+The structure can be read with
+.BR cmsg (3).
+It is defined as
+
+.in +4n
+.nf
+struct tpacket_auxdata {
+    __u32 tp_status;
+    __u32 tp_len;      /* packet length */
+    __u32 tp_snaplen;  /* captured length */
+    __u16 tp_mac;
+    __u16 tp_net;
+    __u16 tp_vlan_tci;
+    __u16 tp_padding;
+};
+.fi
+.in
+
+.I tp_net
+stores the offset to the network layer.
+If the packet socket is of type
+.BR SOCK_DGRAM ,
+then
+.I tp_mac
+is the same.
+If it is of type
+.BR SOCK_RAW ,
+then that field stores the offset to the link layer frame.
+.TP
+.BR PACKET_FANOUT " (since Linux 3.1)"
+.\" commit dc99f600698dcac69b8f56dda9a8a00d645c5ffc
+To scale processing across threads, packet sockets can form a fanout
+group.
+In this mode, each matching packet is enqueued onto only one
+socket in the group.
+A socket joins a fanout group by calling
+.BR setsockopt (2)
+with level
+.B SOL_PACKET
+and option
+.BR PACKET_FANOUT .
+Each network namespace can have up to 65536 independent groups.
+A socket selects a group by encoding the ID in the first 16 bits of
+the integer option value.
+The first packet socket to join a group implicitly creates it.
+To successfully join an existing group, subsequent packet sockets
+must have the same protocol, device settings and fanout mode and
+flags (see below).
+Packet sockets can leave a fanout group only by closing the socket.
+The group is deleted when the last socket is closed.
+
+Fanout supports multiple algorithms to spread traffic between sockets.
+The default mode,
+.BR PACKET_FANOUT_HASH ,
+sends packets from the same flow to the same socket to maintain
+per-flow ordering.
+For each packet, it chooses a socket by taking the packet flow hash
+modulo the number of sockets in the group, where a flow hash is a hash
+over network layer address and optional transport layer port fields.
+The load balance mode
+.BR PACKET_FANOUT_LB
+implements a round-robin algorithm.
+.BR PACKET_FANOUT_CPU
+selects the socket based on the CPU that the packet arrived on.
+
+Fanout modes can take additional options.
+IP fragmentation causes packets from the same flow to have different
+flow hashes.
+The flag
+.BR PACKET_FANOUT_FLAG_DEFRAG ,
+if set, causes packet to be defragmented before fanout is applied, to
+preserve order even in this case.
+Fanout mode and options are communicated in the second 16 bits of the
+integer option value.
+.TP
+.BR PACKET_LOSS " (with PACKET_TX_RING)"
+If set, do not silently drop a packet on transmission error, but
+return it with status set to
+.BR TP_STATUS_WRONG_FORMAT .
+.TP
+.BR PACKET_RESERVE " (with PACKET_RX_RING)"
+By default, a packet receive ring writes packets immediately following the
+metadata structure and alignment padding.
+This integer option reserves additional headroom.
+.TP
+.BR PACKET_RX_RING
+Create a memory mapped ring buffer for asynchronous packet reception.
+The packet socket reserves a contiguous region of application address
+space, lays it out into an array of packet slots and copies packets
+(up to
+.IR tp_snaplen)
+into subsequent slots.
+Each packet is preceded by a metadata structure similar to
+.IR tpacket_auxdata .
+Packet socket and application communicate the head and tail of the ring
+through the
+.I tp_status
+field.
+The packet socket owns all slots with status
+.BR TP_STATUS_KERNEL .
+After filling a slot, it changes the status of the slot to transfer
+ownership to the application.
+During normal operation, the new status is
+.BR TP_STATUS_USER ,
+to signal that a correctly received packet has been stored.
+When the application has finished processing a packet, it transfers
+ownership of the slot back to the socket by setting the status to
+.BR TP_STATUS_KERNEL .
+Packet sockets implement multiple variants of the packet ring.
+The implementation details are described in
+.IR Documentation/networking/packet_mmap.txt
+in the Linux kernel source tree.
+.TP
+.BR PACKET_STATISTICS
+Retrieve packet socket statistics in the form of a structure
+
+.in +4n
+.nf
+struct tpacket_stats {
+    __u32 tp_packets;  /* total packet count */
+    __u32 tp_drops;    /* dropped packet count */
+};
+.fi
+.in
+
+Receiving statistics resets the internal counters.
+The statistics structure differs when using a ring of variant
+.BR TPACKET_V3 .
+.TP
+.BR PACKET_TIMESTAMP " (with PACKET_RX_RING)"
+.\" commit 614f60fa9d73a9e8fdff3df83381907fea7c5649
+The packet receive ring always stores a timestamp in the metadata header.
+By default, this is a software generated timestamp generated when the
+packet is copied into the ring.
+This integer option selects the type of timestamp.
+Besides the default, it support the two hardware formats described in
+.IR Documentation/networking/timestamping.txt
+in the Linux kernel source tree.
+.TP
+.BR PACKET_TX_RING " (since Linux 2.6.31)"
+.\" commit 69e3c75f4d541a6eb151b3ef91f34033cb3ad6e1
+Create a memory mapped ring buffer for packet transmission.
+This option is similar to
+.BR PACKET_RX_RING
+and takes the same arguments.
+The application writes packets into slots with status
+.BR TP_STATUS_AVAILABLE
+and schedules them for transmission by changing the status to
+.BR TP_STATUS_SEND_REQUEST .
+When packets are ready to be transmitted, the application calls
+.BR send (2)
+or a variant thereof.
+The
+.I buf
+and
+.I len
+fields of this call are ignored.
+If an address is passed using
+.BR sendto (2)
+or
+.BR sendmsg (2) ,
+then that overrides the socket default.
+On successful transmission, the socket resets the slot to
+.BR TP_STATUS_AVAILABLE .
+It discards packets silently on error unless
+.BR PACKET_LOSS
+is set.
+.TP
+.BR PACKET_VERSION " (with PACKET_RX_RING)"
+.\" commit bbd6ef87c544d88c30e4b762b1b61ef267a7d279
+By default,
+.BR PACKET_RX_RING
+creates a packet receive ring of variant
+.BR TPACKET_V1 .
+To create another variant, configure the desired variant by setting this
+integer option before creating the ring.
+
 .SS Ioctls
 .B SIOCGSTAMP
 can be used to receive the timestamp of the last received packet.
 Argument is a
-.I struct timeval.
+.I struct timeval .
 .\" FIXME Document SIOCGSTAMPNS
 
 In addition all standard ioctls defined in
@@ -318,7 +507,7 @@ header to get a fully conforming packet.
 Incoming 802.3 packets are not multiplexed on the DSAP/SSAP protocol
 fields; instead they are supplied to the user as protocol
 .B ETH_P_802_2
-with the LLC header prepended.
+with the LLC header prefixed.
 It is thus not possible to bind to
 .BR ETH_P_802_3 ;
 bind to
-- 
1.8.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
