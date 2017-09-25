From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Mon, 25 Sep 2017 14:10:00 -0400
Message-ID: <20170925181000.GA60144@C02RW35GFVH8.dhcp.broadcom.net>
References: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, peter.waskiewicz.jr@intel.com,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        mchan@broadcom.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:49506 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935062AbdIYSKH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 14:10:07 -0400
Received: by mail-qk0-f170.google.com with SMTP id u67so7555658qkg.6
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 11:10:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 02:25:51AM +0200, Daniel Borkmann wrote:
> This work enables generic transfer of metadata from XDP into skb. The
> basic idea is that we can make use of the fact that the resulting skb
> must be linear and already comes with a larger headroom for supporting
> bpf_xdp_adjust_head(), which mangles xdp->data. Here, we base our work
> on a similar principle and introduce a small helper bpf_xdp_adjust_meta()
> for adjusting a new pointer called xdp->data_meta. Thus, the packet has
> a flexible and programmable room for meta data, followed by the actual
> packet data. struct xdp_buff is therefore laid out that we first point
> to data_hard_start, then data_meta directly prepended to data followed
> by data_end marking the end of packet. bpf_xdp_adjust_head() takes into
> account whether we have meta data already prepended and if so, memmove()s
> this along with the given offset provided there's enough room.
> 
> xdp->data_meta is optional and programs are not required to use it. The
> rationale is that when we process the packet in XDP (e.g. as DoS filter),
> we can push further meta data along with it for the XDP_PASS case, and
> give the guarantee that a clsact ingress BPF program on the same device
> can pick this up for further post-processing. Since we work with skb
> there, we can also set skb->mark, skb->priority or other skb meta data
> out of BPF, thus having this scratch space generic and programmable
> allows for more flexibility than defining a direct 1:1 transfer of
> potentially new XDP members into skb (it's also more efficient as we
> don't need to initialize/handle each of such new members).  The facility
> also works together with GRO aggregation. The scratch space at the head
> of the packet can be multiple of 4 byte up to 32 byte large. Drivers not
> yet supporting xdp->data_meta can simply be set up with xdp->data_meta
> as xdp->data + 1 as bpf_xdp_adjust_meta() will detect this and bail out,
> such that the subsequent match against xdp->data for later access is
> guaranteed to fail.
> 
> The verifier treats xdp->data_meta/xdp->data the same way as we treat
> xdp->data/xdp->data_end pointer comparisons. The requirement for doing
> the compare against xdp->data is that it hasn't been modified from it's
> original address we got from ctx access. It may have a range marking
> already from prior successful xdp->data/xdp->data_end pointer comparisons
> though.

First, thanks for this detailed description.  It was helpful to read
along with the patches.

My only concern about this area being generic is that you are now in a
state where any bpf program must know about all the bpf programs in the
receive pipeline before it can properly parse what is stored in the
meta-data and add it to an skb (or perform any other action).
Especially if each program adds it's own meta-data along the way.

Maybe this isn't a big concern based on the number of users of this
today, but it just starts to seem like a concern as there are these
hints being passed between layers that are challenging to track due to a
lack of a standard format for passing data between.

The main reason I bring this up is that Michael and I had discussed and
designed a way for drivers to communicate between each other that rx
resources could be freed after a tx completion on an XDP_REDIRECT
action.  Much like this code, it involved adding an new element to
struct xdp_md that could point to the important information.  Now that
there is a generic way to handle this, it would seem nice to be able to
leverage it, but I'm not sure how reliable this meta-data area would be
without the ability to mark it in some manner.

For additional background, the minimum amount of data needed in the case
Michael and I were discussing was really 2 words.  One to serve as a
pointer to an rx_ring structure and one to have a counter to the rx
producer entry.  This data could be acessed by the driver processing the
tx completions and callback to the driver that received the frame off the wire
to perform any needed processing.  (For those curious this would also require a
new callback/netdev op to act on this data stored in the XDP buffer.)

IIUC, I could use this meta_data area to store this information, but would it
also be useful to create some type field/marker that could also be stored in
the meta_data to indicate what type of information is there?  I hate to propose
such a thing as it may add unneeded complexity, but I just wanted to make sure
to say something before it was too late as there may be more users of this
right away.  :-)

> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: John Fastabend <john.fastabend@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |   1 +
>  drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   1 +
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   1 +
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   1 +
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   1 +
>  .../net/ethernet/netronome/nfp/nfp_net_common.c    |   1 +
>  drivers/net/ethernet/qlogic/qede/qede_fp.c         |   1 +
>  drivers/net/tun.c                                  |   1 +
>  drivers/net/virtio_net.c                           |   2 +
>  include/linux/bpf.h                                |   1 +
>  include/linux/filter.h                             |  21 +++-
>  include/linux/skbuff.h                             |  68 +++++++++++-
>  include/uapi/linux/bpf.h                           |  13 ++-
>  kernel/bpf/verifier.c                              | 114 ++++++++++++++++-----
>  net/bpf/test_run.c                                 |   1 +
>  net/core/dev.c                                     |  31 +++++-
>  net/core/filter.c                                  |  77 +++++++++++++-
>  net/core/skbuff.c                                  |   2 +
>  19 files changed, 297 insertions(+), 42 deletions(-)
[...]
