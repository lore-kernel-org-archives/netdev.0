From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net/bonding: Add function bond_remove_proc_entry at __bond_release_one
Date: Mon, 13 Jul 2015 23:10:58 +0200
Message-ID: <55A42962.9080004@cumulusnetworks.com>
References: <1436813848-30995-1-git-send-email-clsoto@linux.vnet.ibm.com> <55A4282A.1060401@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
	j.vosburgh@gmail.com, gospo@cumulusnetworks.com
To: clsoto@linux.vnet.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35672 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbbGMVLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 17:11:02 -0400
Received: by wiga1 with SMTP id a1so81165937wig.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 14:11:01 -0700 (PDT)
In-Reply-To: <55A4282A.1060401@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2015 11:05 PM, Nikolay Aleksandrov wrote:
> On 07/13/2015 08:57 PM, clsoto@linux.vnet.ibm.com wrote:
>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>
>> Add function bond_remove_proc_entry at __bond_release_one to avoid stack 
>> trace at rmmod bonding.
>>
>> [68830.202239] remove_proc_entry: removing non-empty directory
>> 'net/bonding', leaking at least 'bond0'
>> [68830.202257] ------------[ cut here ]------------
>> [68830.202260] WARNING: at fs/proc/generic.c:562
>> [68830.202412] NIP [c0000000002abf6c] .remove_proc_entry+0x1fc/0x240
>> [68830.202416] LR [c0000000002abf68] .remove_proc_entry+0x1f8/0x240
>> [68830.202419] PACATMSCRATCH [8000000000009032]
>> [68830.202421] Call Trace:
>> [68830.202424] [c000000179277940] [c0000000002abf68] 
>> .remove_proc_entry+0x1f8/0x240 (unreliable)
>> [68830.202434] [c0000001792779f0] [d0000000053229a4] 
>> .bond_destroy_proc_dir+0x34/0x54 [bonding]
>> [68830.202440] [c000000179277a70] [d0000000053130e0] 
>> .bond_net_exit+0x90/0x120 [bonding]
>> [68830.202445] [c000000179277b10] [c00000000059944c] 
>> .ops_exit_list.isra.0+0x6c/0xd0
>> [68830.202450] [c000000179277ba0] [c000000000599774] 
>> .unregister_pernet_operations+0x94/0x100
>> [68830.202454] [c000000179277c40] [c000000000599814] 
>> .unregister_pernet_subsys+0x34/0x60
>> [68830.202460] [c000000179277cc0] [d000000005323758] 
>> .bonding_exit+0x48/0x2328 [bonding]
>> [68830.202466] [c000000179277d30] [c00000000010dcc4] 
>> .SyS_delete_module+0x1f4/0x340
>> [68830.202471] [c000000179277e30] [c000000000009e7c] 
>> syscall_exit+0x0/0x7c
>> [68830.202491] ---[ end trace 9bd1d810219c9875 ]---
>>
>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 19eb990..ace105a 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1870,6 +1870,8 @@ static int __bond_release_one(struct net_device *bond_dev,
>>  		dev_set_mac_address(slave_dev, &addr);
>>  	}
>>  
>> +	bond_remove_proc_entry(bond);
>> +
>>  	dev_set_mtu(slave_dev, slave->original_mtu);
>>  
>>  	slave_dev->priv_flags &= ~IFF_BONDING;
>>
> 
> This is incorrect, it tries to remove the bond entry on every slave release
> so if we have a bonding device with >= 2 slaves and release one of them then
> the whole bond device entry will be removed from /proc/net/bonding.
<<<<>>>>
> You can hit this case only if you had created a bonding device while doing the
> rmmod bonding (it's an old race condition which was fixed long time ago, but
> the procfs was apparently missed) and only after the notifier has been
> unregistered but before the sysfs has been removed.
> 
Scratch this part, it should be triggered in a different way.
Could you provide a way to reproduce ?

> Since the bonding netdevice notifier is handling the procfs creation/destruction
> we could try moving the unregister after the pernet destruction which should
> help avoid such problems. Could you try the following patch:
> 
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 19eb990d398c..d515ee38b77f 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4682,12 +4682,10 @@ err_link:
>  
>  static void __exit bonding_exit(void)
>  {
> -	unregister_netdevice_notifier(&bond_netdev_notifier);
> -
>  	bond_destroy_debugfs();
> -
>  	bond_netlink_fini();
>  	unregister_pernet_subsys(&bond_net_ops);
> +	unregister_netdevice_notifier(&bond_netdev_notifier);
>  
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	/* Make sure we don't have an imbalance on our netpoll blocking */
> 
