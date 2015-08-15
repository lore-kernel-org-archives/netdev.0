From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net] igb: Fix oops caused by missing queue pairing
Date: Sat, 15 Aug 2015 01:42:44 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81AE758E@ORSMSX101.amr.corp.intel.com>
References: <1435710352-956-1-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435710352-956-1-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Shota Suzuki
> Sent: Tuesday, June 30, 2015 5:26 PM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny,
> Carolyn; Skidmore, Donald C; Vick, Matthew; Ronciak, John; Williams, Mitch
> A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Cc: Shota Suzuki
> Subject: [PATCH net] igb: Fix oops caused by missing queue pairing
> 
> When initializing igb driver (e.g. 82576, I350), IGB_FLAG_QUEUE_PAIRS is
> set if adapter->rss_queues exceeds half of max_rss_queues in
> igb_init_queue_configuration().
> On the other hand, IGB_FLAG_QUEUE_PAIRS is not set even if the number of
> queues exceeds half of max_combined in igb_set_channels() when changing
> the number of queues by "ethtool -L".
> In this case, if numvecs is larger than MAX_MSIX_ENTRIES (10), the size
> of adapter->msix_entries[], an overflow can occur in
> igb_set_interrupt_capability(), which in turn leads to an oops.
> 
> Fix this problem as follows:
>  - When changing the number of queues by "ethtool -L", set
>    IGB_FLAG_QUEUE_PAIRS in the same way as initializing igb driver.
>  - When increasing the size of q_vector, reallocate it appropriately.
>    (With IGB_FLAG_QUEUE_PAIRS set, the size of q_vector gets larger.)
> 
> Another possible way to fix this problem is to cap the queues at its
> initial number, which is the number of the initial online cpus. But this
> is not the optimal way because we cannnot increase queues when another
> cpu becomes online.
> 
> Note that before commit cd14ef54d25b ("igb: Change to use statically
> allocated array for MSIx entries"), this problem did not cause oops
> but just made the number of queues become 1 because of entering msi_only
> mode in igb_set_interrupt_capability().
> 
> Fixes: 907b7835799f ("igb: Add ethtool support to configure number of
> channels")
> Signed-off-by: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
> ---
> Although we might be able to additionally unset IGB_FLAG_QUEUE_PAIRS
> when it is not needed, this patch doesn't change existing behaviour
> because such a change is not a bug fix.
> 
>  drivers/net/ethernet/intel/igb/igb.h         |  1 +
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |  5 ++++-
>  drivers/net/ethernet/intel/igb/igb_main.c    | 16 ++++++++++++++--
>  3 files changed, 19 insertions(+), 3 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
