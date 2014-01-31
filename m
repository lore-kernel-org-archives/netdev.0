From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 17/34] ixgbevf: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 22:20:43 +0300
Message-ID: <52EBF78B.6040609@cogentembedded.com>
References: <cover.1391172839.git.agordeev@redhat.com> <3d63d58082b8cb80de7f2cb434ca5d83781e8c9f.1391172839.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Alexander Gordeev <agordeev@redhat.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:44467 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932900AbaAaSUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 13:20:32 -0500
Received: by mail-la0-f51.google.com with SMTP id c6so3809745lan.10
        for <netdev@vger.kernel.org>; Fri, 31 Jan 2014 10:20:31 -0800 (PST)
In-Reply-To: <3d63d58082b8cb80de7f2cb434ca5d83781e8c9f.1391172839.git.agordeev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2014 06:08 PM, Alexander Gordeev wrote:

> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.

> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> ---
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   33 +++++++-------------
>   1 files changed, 12 insertions(+), 21 deletions(-)

> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 9df2898..521a9d7 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c

> @@ -1831,33 +1830,25 @@ static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
>   	 * Right now, we simply care about how many we'll get; we'll
>   	 * set them up later while requesting irq's.
>   	 */
> -	while (vectors >= vector_threshold) {
> -		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
> -				      vectors);
> -		if (!err || err < 0) /* Success or a nasty failure. */
> -			break;
> -		else /* err == number of vectors we should try again with */
> -			vectors = err;
> -	}
> +	vectors = pci_enable_msix_range(adapter->pdev, adapter->msix_entries,
> +					vector_threshold, vectors);
>
> -	if (vectors < vector_threshold)
> -		err = -ENOMEM;
> -
> -	if (err) {
> +	if (vectors < 0) {
>   		dev_err(&adapter->pdev->dev,
>   			"Unable to allocate MSI-X interrupts\n");
>   		kfree(adapter->msix_entries);
>   		adapter->msix_entries = NULL;
> -	} else {
> -		/*
> -		 * Adjust for only the vectors we'll use, which is minimum
> -		 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
> -		 * vectors we were allocated.
> -		 */
> -		adapter->num_msix_vectors = vectors;
> +		return vectors;
>   	}
>
> -	return err;
> +	/*
> +	 * Adjust for only the vectors we'll use, which is minimum
> +	 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
> +	 * vectors we were allocated.
> +	 */

    Networking code formats multi-line comments slightly differently to the 
rest of the kernel:

/* bla
  * bla
  */

    Although, you're only moving what was there before you, maybe it's a good 
time to get this right.

WBR, Sergei
