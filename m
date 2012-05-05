From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 0/3] First pass of cleanups for pskb_expand_head
Date: Fri, 04 May 2012 17:26:40 -0700
Message-ID: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24583 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725Ab2EEA0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 20:26:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After looking over the tcp coalesing and GRO code a couple of days ago it
occurred to me that pskb_expand_head has a few flaws.  A few of which are
addressed in this patch series.

This change set takes care of some of the minor cleanup items.  One thing
that caught my eye is the fact the memmove code in the fast-path is likely
no longer doing any thing but burning cycles on a call that doesn't
actually move any memory.

The other change is a follow on to that to drop the fastpath variable which
really just means if the skb is cloned or not.

The final change in this set just adds an inline for getting the end offset
since there were multiple places where we were computing end - head to get
the offset and if we are storing it as an offset it makes more sense to
just pull the actual value.

There are a few more items that I will try to get to next week.  The big one
is the fact that pskb_expand_head can mess up the truesize since it can
allocate a new head but never updates the truesize.  I plan on adding a helper
function for the cases where we are just using it unshare the head so I can
identify the places where we are actually modifying the size.

---

Alexander Duyck (3):
      skb: Add inline helper for getting the skb end offset from head
      skb: Drop "fastpath" variable for skb_cloned check in pskb_expand_head
      skb: Drop bad code from pskb_expand_head


 drivers/atm/ambassador.c             |    2 +
 drivers/atm/idt77252.c               |    2 +
 drivers/net/wimax/i2400m/usb-rx.c    |    2 +
 drivers/staging/octeon/ethernet-tx.c |    2 +
 include/linux/skbuff.h               |   12 ++++++++-
 net/core/skbuff.c                    |   46 ++++++++++------------------------
 6 files changed, 29 insertions(+), 37 deletions(-)

-- 
Thanks,

Alex
