From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC 00/11] mlx5 RX refactoring and XDP support
Date: Wed,  7 Sep 2016 15:42:21 +0300
Message-ID: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: iovisor-dev <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45241 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932536AbcIGMm6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 08:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch set introduces some important data path RX refactoring
addressing mlx5e memory allocation/management improvements and XDP support.

Submitting as RFC since we would like to get an early feedback, while we
continue reviewing testing and complete the performance analysis in house.

In details:
>From Tariq, three patches that address the page allocation and memory fragmentation
issue of mlx5e striding RQ, where we used to allocate order 5 pages then split them 
into order 0 pages.  Basically we now allocate only order 0 pages and we default
to what we used to call the fallback mechanism (ConnectX4 UMR) to virtually map 
them into device as one big chunk.  The last two patches in his series, Tariq introduces
a mapped pages internal cache API for mlx5e driver to recover from the performance
degradation we hit, since now we allocate 32 order 0 pages when required in striding RQ
RX path.  Those two patches of mapped pages cache API are needed later in my series
of XDP support.

XDP support:
To have proper XDP support a "page per packet" is a must have prerequisite and
neither of our two RX modes can trivially do XDP.  Striding RQ is not an option,
since the whole idea from it is to share memory and have minimum HW descriptors
for as much packets as we can.

The other mode is a regular RX ring mode where we have a HW descriptor per packet,
but the main issue is that ring SKBs are allocated in advance and skb->data is mapped
directly to device (drop decision will not be as fast as we want, since we will need to
free the skb).  For that we've made some RX refactoring also in regular RQ mode area 
where we now allocate a page per packet and use build_skb.  To overcome the page allocator 
overhead, we use the page cache API.  For those who have ConnectX4-LX where striding RQ is
the default, if xdp is requested we will move to regular ring RQ mode, and move back to
striding mode when xdp goes back to off.

Some issues are needed to be addressed now, having a page per packet is not perfect as
it seems, driver memory consumption just got up, and as a future work, we need to
share pages for multiple packets when XDP is off, especially for systems with large
PAGE_SIZE. 

For XDP TX forwarding support, we add it in the last two patches.
Nothing is really special there :).

You will find much more details and initial performance numbers in the patches commit messages.

Thanks,
Saeed.

Rana Shahout (1):
  net/mlx5e: XDP fast RX drop bpf programs support

Saeed Mahameed (7):
  net/mlx5e: Build RX SKB on demand
  net/mlx5e: Union RQ RX info per RQ type
  net/mlx5e: Slightly reduce hardware LRO size
  net/mlx5e: Dynamic RQ type infrastructure
  net/mlx5e: Have a clear separation between different SQ types
  net/mlx5e: XDP TX forwarding support
  net/mlx5e: XDP TX xmit more

Tariq Toukan (3):
  net/mlx5e: Single flow order-0 pages for Striding RQ
  net/mlx5e: Introduce API for RX mapped pages
  net/mlx5e: Implement RX mapped page cache for page recycle

 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 144 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 581 +++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 618 ++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  32 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  61 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  67 ++-
 6 files changed, 998 insertions(+), 505 deletions(-)

-- 
2.7.4
