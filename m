From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 7/8] net-timestamp: expand documentation
Date: Thu,  3 Jul 2014 15:39:39 -0400
Message-ID: <1404416380-3545-8-git-send-email-willemb@google.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gomail.com, stephen@networkplumber.org,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:38971 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbaGCTju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 15:39:50 -0400
Received: by mail-ob0-f202.google.com with SMTP id va2so138842obc.5
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 12:39:50 -0700 (PDT)
In-Reply-To: <1404416380-3545-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expand Documentation/networking/timestamping.txt with interface
details of MSG_TSTAMP and bytestream timestamping. Also minor
cleanup of the other text.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/timestamping.txt | 263 ++++++++++++++++++++++++++----
 1 file changed, 228 insertions(+), 35 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index bc35541..c00500a 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -1,4 +1,7 @@
-The existing interfaces for getting network packages time stamped are:
+
+1. Control Interfaces
+
+The interfaces for getting network packages time stamped are:
 
 * SO_TIMESTAMP
   Generate time stamp for each incoming packet using the (not necessarily
@@ -13,21 +16,47 @@ The existing interfaces for getting network packages time stamped are:
   Only for multicasts: approximate send time stamp by receiving the looped
   packet and using its receive time stamp.
 
-The following interface complements the existing ones: receive time
-stamps can be generated and returned for arbitrary packets and much
-closer to the point where the packet is really sent. Time stamps can
-be generated in software (as before) or in hardware (if the hardware
-has such a feature).
+* SO_TIMESTAMPING
+  Request timestamps on reception, transmission or both. Request hardware,
+  software or both timestamps.
+
+* MSG_TSTAMP..
+  Like SO_TIMESTAMPING, but unlike that socket option, request a timestamp
+  for the payload of one specific send() call only. Currently supports
+  only timestamping on transmission.
+
+
+1.1 SO_TIMESTAMP:
+
+This socket option enables timestamping of datagrams on the network reception
+path. Because the destination socket, if any, is not known early in the
+network stack, the feature has to be enabled for all possibly matching packets
+(i.e., datagrams). The same is true for all subsequent reception timestamp
+options, too.
+
+For interface details, see `man 7 socket`.
 
-SO_TIMESTAMPING:
+
+1.2 SO_TIMESTAMPNS:
+
+This option is identical to SO_TIMESTAMP except for the returned data type.
+Its struct timespec allows for higher resolution (ns) timestamps than the
+timeval of SO_TIMESTAMP (ms).
+
+
+1.3 SO_TIMESTAMPING:
 
 Instructs the socket layer which kind of information should be collected
-and/or reported.  The parameter is an integer with some of the following
-bits set. Setting other bits is an error and doesn't change the current
-state.
+and/or reported. SO_TIMESTAMPING supports multiple types of timestamps. The
+socket option is a bitmap, not a boolean, as a result. In an expression
+
+  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, (void *) val, &val);
+
+The parameter val is an integer with some of the following bits set. Setting
+other bits returns EINVAL and does not change the current state.
 
 Four of the bits are requests to the stack to try to generate
-timestamps.  Any combination of them is valid.
+timestamps. Any combination of them is valid.
 
 SOF_TIMESTAMPING_TX_HARDWARE:  try to obtain send time stamps in hardware
 SOF_TIMESTAMPING_TX_SOFTWARE:  try to obtain send time stamps in software
@@ -43,6 +72,10 @@ SOF_TIMESTAMPING_SOFTWARE:     report systime if available
 SOF_TIMESTAMPING_SYS_HARDWARE: report hwtimetrans if available
 SOF_TIMESTAMPING_RAW_HARDWARE: report hwtimeraw if available
 
+The interface supports one option
+
+SOF_TIMESTAMPING_OPT_TSONLY:   report a tx tstamp without looping pkt payload
+
 It is worth noting that timestamps may be collected for reasons other
 than being requested by a particular socket with
 SOF_TIMESTAMPING_[TR]X_(HARD|SOFT)WARE.  For example, most drivers that
