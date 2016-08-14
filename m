From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 0/3] VSOCK: vsockmon virtual device to monitor
 AF_VSOCK sockets.
Date: Mon, 15 Aug 2016 02:15:38 +0300
Message-ID: <20160814231538.jihsj54ft7aftvdf@redhat.com>
References: <20160813102154.14338-1-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stefanha@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbcHNXPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Aug 2016 19:15:42 -0400
Content-Disposition: inline
In-Reply-To: <20160813102154.14338-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 13, 2016 at 12:21:51PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
> 
> This patch applies over the mst vhost git repository:
> http://git.kernel.org/cgit/linux/kernel/git/mst/vhost.git

So I do like where this is going, but it gives me pause
that there's a global list of taps, where all sockets
seem to multicast to them all.

In particular, this won't play well with things
like containers.

As each socket is bound to a physical device, how about binding
the monitor there as well? Only sockets from this device
would do the forwarding, and only one monitor per
device would be supported.

In a sense this will make it more like macvtap than tap.


> v2:
>  * Clone skb before transmitting them to vsockmon.
>  * Use consume_skb() instead of kfree_skb().
>  * Pass skb lifetime responsibility to tap functions.
>  * Remove t_hdr member from vsockmon header to avoid problems when/if it
>     changes it size if more transports are supported.
> 
> This was already been sent as a RFC where several issues where fixed.
> This is the summary of changes from the first RFC:
> 
> v2:
>  * Do not clone skb, instead take ownership before transmitting.
>  * Split tap functions from af_vsock.c.
>  * Simplify vsockmon header to remove unnecessary padding and
>     set little endian byte order.
>  * Various simple fixes from the comments received to the first RFC.
> 
> Additionally, first pach version changes:
>  * Add len field to the vsockmon header to ease parsing.
>  * Pack vsockmon header.
>  * Various simple fixes and styling.
> 
> Overview:
> 
> Virtual socket transports operate at kernel level therefore, there is no easy
> way to see the traffic exchanged between virtual machines and hypervisors that
> communicate using AF_VSOCK sockets. In addition, being able to see the control
> messages exchanged by the transports may be useful for debugging and
> optimization purposes. This patch adds a virtual device that may be used to see
> the traffic exchanged between virtual machines and hypervisors through AF_VSOCK
> sockets.
> 
> Its structure is based on the nlmon device and this version just targets the
> virtio transport, but support for the VMCI transport can be easily implemented.
> The vsockmon header contains a generic header and includes the header specific to
> the transport. The generic header allows to follow an AF_VSOCK stream without
> having to dig into the details of the transport while the transport header
> gives more detail which may be useful for troubleshooting and debugging.
> 
> Testing:
> 
> To set up a vsockmon device:
> 
> ip link add type vsockmon
> ip link set vsockmon0 up
> 
> The Wireshark development version (master branch) includes a vsock dissector
> that is capable of parsing packets received through vsockmon. The dissector
> needs to be manually selected.
> 
> Thanks to Stefan Hajnoczi for his help.
> 
> Gerard Garcia (3):
>   VSOCK: Add vsockmon tap functions
>   VSOCK: Add vsockmon device
>   VSOCK: Add virtio vsock vsockmon hooks
> 
>  drivers/net/Kconfig           |   8 ++
>  drivers/net/Makefile          |   1 +
>  drivers/net/vsockmon.c        | 168 ++++++++++++++++++++++++++++++++++++++++++
>  drivers/vhost/vsock.c         |  72 ++++++++++++++++++
>  include/net/af_vsock.h        |  13 ++++
>  include/uapi/linux/Kbuild     |   1 +
>  include/uapi/linux/if_arp.h   |   1 +
>  include/uapi/linux/vsockmon.h |  38 ++++++++++
>  net/vmw_vsock/Makefile        |   2 +-
>  net/vmw_vsock/af_vsock_tap.c  | 113 ++++++++++++++++++++++++++++
>  10 files changed, 416 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/net/vsockmon.c
>  create mode 100644 include/uapi/linux/vsockmon.h
>  create mode 100644 net/vmw_vsock/af_vsock_tap.c
> 
> -- 
> 2.9.1
