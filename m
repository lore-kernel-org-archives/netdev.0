From: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH net-next] net/mlx4_core: Fix backward compatibility on VFs
Date: Mon, 21 Mar 2016 16:02:16 +1100
Message-ID: <56EF8058.2060203@ozlabs.ru>
References: <1458233382-12871-1-git-send-email-eli@mellanox.com>
 <56EBCE2F.40902@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56EBCE2F.40902-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/18/2016 08:45 PM, Alexey Kardashevskiy wrote:
> On 03/18/2016 03:49 AM, Eli Cohen wrote:
>> Commit 85743f1eb345 ("net/mlx4_core: Set UAR page size to 4KB regardless
>> of system page size") introduced dependency where old VF drivers without
>> this fix fail to load if the PF driver runs with this commit.
>>
>> To resolve this add a module parameter which disables that functionality
>> by default.  If both the PF and VFs are running with a driver with that
>> commit the administrator may set the module param to true.
>>
>> The module parameter is called enable_4k_uar.
>>
>> Fixes: 85743f1eb345 ('net/mlx4_core: Set UAR page size to 4KB ...')
>> Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>
> Thanks!

After more tries, I found that if for whatever reason mlx4_core fails to 
stop while shutting the guest down (last message is "mlx4_core 
0000:00:00.0: mlx4_shutdown was called"), then next time VF in guest won't 
start.

Example #1:

mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
mlx4_core: Initializing 0000:00:00.0
mlx4_core 0000:00:00.0: enabling device (0000 -> 0002)
mlx4_core 0000:00:00.0: Detected virtual function - running in slave mode
mlx4_core 0000:00:00.0: Sending reset
mlx4_core 0000:00:00.0: Sending vhcr0
mlx4_core 0000:00:00.0: HCA minimum page size:1
mlx4_core 0000:00:00.0: UAR size:4096 != kernel PAGE_SIZE of 65536
mlx4_core 0000:00:00.0: Failed to obtain slave caps

Example #2:

root@le-dbg:~# dhclient eth0
NETDEV WATCHDOG: eth0 (mlx4_core): transmit queue 11 timed out
------------[ cut here ]------------
WARNING: at /home/aik/p/guest-kernel/net/sched/sch_generic.c:303

and no IP assigned, timed out.


This is fixed by the guest restart, first restart might not help, then the 
second restart will.

The host is running the latest upstream plus the patch I am replying to. 
The guest is using initramdisk from debian bootstrap and vanilla v4.2 
kernel, ppc64le arch, POWER8 chip, QEMU is running with 1 CPU and 2GB of RAM.

Does this look any familiar?



>
>
> Tested-by: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
>
>
>
>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/main.c | 24 ++++++++++++++++++------
>>   1 file changed, 18 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c
>> b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index 503ec23e84cc..358f7230da58 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -105,6 +105,11 @@ module_param(enable_64b_cqe_eqe, bool, 0444);
>>   MODULE_PARM_DESC(enable_64b_cqe_eqe,
>>            "Enable 64 byte CQEs/EQEs when the FW supports this (default:
>> True)");
>>
>> +static bool enable_4k_uar;
>> +module_param(enable_4k_uar, bool, 0444);
>> +MODULE_PARM_DESC(enable_4k_uar,
>> +         "Enable using 4K UAR. Should not be enabled if have VFs which
>> do not support 4K UARs (default: false)");
>> +
>>   #define PF_CONTEXT_BEHAVIOUR_MASK    (MLX4_FUNC_CAP_64B_EQE_CQE | \
>>                        MLX4_FUNC_CAP_EQE_CQE_STRIDE | \
>>                        MLX4_FUNC_CAP_DMFS_A0_STATIC)
>> @@ -423,7 +428,11 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct
>> mlx4_dev_cap *dev_cap)
>>           /* Virtual PCI function needs to determine UAR page size from
>>            * firmware. Only master PCI function can set the uar page size
>>            */
>> -        dev->uar_page_shift = DEFAULT_UAR_PAGE_SHIFT;
>> +        if (enable_4k_uar)
>> +            dev->uar_page_shift = DEFAULT_UAR_PAGE_SHIFT;
>> +        else
>> +            dev->uar_page_shift = PAGE_SHIFT;
>> +
>>           mlx4_set_num_reserved_uars(dev, dev_cap);
>>       }
>>
>> @@ -2233,11 +2242,14 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
>>
>>           dev->caps.max_fmr_maps = (1 << (32 -
>> ilog2(dev->caps.num_mpts))) - 1;
>>
>> -        /* Always set UAR page size 4KB, set log_uar_sz accordingly */
>> -        init_hca.log_uar_sz = ilog2(dev->caps.num_uars) +
>> -                      PAGE_SHIFT -
>> -                      DEFAULT_UAR_PAGE_SHIFT;
>> -        init_hca.uar_page_sz = DEFAULT_UAR_PAGE_SHIFT - 12;
>> +        if (enable_4k_uar) {
>> +            init_hca.log_uar_sz = ilog2(dev->caps.num_uars) +
>> +                            PAGE_SHIFT - DEFAULT_UAR_PAGE_SHIFT;
>> +            init_hca.uar_page_sz = DEFAULT_UAR_PAGE_SHIFT - 12;
>> +        } else {
>> +            init_hca.log_uar_sz = ilog2(dev->caps.num_uars);
>> +            init_hca.uar_page_sz = PAGE_SHIFT - 12;
>> +        }
>>
>>           init_hca.mw_enabled = 0;
>>           if (dev->caps.flags & MLX4_DEV_CAP_FLAG_MEM_WINDOW ||
>>
>
>


-- 
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