@@ -50,45 +83,174 @@ can generate hardware receive timestamps ignore
 SOF_TIMESTAMPING_RX_HARDWARE.  It is still a good idea to set that flag
 in case future drivers pay attention.
 
-If timestamps are reported, they will appear in a control message with
-cmsg_level==SOL_SOCKET, cmsg_type==SO_TIMESTAMPING, and a payload like
-this:
+
+1.4 MSG_TSTAMP:
+
+The socket options enable timestamps for all datagrams on a socket
+until the configuration is again updated. Timestamps are often of
+interest only selectively, for instance for sampled monitoring or
+to instrument outliers. In these cases, continuous monitoring imposes
+unnecessary cost.
+
+MSG_TSTAMP and the MSG_TSTAMP_* flags are passed immediately with
+a send() call and request a timestamp only for the data in that
+buffer. They do not change socket state, nor do they depend on any
+of the socket options. Both can be used independently. Enabling
+both concurrently is safe, but redundant.
+
+MSG_TSTAMP:
+  generates the same timestamp as
+  SOF_TIMESTAMPING_TX_SOFTWARE | SOF_TIMESTAMPING_SOFTWARE: a transmit
+  timestamp in the device driver prior to handing to the NIC. As such
+  support for this timestamp is device driver specific.
+
+MSG_TSTAMP_ENQ:
+  generates a timestamp in the traffic shaping layer, prior to queuing
+  a packet. Kernel transmit latency is, if long, often dominated by
+  queueing delay. The difference between MSG_TSTAMP_ENQ and MSG_TSTAMP
+  will expose this delay indepedently from protocol processing. On
+  machines with virtual devices where a transmitted packet travels
+  through multiple devices and, hence, multiple traffic shaping
+  layers, a timestamp is returned for each layer. This enables fine
+  grained measurement of queueing delay.
+
+MSG_TSTAMP_ACK:
+  generates a timestamp when all data in the send buffer has been
+  acknowledged. This only makes sense for reliable protocols. It is
+  currently only implemented for TCP. For that protocol, it may
+  over-report measurement, because it defines when all data up to
+  and including the buffer was acknowledged (a cumulative ACK). It
+  ignores SACK and FACK.
+
+
+1.4.1 Bytestream Timestamps
+
+Unlike the socket options, the MSG_TSTAMP_.. interface supports
+timestamping of data in a bytestream. Each request is interpreted
+as a request for when the entire content of the buffer has passed a
+defined timestamping point. That is, a MSG_TSTAMP request records
+when all bytes have reached the device driver, regardless of how
+many packets the data has been converted into.
+
+In general, bytestreams have no natural delimiters and therefore
+correlating a timestamp with data is non-trivial. A range of bytes
+may be split across packets, packets may be merged (possibly merging
+two halves of two previously split, otherwise independent, buffers).
+These segments may be reordered and can even coexist for reliable
+protocols that implement retransmissions.
+
+It is essential that all timestamps implement the same semantics,
+regardless of all possible transformations, as otherwise they are
+incomparable. Handling "rare" corner cases differently from the
+simple case (a 1:1 mapping from buffer to skb) is insufficient
+because performance debugging often needs to focus on such outliers.
+
+In practice, timestamps can be correlated with segments of a
+bytestream consistently, if both semantics of the timestamp and the
+timing of measurement are chosen correctly. This challenge is no
+different from deciding on a strategy for IP fragmentation. There, the
+definition is that only the first fragment is timestamped. For
+bytestreams, we chose that a timestamp is generated only when all
+bytes have passed a point. The MSG_TSTAMP_ACK as defined is easy to
+implement and reason about. An implementation that has to take into
+account SACK would be more complex due to possible transmission holes
+and out of order arrival.
+
+On the host, TCP can also break the simple 1:1 mapping from buffer to
+skb by
+- appending a buffer to an existing skb (e.g., Nagle, cork and autocork)
+- MSS-based segmentation
+- generic segmentation offload (GSO)
+
+The implementation avoids the first by effectively closing an skb
+for appends once a timestamp flag is set. The stack avoids
+segmentation due to MSS. GSO is supported by copying the relevant
+flag from the original large packet into the last of the segmented
+MTU or smaller sized packets.
+
+This ensures that the timestamp is generated only when all bytes have
+passed a timestamp point, if the network stack does not reorder the
+packets. The stack indeed tries to avoid reordering. The one exception
+is under administrator control: it is possible to construct a traffic
+shaping setup that delays segments differently. Such a setup would be
+unusual.
+
+
+2 Data Interfaces
+
+The socket manual page describes how data is read from SO_TIMESTAMP
+and SO_TIMESTAMPNS. The other two interfaces use the same mechanism
+to return timestamps to the process.
+
+2.1 Reading TIMESTAMPING and MSG_TSTAMP records
+
+Timestamps can be read using the ancillary data feature of recvmsg().
+See `man 3 cmsg` for details of this interface. Timestamps are
+returned in a control message with cmsg_level SOL_SOCKET, cmsg_type
+SO_TIMESTAMPING, and payload of type
 
 struct scm_timestamping {
-	struct timespec systime;
-	struct timespec hwtimetrans;
-	struct timespec hwtimeraw;
+	struct timespec ts[3];
+};
+
+2.1.1 Transmit timestamps with MSG_ERRQUEUE
+
+For transmit timestamps the outgoing packet is looped back to
+the socket's error queue with the send time stamp(s) attached. A
+process receives the timestamps by calling recvmsg() with flag
+MSG_ERRQUEUE set and with a msg_control buffer sufficiently large
+to receive the relevant metadata structures. The recvmsg call returns
+the original outgoing data packet with two ancillary messages attached.
+A message of cm_level SOL_IP(V6) and cm_type IP(V6)_RECVERR embeds a
+struct sock_extended_err. This defines the error type. For timestamps,
+the ee_errno field is ENOMSG. The other ancillary message will have
+cm_level SOL_SOCKET and cm_type SCM_TIMESTAMPING. This embeds the
+struct scm_timestamping. Reading from the error queue is always a
+non-blocking operation. If the process wants to block for timestamps,
+it can use poll or select. In that case, the socket is ready for
+reading on POLLIN (not POLLERR).
+
+The semantics of the three struct timespec are defined by field
+ee_info in the extended error structure. It contains zero or one
+value SCM_TSTAMP_* for each struct timespec in scm_timestamping.
+In essence, it describes a
+
+struct scm_timestamping_types {
+	u32 tstype_field0:10;
+	u32 tstype_field1:10;
+	u32 tstype_field2:10;
+	u32 reserved:2;
 };
 
