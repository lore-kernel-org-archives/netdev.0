From: Joe Perches <joe@perches.com>
Subject: [PATCH] ethtool: Use kcalloc instead of kmalloc for
 ethtool_get_strings
Date: Wed, 14 Oct 2015 01:09:40 -0700
Message-ID: <1444810180.2718.16.camel@perches.com>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1444805996-3877-16-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0096.hostedemail.com ([216.40.44.96]:44291 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750817AbbJNIJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 04:09:44 -0400
In-Reply-To: <1444805996-3877-16-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that kernel memory can leak into userspace by a
kmalloc, ethtool_get_strings, then copy_to_user sequence.

Avoid this by using kcalloc to zero fill the copied buffer.

Signed-off-by: Joe Perches <joe@perches.com>
---

stable too...

On Tue, 2015-10-13 at 23:59 -0700, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
[]
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
[]
> @@ -206,13 +206,13 @@ static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
>  	}
>  
>  	for (i = 0; i < interface->hw.mac.max_queues; i++) {
> -		sprintf(p, "tx_queue_%u_packets", i);
> +		snprintf(p, ETH_GSTRING_LEN, "tx_queue_%u_packets", i);

It seems these need a memset after the snprintf to zero fill
bytes after the string terminating \0 to avoid leaking
contents of any unset bytes.

It'd probably be better to allocate a zeroed buffer instead.

>  		p += ETH_GSTRING_LEN;
> -		sprintf(p, "tx_queue_%u_bytes", i);
> +		snprintf(p, ETH_GSTRING_LEN, "tx_queue_%u_bytes", i);

so...

 net/core/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b495ab1..29edf74 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1284,7 +1284,7 @@ static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 
 	gstrings.len = ret;
 
-	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
+	data = kcalloc(gstrings.len, ETH_GSTRING_LEN, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
