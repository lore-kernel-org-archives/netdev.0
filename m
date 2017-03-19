From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH 0/6] virtio-net: Add support for virtio-net header extensions
Date: Sun, 19 Mar 2017 00:06:31 -0400
Message-ID: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@list.linux-foundation.org, mst@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34510 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdCSEGv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 00:06:51 -0400
Received: by mail-qk0-f182.google.com with SMTP id p64so90055013qke.1
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 21:06:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Curreclty virtion net header is fixed size and adding things to it is rather
difficult to do.  This series attempt to add the infrastructure as well as some
extensions that try to resolve some deficiencies we currently have.

First, vnet header only has space for 16 flags.  This may not be enough
in the future.  The extensions will provide space for 32 possbile extension
flags and 32 possible extensions.   These flags will be carried in the
first pseudo extension header, the presense of which will be determined by
the flag in the virtio net header.

The extensions themselves will immidiately follow the extension header itself.
They will be added to the packet in the same order as they appear in the
extension flags.  No padding is placed between the extensions and any
extensions negotiated, but not used need by a given packet will convert to
trailing padding.

For example:
 | vnet mrg hdr | ext hdr | ext 1 | ext 2 | ext 5 | .. pad .. | packet data |

Extensions proposed in this series are:
 - IPv6 fragment id extension
   * Currently, the guest generated fragment id is discarded and the host
     generates an IPv6 fragment id if the packet has to be fragmented.  This
     results in slightly less random id genration that might be potentially
     easier to guess.  We can pass the fragment id from guest to host to
     remove the need for the host to generate ids.

 - VLAN header acceleration
   * Currently virtio doesn't not do vlan header acceleration and instead
     uses software tagging.  The extension allows us to pass vlan id and
     protocol to the host and take advantage of host HW vlan acceleration.

 - UDP tunnel offload
   * Similar to vlan acceleration, with this extension we can pass additional
     data to host for support GSO with udp tunnel and possible other
     encapsulations.

This series only takes care of virtio net.  I have addition patches for the
host side (vhost and tap/macvtap as well as qemu), but wanted to get feedback
on the general approach first.

Vladislav Yasevich (6):
  virtio-net: Remove the use the padded vnet_header structure
  virtio-net: make header length handling uniform
  virtio_net: Add basic skeleton for handling vnet header extensions.
  virtio-net: Add support for IPv6 fragment id vnet header extension.
  virtio-net: Add support for vlan acceleration vnet header extension.
  virtio-net: Add support for UDP tunnel offload and extension.

 drivers/net/virtio_net.c        | 132 +++++++++++++++++++++++++++++++++-------
 include/linux/skbuff.h          |   5 ++
 include/linux/virtio_net.h      |  91 ++++++++++++++++++++++++++-
 include/uapi/linux/virtio_net.h |  38 ++++++++++++
 4 files changed, 242 insertions(+), 24 deletions(-)

-- 
2.7.4
