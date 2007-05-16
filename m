From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Work around 82571 completion timout on Pseries
 HW
Date: Wed, 16 May 2007 12:00:57 -0400
Message-ID: <464B2AB9.4050706@garzik.org>
References: <20070516085329.29131.120.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wenxiong@us.ibm.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58103 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222AbXEPQBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 12:01:05 -0400
In-Reply-To: <20070516085329.29131.120.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Our 82571 (first PCI-E hardware) causes P-Series hardware to throw
> issues. Disabling PCI-E completion timeouts in our NIC resolves
> the issue.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Wen Xiong <wenxiong@us.ibm.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 49be393..830d851 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
>  		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
>  	}
>  
> +#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)
> +#define E1000_GCR_DISABLE_TIMEOUT_MECHANISM 0x80000000
> +	if (adapter->hw.mac.type == e1000_82571) {
> +		/* work around pSeries hardware by disabling timeouts */
> +		u32 gcr = E1000_READ_REG(&adapter->hw, E1000_GCR);
> +		gcr |= E1000_GCR_DISABLE_TIMEOUT_MECHANISM;
> +		E1000_WRITE_REG(&adapter->hw, E1000_GCR, gcr);

Why is this needed?

Is pSeries PCI-E implementation problematic?  Or is this a e1000 PCI-E 
hardware bug?  If the former, I wonder if this is the best way to work 
around the issue, especially since it might crop up in other PCI-E 
boards besides e1000.  If the latter, it seems like we should disable 
the feature on all platforms.

	Jeff


