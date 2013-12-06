From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH man-pages] man: packet.7: document fanout, ring and
 auxiliary options
Date: Fri, 6 Dec 2013 11:11:46 -0500
Message-ID: <CA+FuTSdCfH_yum57ZWV9tw5cd0=DkWWR-OvnaUEkUf5O7JCQYg@mail.gmail.com>
References: <cover.1386081779.git.dborkman@redhat.com> <a19a6633601bbc10867ac57e4a601df847cf47cc.1386081779.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
	linux-man@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:45482 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168Ab3LFQMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 11:12:17 -0500
Received: by mail-qa0-f45.google.com with SMTP id o15so697173qap.4
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 08:12:17 -0800 (PST)
In-Reply-To: <a19a6633601bbc10867ac57e4a601df847cf47cc.1386081779.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  [Very minor fixups. -dborkman]
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  Just a resend of something that got lost in March this year.

Thanks for dusting this off, Daniel!

I spotted a few small issues. We also introduced a few new flags since
the last revision. If we have to make changes anyway, may as well
describe those, too. Let me know if you will resubmit or prefer me to
do it.

I did not test the output of my changes yet, btw.

> +.I tp_net
> +stores the offset to the network layer.
> +If the packet socket is of type
> +.BR SOCK_DGRAM ,
> +then
> +.I tp_mac
> +is the same.
> +If it is of type
> +.BR SOCK_RAW ,
> +then that field stores the offset to the link layer frame.

This only applies to the metadata when passed in a packet ring frame
and has to be moved there. The ring metadata structure is very similar
to tpacket_auxdata (as mentioned below), but they differ in this
regard: with recvmsg/auxdata the mac always starts at offset 0 for
obvious reasons.

> +.TP
> +.BR PACKET_FANOUT " (since Linux 3.1)"
> +.\" commit dc99f600698dcac69b8f56dda9a8a00d645c5ffc
> +To scale processing across threads, packet sockets can form a fanout
> +group.
> +In this mode, each matching packet is enqueued onto only one
> +socket in the group.
> +A socket joins a fanout group by calling
> +.BR setsockopt (2)
> +with level
> +.B SOL_PACKET
> +and option
> +.BR PACKET_FANOUT .
> +Each network namespace can have up to 65536 independent groups.
> +A socket selects a group by encoding the ID in the first 16 bits of
> +the integer option value.
> +The first packet socket to join a group implicitly creates it.
> +To successfully join an existing group, subsequent packet sockets
> +must have the same protocol, device settings and fanout mode and
> +flags (see below).
> +Packet sockets can leave a fanout group only by closing the socket.
> +The group is deleted when the last socket is closed.
> +
> +Fanout supports multiple algorithms to spread traffic between sockets.
> +The default mode,
> +.BR PACKET_FANOUT_HASH ,
> +sends packets from the same flow to the same socket to maintain
> +per-flow ordering.
> +For each packet, it chooses a socket by taking the packet flow hash
> +modulo the number of sockets in the group, where a flow hash is a hash
> +over network layer address and optional transport layer port fields.
> +The load balance mode
> +.BR PACKET_FANOUT_LB
> +implements a round-robin algorithm.
> +.BR PACKET_FANOUT_CPU
> +selects the socket based on the CPU that the packet arrived on.

New options since the last patch:

+.BR PACKET_FANOUT_ROLLOVER
+processes all data on a single socket, moves to the next when one
becomes backlogged.
+.BR PACKET_FANOUT_RND:
+selects the socket using a pseudo random number generator.

> +
> +Fanout modes can take additional options.
> +IP fragmentation causes packets from the same flow to have different
> +flow hashes.
> +The flag
> +.BR PACKET_FANOUT_FLAG_DEFRAG ,
> +if set, causes packet to be defragmented before fanout is applied, to
> +preserve order even in this case.
> +Fanout mode and options are communicated in the second 16 bits of the
> +integer option value.

.BR PACKET_FANOUT_FLAG_ROLLOVER ,
+if set, enables the roll over mechanism as a backup strategy. If the
+original fanout algorithm selects a backlogged cpu, roll over to the
+next available one.

> +.TP
> +.BR PACKET_LOSS " (with PACKET_TX_RING)"
> +If set, do not silently drop a packet on transmission error, but
> +return it with status set to
> +.BR TP_STATUS_WRONG_FORMAT .
> +.TP
> +.BR PACKET_RESERVE " (with PACKET_RX_RING)"
> +By default, a packet receive ring writes packets immediately following the
> +metadata structure and alignment padding.
> +This integer option reserves additional headroom.
> +.TP
> +.BR PACKET_RX_RING
> +Create a memory mapped ring buffer for asynchronous packet reception.
> +The packet socket reserves a contiguous region of application address
> +space, lays it out into an array of packet slots and copies packets
> +(up to
> +.IR tp_snaplen
> +) into subsequent slots.
> +Each packet is preceded by a metadata structure similar to
> +.IR tpacket_auxdata .

This is where the mac discussion from above belongs.

> +Packet socket and application communicate the head and tail of the ring
> +through the
> +.I tp_status
> +field.
> +The packet socket owns all slots with status
> +.BR TP_STATUS_KERNEL .
> +After filling a slot, it changes the status of the slot to transfer
> +ownership to the application.
> +During normal operation, the new status is
> +.BR TP_STATUS_USER ,
> +to signal that a correctly received packet has been stored.
> +When the application has finished processing a packet, it transfers
> +ownership of the slot back to the socket by setting the status to
> +.BR TP_STATUS_KERNEL .
> +Packet sockets implement multiple variants of the packet ring.
> +The implementation details are described in
> +.IR Documentation/networking/packet_mmap.txt
> +in the Linux kernel source tree.
> +.TP
> +.BR PACKET_STATISTICS
> +Retrieve packet socket statistics in the form of a structure
> +
> +.in +4n
> +.nf
> +struct tpacket_stats {
> +    __u32 tp_packets;  /* total packet count */
> +    __u32 tp_drops;    /* dropped packet count */

these should apparently be

+    unsigned int tp_packets;  /* total packet count */
+    unsigned int tp_drops;    /* dropped packet count */

> +};
> +.fi
> +.in
> +

All the rest looked fine.
