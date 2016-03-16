From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 00/13] Mellanox 100G mlx5 driver receive path optimizations
Date: Wed, 16 Mar 2016 19:04:55 +0200
Message-ID: <CALzJLG8j0k96XJm-t0LRrQvzf2CLMZF8kj14HUVTP2FWumYxOw@mail.gmail.com>
References: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:36438 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934084AbcCPRE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 13:04:57 -0400
Received: by mail-yw0-f196.google.com with SMTP id p65so4149390ywb.3
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 10:04:56 -0700 (PDT)
In-Reply-To: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 8:41 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Hello Dave,
>
> Changes from V0:
>         - Fixed a typo in commit message reported by Sergei
>         - Align SKB fragments truesize to stride size
>         - Use skb_add_rx_frag and remove the use of SKB_TRUESIZE
>         - Fix: # MTTs alignment on Power PC
>         - Fix: Free original (unaligned) pointer of MTT array
>         - Use dev_alloc_pages and dev_alloc_page
>         - Extend the stats.buff_alloc_err counter
>         - Reform the copying of packet header into skb linear data
>         - Add compiler hints for conditional statements
>         - Prefetch skd->data prior to copying packet header into it
>         - Rework: mlx5e_complete_rx_fragmented_mpwqe
>         - Handle SKB fragments before linear data
>         - Dropped ("net/mlx5e: Prefetch next RX CQE") for now
>         - Added a small patch that Adds ConnectX-5 devices to the list of supported devices
>         - Rebased to 1cdba5505555 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next")
>
> This series includes Some RX modifications and optimizations for
> the mlx5 Ethernet driver.

Hi Dave,

Tariq is working on one more perf optimization that can potentially
save cache miss per SKB. In this series we do get_page per SKB on the
same WQE (page) and the stack might release this SKB on a different
CPU, our solution is to hold max potential SKBs as a ref count for
that page once on allocation, and release the ref count held by the
driver (taking into account the ref count held by the actual SKBs)
once the whole page gets consumed,

Also for the issue Eric raised on out of order possible DOS attack, we
came up with a solution that limits drivers memory footprint, by
reusing the large WQEs (pages) and in case they are not available (may
be due to the issue Eric raised) we won't allow more large pages
(WQEs) to be allocated and we will fallback to fragmented small pages.

Please hold on with this series for V2 with the above improvements.

Thanks.
