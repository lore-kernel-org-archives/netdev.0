From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 0/6] virtio-net: Add support for virtio-net header
 extensions
Date: Thu, 30 Mar 2017 19:06:03 +0300
Message-ID: <20170330160412.GA32094@redhat.com>
References: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60044 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933806AbdC3QGO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 12:06:14 -0400
Content-Disposition: inline
In-Reply-To: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 19, 2017 at 12:06:31AM -0400, Vladislav Yasevich wrote:
> Curreclty virtion net header is fixed size and adding things to it is rather
> difficult to do.  This series attempt to add the infrastructure as well as some
> extensions that try to resolve some deficiencies we currently have.

Pls copy virtio TC ML as with any interface change proposals.

Also pls use the correct list for virtio: that's
virtualization@lists.linux-foundation.org, not
virtualization@list.linux-foundation.org

And pls copy more relevant people directly.
virtio dpdk and qemu maintainers and qemu ml come to mind.

> First, vnet header only has space for 16 flags.  This may not be enough
> in the future.  The extensions will provide space for 32 possbile extension
> flags and 32 possible extensions.   These flags will be carried in the
> first pseudo extension header, the presense of which will be determined by
> the flag in the virtio net header.
> 
> The extensions themselves will immidiately follow the extension header itself.
> They will be added to the packet in the same order as they appear in the
> extension flags.  No padding is placed between the extensions and any
> extensions negotiated, but not used need by a given packet will convert to
> trailing padding.
> 
> For example:
>  | vnet mrg hdr | ext hdr | ext 1 | ext 2 | ext 5 | .. pad .. | packet data |
> 

I'll try to look into interface detail later, but there's some
detail missing here on when are these extensions helpful.

> Extensions proposed in this series are:
>  - IPv6 fragment id extension
>    * Currently, the guest generated fragment id is discarded and the host
>      generates an IPv6 fragment id if the packet has to be fragmented.  This
>      results in slightly less random id genration that might be potentially
>      easier to guess.  We can pass the fragment id from guest to host to
>      remove the need for the host to generate ids.

Well it's harder for guest to get hold of random-ness.
why does doing it in host result in less randomness?

>  - VLAN header acceleration
>    * Currently virtio doesn't not do vlan header acceleration and instead
>      uses software tagging.  The extension allows us to pass vlan id and
>      protocol to the host and take advantage of host HW vlan acceleration.

Consider vlan acceleration: it's normally done in hardware
but in our case isn't it just moving work over to
the hypervisor?

Some kind of performance improvement would have to be shown.


> 
>  - UDP tunnel offload
>    * Similar to vlan acceleration, with this extension we can pass additional
>      data to host for support GSO with udp tunnel and possible other
>      encapsulations.

Sounds interesting. Again, is there a performance improvement to be
had from this?

> This series only takes care of virtio net.  I have addition patches for the
> host side (vhost and tap/macvtap as well as qemu), but wanted to get feedback
> on the general approach first.
> Vladislav Yasevich (6):
>   virtio-net: Remove the use the padded vnet_header structure
>   virtio-net: make header length handling uniform
>   virtio_net: Add basic skeleton for handling vnet header extensions.
>   virtio-net: Add support for IPv6 fragment id vnet header extension.
>   virtio-net: Add support for vlan acceleration vnet header extension.
>   virtio-net: Add support for UDP tunnel offload and extension.
> 
>  drivers/net/virtio_net.c        | 132 +++++++++++++++++++++++++++++++++-------
>  include/linux/skbuff.h          |   5 ++
>  include/linux/virtio_net.h      |  91 ++++++++++++++++++++++++++-
>  include/uapi/linux/virtio_net.h |  38 ++++++++++++
>  4 files changed, 242 insertions(+), 24 deletions(-)
> 
> -- 
> 2.7.4
