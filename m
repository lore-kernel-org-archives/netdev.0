From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] ethernet/sfc: mark state UNINIT after unregister
Date: Mon, 15 Jun 2015 12:58:39 -0400
Message-ID: <557F043F.5020908@redhat.com>
References: <1434135061-42521-1-git-send-email-jarod@redhat.com> <557ED7DE.7080407@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <557ED7DE.7080407@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/15/2015 9:49 AM, Edward Cree wrote:
> On 12/06/15 19:51, Jarod Wilson wrote:
>> Without this change, modprobe -r sfc hits the BUG_ON() in
>> efx_pci_remove_main(). Best as I can tell, this was just an oversight,
>> efx->state gets set to STATE_UNINIT in the error path of
>> efx_register_netdev() just after unregister_netdevice(), and the same
>> should happen in efx_unregister_netdev() after its unregister_netdevice()
>> call. Now I can load and unload no problem.
>>
>> CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
>> CC: netdev@vger.kernel.org
>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>> ---
>>   drivers/net/ethernet/sfc/efx.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
>> index 0c42ed9..f3eaade 100644
>> --- a/drivers/net/ethernet/sfc/efx.c
>> +++ b/drivers/net/ethernet/sfc/efx.c
>> @@ -2448,6 +2448,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
>>   #endif
>>                device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
>>                unregister_netdev(efx->net_dev);
>> +             efx->state = STATE_UNINIT;
>>        }
>>   }
>>
> This isn't quite the right place, efx->state changes are supposed to be serialised by the RTNL lock.
> Our out-of-tree driver has this in efx_pci_remove, just after the efx_disable_interrupts(efx) call and before rtnl_unlock() (see patch below).  I'd suggest that's the change we should make, but I haven't tested it yet.
>
> For reference, the "oversight" was in my e7fef9b45ae188066bb6eb3dde8310d33c2f7d5e "sfc: add sysfs entry to control MCDI tracing" which accidentally took our out-of-tree version of efx_unregister_netdev().  Before that the code was as in Jarod's patch.

Ah, I did notice the rtnl_lock calls before some other occasions where 
state was set, but was thinking the lock might not be necessary if we're 
that far along the teardown path with the netdev already unregistered. 
You know the code far better than I do though, and your version works 
just fine here too.

Feel free to add this (along with your signed-off-by, of course):

Reviewed-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
