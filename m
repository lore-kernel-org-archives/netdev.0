From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] Restore UFO support to virtio_net devices
Date: Mon, 26 Jan 2015 17:28:42 +0200
Message-ID: <20150126152842.GA5130@redhat.com>
References: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	ben@decadent.org.uk, edumazet@google.com,
	Vladislav Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbbAZP3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 10:29:03 -0500
Content-Disposition: inline
In-Reply-To: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2015 at 09:37:03AM -0500, Vladislav Yasevich wrote:
> commit 3d0ad09412ffe00c9afa201d01effdb6023d09b4
> Author: Ben Hutchings <ben@decadent.org.uk>
> Date:   Thu Oct 30 18:27:12 2014 +0000
> 
>     drivers/net: Disable UFO through virtio
> 
> Turned off UFO support to virtio-net based devices due to issues
> with IPv6 fragment id generation for UFO packets.  The issue
> was that IPv6 UFO/GSO implementation expects the fragment id
> to be supplied in skb_shinfo().  However, for packets generated
> by the VMs, the fragment id is not supplied which causes all
> IPv6 fragments to have the id of 0.
> 
> The problem is that turning off UFO support on tap/macvtap
> as well as virtio devices caused issues with migrations.  
> Migrations would fail when moving a vm from a kernel supporting
> expecting UFO to work to the newer kernels that disabled UFO.
> 
> This series provides a partial solution to address the migration
> issue.  The series reserves a bit in the skb and sets the bit
> with the ipv6 fragment id has been generated for the packet.
> UFO/GSO code then checks the bit to see if the fragment id
> is already present or if a new fragment id needs to be generated.
> This solution allows host-originated UFO packets to keep a
> better randomized fragment id, as well as generating a randomized
> id for VM generated traffic (solving the fragment id 0 issue).
> 
> Vladislav Yasevich (3):
>   ipv6: Select fragment id during UFO/GSO segmentation if not set.
>   Revert "drivers/net, ipv6: Select IPv6 fragment idents for virtio UFO
>     packets"
>   Revert "drivers/net: Disable UFO through virtio"
> 
>  drivers/net/macvtap.c    | 16 ++++++++--------
>  drivers/net/tun.c        | 25 +++++++++----------------
>  drivers/net/virtio_net.c | 24 ++++++++++--------------
>  include/linux/skbuff.h   |  3 ++-
>  include/net/ipv6.h       |  2 ++
>  net/ipv6/ip6_output.c    |  4 ++--
>  net/ipv6/output_core.c   |  9 ++++++++-
>  net/ipv6/udp_offload.c   | 10 +++++++++-
>  8 files changed, 50 insertions(+), 43 deletions(-)

Should also help a lot to put UDP performance where it was.

Acked-by: Michael S. Tsirkin <mst@redhat.com>



> -- 
> 1.9.3
