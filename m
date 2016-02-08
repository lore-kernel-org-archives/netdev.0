From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 0/3] net: mitigating kmem_cache free slowpath
Date: Mon, 08 Feb 2016 13:14:54 +0100
Message-ID: <20160208121328.8860.67014.stgit@localhost>
References: <20160207.142526.1252110536030712971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, linux-mm@kvack.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510AbcBHMO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 07:14:57 -0500
In-Reply-To: <20160207.142526.1252110536030712971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is the first real use-case for kmem_cache bulk _free_.
The use of bulk _alloc_ is NOT included in this patchset. The full use
have previously been posted here [1].

The bulk free side have the largest benefit for the network stack
use-case, because network stack is hitting the kmem_cache/SLUB
slowpath when freeing SKBs, due to the amount of outstanding SKBs.
This is solved by using the new API kmem_cache_free_bulk().

Introduce new API napi_consume_skb(), that hides/handles bulk freeing
for the caller.  The drivers simply need to use this call when freeing
SKBs in NAPI context, e.g. replacing their calles to dev_kfree_skb() /
dev_consume_skb_any().

Driver ixgbe is the first user of this new API.

[1] http://thread.gmane.org/gmane.linux.network/384302/focus=397373

---

Jesper Dangaard Brouer (3):
      net: bulk free infrastructure for NAPI context, use napi_consume_skb
      net: bulk free SKBs that were delay free'ed due to IRQ context
      ixgbe: bulk free SKBs during TX completion cleanup cycle


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +-
 include/linux/skbuff.h                        |    4 +
 net/core/dev.c                                |    9 ++-
 net/core/skbuff.c                             |   87 +++++++++++++++++++++++--
 4 files changed, 96 insertions(+), 10 deletions(-)