-recvmsg() can be used to get this control message for regular incoming
-packets. For send time stamps the outgoing packet is looped back to
-the socket's error queue with the send time stamp(s) attached. It can
-be received with recvmsg(flags=MSG_ERRQUEUE). The call returns the
-original outgoing packet data including all headers preprended down to
-and including the link layer, the scm_timestamping control message and
-a sock_extended_err control message with ee_errno==ENOMSG and
-ee_origin==SO_EE_ORIGIN_TIMESTAMPING. A socket with such a pending
-bounced packet is ready for reading as far as select() is concerned.
-If the outgoing packet has to be fragmented, then only the first
-fragment is time stamped and returned to the sending socket.
-
-All three values correspond to the same event in time, but were
+All three timestamps correspond to the same packet, but were
 generated in different ways. Each of these values may be empty (= all
 zero), in which case no such value was available. If the application
 is not interested in some of these values, they can be left blank to
 avoid the potential overhead of calculating them.
 
-systime is the value of the system time at that moment. This
+The SCM_TSTAMP_* types are closely related to the SOF_TIMESTAMPING_*
+and MSG_TSTAMP_* control fields discussed previously. They are defined
+as follows:
+
+SCM_TSTAMP_RCV records the system time in the rx softint path. This
 corresponds to the value also returned via SO_TIMESTAMP[NS]. If the
 time stamp was generated by hardware, then this field is
 empty. Otherwise it is filled in if SOF_TIMESTAMPING_SOFTWARE is
 set.
 
