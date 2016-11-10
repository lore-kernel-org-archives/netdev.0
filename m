From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH v2] e1000e: free IRQ regardless of
 __E1000_DOWN
Date: Thu, 10 Nov 2016 08:19:28 +0200
Message-ID: <42e53bc2-0361-e7b7-1093-4e095aa56955@intel.com>
References: <1478727681-16505-1-git-send-email-tbaicar@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Tyler Baicar <tbaicar@codeaurora.org>, jeffrey.t.kirsher@intel.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, okaya@codeaurora.org,
        timur@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478727681-16505-1-git-send-email-tbaicar@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/9/2016 11:41 PM, Tyler Baicar wrote:
> Move IRQ free code so that it will happen regardless of the
> __E1000_DOWN bit. Currently the e1000e driver only releases its IRQ
> if the __E1000_DOWN bit is cleared. This is not sufficient because
> it is possible for __E1000_DOWN to be set without releasing the IRQ.
> In such a situation, we will hit a kernel bug later in e1000_remove
> because the IRQ still has action since it was never freed. A
> secondary bus reset can cause this case to happen.
> 
> Signed-off-by: Tyler Baicar <tbaicar@codeaurora.org>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 7017281..36cfcb0 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -4679,12 +4679,13 @@ int e1000e_close(struct net_device *netdev)
>  
>  	if (!test_bit(__E1000_DOWN, &adapter->state)) {
>  		e1000e_down(adapter, true);
> -		e1000_free_irq(adapter);
>  
>  		/* Link status message must follow this format */
>  		pr_info("%s NIC Link is Down\n", adapter->netdev->name);
>  	}				
>  
> +	e1000_free_irq(adapter);
> +
>  	napi_disable(&adapter->napi);
>  
>  	e1000e_free_tx_resources(adapter->tx_ring);
> 
I would like not recommend insert this change. This change related
driver state machine, we afraid from lot of synchronization problem and
issues.
We need keep e1000_free_irq in loop and check for 'test_bit' ready.
Another point, does before execute secondary bus reset your SW back up
pcie configuration space as properly?

Sasha
