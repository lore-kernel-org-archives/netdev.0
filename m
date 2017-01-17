From: Rolf Neugebauer <rolf.neugebauer@docker.com>
Subject: virtio: Subtle changes to virtio_net flags breaks VXLAN on Google Cloud
Date: Tue, 17 Jan 2017 16:20:49 +0000
Message-ID: <CA+pO-2dnYX2OguTXPP_UV8hKwubNJ6Umxiux4vc+9yO0Ff0orw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>,
        virtio-dev@lists.oasis-open.org, mst@redhat.com,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:34933 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdAQQU4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:20:56 -0500
Received: by mail-it0-f54.google.com with SMTP id 203so98335758ith.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:20:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commits:

fd2a0437dc33 virtio_net: introduce virtio_net_hdr_{from,to}_skb
e858fae2b0b8 virtio_net: use common code for virtio_net_hdr and skb
GSO conversion

introduced a subtle (but unexplained) difference in how virtio_net
flags are derived from skb->ip_summed fields on transmit from the
guest to the host/backend. Prior to the patches the flags would be set
to VIRTIO_NET_HDR_F_NEEDS_CSUM if ip_summed was CHECKSUM_PARTIAL,
otherwise the flags would be set to 0.

After the commits, virtio_net flags would still be set to
VIRTIO_NET_HDR_F_NEEDS_CSUM if ip_summed == CHECKSUM_PARTIAL but it
now sets the virtio_net flags to VIRTIO_NET_HDR_F_DATA_VALID if
ip_summed == CHECKSUM_UNNECESSARY. Otherwise the virtio_net flags are set to 0.

skbuff.h says that for transmitting CHECKSUM_NONE and
CHECKSUM_UNNECESSARY have the same meaning, yet the above changes
treat them different.

Version 1.0 of the virtio spec [1] says in Section 5.1.6.2.1 Driver
Requirements: Packet Transmission: "The driver MUST NOT set the
VIRTIO_NET_HDR_F_DATA_VALID bit in flags." The above changes clearly
do that, but maybe I'm mis-reading the spec here.

The changes break VXLAN in some setups (we discovered it on Google
Could Engine, see below). We are trying to establish if this is an
issue with the GCE backend implementation, or if the above commit
should be amended to revert to the old behaviour (set
VIRTIO_NET_HDR_F_NEEDS_CSUM if ip_summed==CHECKSUM_PARTIAL, otherwise
set flags to 0).

Reverting back to the old behaviour (see strawman patch below) fixes
the issue we were seeing. While we tested with a 4.9.3 kernel, the
code in question has not been changed since.

Thanks
Rolf

Background:
On Google cloud, we have a setup with a manager node using a 4.9.3
kernel, two worker nodes (one with a 4.9.3 and the other with a 4.4.41
based kernel). Requests from a client node to the manager node are
either handled by the manager node or one of the two worker nodes. If
requests are handled by a worker node, the request (including the
SYN/SYN,ACK handshake) are encapsulated in VXLAN before being sent to
the worker and responses are decapsulate by the manager and forwarded
back to the client.
If a request is handled by either the manager or the 4.4 based worker,
everything works as expected. For requests handled by the 4.9 based
worker we see the response packet being sent to the client node by the
manager node (tcpdump on eth0), but it never arrives at the client
node.

Looking at the packets in a bit more detail, we noticed that the VXLAN
encapsulated responses from a 4.4 based worker have a zero UDP
checksum in the outer header while the responses from the 4.9 based
worker have a correct UDP checksum. Both packets have correct
checksums in the inner packet.

We instrumented the virtio_net driver and looked at the values of
ip_summed and virtio_net flags for the last hop of the SYN,ACK from
the manager back to the client.

- Requests handled directly by the manager have ip_summed =
  CHECKSUM_PARTIAL and flags
  VIRTIO_NET_HDR_F_NEEDS_CSUM (checksum offload).
- Requests originally originated from the 4.4 based worker
  (where the outer UDP checksum was zero) have ip_summed =
  CHECKSUM_NONE and flags = VIRTIO_NET_F_CSUM
  (no checksum offload)
- Requests originally originated from the 4.9 based worker
  (where the outer UDP checksum was filled in) have ip_summed =
  CHECKSUM_UNNECESSARY and flags =
  VIRTIO_NET_HDR_F_DATA_VALID. These packets get dropped
  before they reach the client.

The VXLAN code seems to set ip_summed to either CHECKSUM_NONE or
CHECKSUM_UNNECESSARY depending on the presence of the UDP checksum in
the outer header.

As a strawman, we reverted to the old behaviour on the xmit path with:
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -91,9 +91,7 @@ static inline int virtio_net_hdr_from_skb(const
struct sk_buff *skb,
                                skb_checksum_start_offset(skb));
                hdr->csum_offset = __cpu_to_virtio16(little_endian,
                                skb->csum_offset);
-       } else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-               hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
-       } /* else everything is zero */
+       }

        return 0;
 }
and it fixes the issue.


[1] http://docs.oasis-open.org/virtio/virtio/v1.0/cs04/virtio-v1.0-cs04.pdf