-hwtimeraw is the original hardware time stamp. Filled in if
+SCM_TSTAMP_SND records the system time in the transmit path as late
+as possible prior to handing the packet to the NIC. This is in the
+device driver path, so support is device dependent. See also the
+control option MSG_TSTAMP.
+
+Analogously, SCM_TSTAMP_ENQ and SCM_TSTAMP_ACK return timestamps
+generated by requests for MSG_TSTAMP_ENQ and MSG_TSTAMP_ACK.
+
+SCM_TSTAMP_HWSYS is the original hardware time stamp. Filled in if
 SOF_TIMESTAMPING_RAW_HARDWARE is set. No assumptions about its
 relation to system time should be made.
 
-hwtimetrans is the hardware time stamp transformed so that it
+SCM_TSTAMP_HWRAW is the hardware time stamp transformed so that it
 corresponds as good as possible to system time. This correlation is
 not perfect; as a consequence, sorting packets received via different
 NICs by their hwtimetrans may differ from the order in which they were
@@ -96,8 +258,39 @@ received. hwtimetrans may be non-monotonic even for the same NIC.
 Filled in if SOF_TIMESTAMPING_SYS_HARDWARE is set. Requires support
 by the network device and will be empty without that support.
 
+2.1.1.1 Fragmentation
+
+Fragmentation of outgoing datagrams is rare, but is possible, e.g., by
+explicitly disabling PMTU discovery. If an outgoing packet is fragmented,
+then only the first fragment is timestamped and returned to the sending
+socket.
+
+2.1.1.2 Reading Payload
+
+The calling application is often not interested in receiving the whole
+packet payload that it passed to the stack originally: the socket
+error queue mechanism is just a method to piggyback the timestamp on.
+In this case, the application can choose to read datagrams with a
+smaller buffer, possibly even of length 0. The payload is truncated
+accordingly.
+
+Until the process calls recvmsg() on the error queue, however, the
+full packet is queued, taking up budget from SO_SNDBUF. By setting
+socket option SOF_TIMESTAMPING_OPT_TSONLY, the timestamp is looped
+back not onto the original packet, but an empty packet generated
+at recvmsg() time.
+
+2.1.2 Receive timestamps
+
+On reception, there is no reason to read from the socket error queue.
+The SCM_TIMESTAMPING ancillary data is sent along with the packet data
+on a normal recvmsg(). Since this is not a socket error, it is not
+accompanied by a message SOL_IP(V6)/IP(V6)_RECVERROR. In this case,
+the meaning of the three fields is implicitly defined. Field 0 holds
+a value of SCM_TSTAMP_RCV, 1 of type SCM_TSTAMP_HWSYS and 2 of type
+SCM_TSTAMP_HWRAW.
 
-SIOCSHWTSTAMP, SIOCGHWTSTAMP:
+3. Hardware Timestamping configuration: SIOCSHWTSTAMP and SIOCGHWTSTAMP
 
 Hardware time stamping must also be initialized for each device driver
 that is expected to do hardware time stamping. The parameter is defined in
@@ -169,7 +362,7 @@ enum {
 };
 
 
-DEVICE IMPLEMENTATION
+Hardware Timestamping Implementation: Device Drivers
 
 A driver which supports hardware time stamping must support the
 SIOCSHWTSTAMP ioctl and update the supplied struct hwtstamp_config with
-- 
2.0.0.526.g5318336
