From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net/bonding: Add function bond_remove_proc_entry at __bond_release_one
Date: Wed, 15 Jul 2015 19:49:11 +0200
Message-ID: <55A69D17.5030800@cumulusnetworks.com>
References: <1436813848-30995-1-git-send-email-clsoto@linux.vnet.ibm.com> <55A4282A.1060401@cumulusnetworks.com> <55A42962.9080004@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
	j.vosburgh@gmail.com, gospo@cumulusnetworks.com
To: clsoto@linux.vnet.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:34527 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbbGORtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 13:49:15 -0400
Received: by wgkl9 with SMTP id l9so39567979wgk.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 10:49:14 -0700 (PDT)
In-Reply-To: <55A42962.9080004@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2015 11:10 PM, Nikolay Aleksandrov wrote:
> On 07/13/2015 11:05 PM, Nikolay Aleksandrov wrote:
>> On 07/13/2015 08:57 PM, clsoto@linux.vnet.ibm.com wrote:
>>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>>
>>> Add function bond_remove_proc_entry at __bond_release_one to avoid stack 
>>> trace at rmmod bonding.
>>>
>>> [68830.202239] remove_proc_entry: removing non-empty directory
>>> 'net/bonding', leaking at least 'bond0'
>>> [68830.202257] ------------[ cut here ]------------
>>> [68830.202260] WARNING: at fs/proc/generic.c:562
>>> [68830.202412] NIP [c0000000002abf6c] .remove_proc_entry+0x1fc/0x240
>>> [68830.202416] LR [c0000000002abf68] .remove_proc_entry+0x1f8/0x240
>>> [68830.202419] PACATMSCRATCH [8000000000009032]
>>> [68830.202421] Call Trace:
>>> [68830.202424] [c000000179277940] [c0000000002abf68] 
>>> .remove_proc_entry+0x1f8/0x240 (unreliable)
>>> [68830.202434] [c0000001792779f0] [d0000000053229a4] 
>>> .bond_destroy_proc_dir+0x34/0x54 [bonding]
>>> [68830.202440] [c000000179277a70] [d0000000053130e0] 
>>> .bond_net_exit+0x90/0x120 [bonding]
>>> [68830.202445] [c000000179277b10] [c00000000059944c] 
>>> .ops_exit_list.isra.0+0x6c/0xd0
>>> [68830.202450] [c000000179277ba0] [c000000000599774] 
>>> .unregister_pernet_operations+0x94/0x100
>>> [68830.202454] [c000000179277c40] [c000000000599814] 
>>> .unregister_pernet_subsys+0x34/0x60
>>> [68830.202460] [c000000179277cc0] [d000000005323758] 
>>> .bonding_exit+0x48/0x2328 [bonding]
>>> [68830.202466] [c000000179277d30] [c00000000010dcc4] 
>>> .SyS_delete_module+0x1f4/0x340
>>> [68830.202471] [c000000179277e30] [c000000000009e7c] 
>>> syscall_exit+0x0/0x7c
>>> [68830.202491] ---[ end trace 9bd1d810219c9875 ]---
>>>
>>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>> ---
>>>  drivers/net/bonding/bond_main.c | 2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>> index 19eb990..ace105a 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -1870,6 +1870,8 @@ static int __bond_release_one(struct net_device *bond_dev,
>>>  		dev_set_mac_address(slave_dev, &addr);
>>>  	}
>>>  
>>> +	bond_remove_proc_entry(bond);
>>> +
>>>  	dev_set_mtu(slave_dev, slave->original_mtu);
>>>  
>>>  	slave_dev->priv_flags &= ~IFF_BONDING;
>>>
>>
>> This is incorrect, it tries to remove the bond entry on every slave release
>> so if we have a bonding device with >= 2 slaves and release one of them then
>> the whole bond device entry will be removed from /proc/net/bonding.
> <<<<>>>>
>> You can hit this case only if you had created a bonding device while doing the
>> rmmod bonding (it's an old race condition which was fixed long time ago, but
>> the procfs was apparently missed) and only after the notifier has been
>> unregistered but before the sysfs has been removed.
>>
> Scratch this part, it should be triggered in a different way.
> Could you provide a way to reproduce ?
> 
>> Since the bonding netdevice notifier is handling the procfs creation/destruction
>> we could try moving the unregister after the pernet destruction which should
>> help avoid such problems. Could you try the following patch:
>>
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 19eb990d398c..d515ee38b77f 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -4682,12 +4682,10 @@ err_link:
>>  
>>  static void __exit bonding_exit(void)
>>  {
>> -	unregister_netdevice_notifier(&bond_netdev_notifier);
>> -
>>  	bond_destroy_debugfs();
>> -
>>  	bond_netlink_fini();
>>  	unregister_pernet_subsys(&bond_net_ops);
>> +	unregister_netdevice_notifier(&bond_netdev_notifier);
>>  
>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>>  	/* Make sure we don't have an imbalance on our netpoll blocking */
>>

After we had a private discussion I was able to reproduce this issue with
tap devices (!= ARPHRD_ETHER and can be enslaved):

[14446.539000] bond0: Releasing active interface tun1
[14446.548333] bond0 (unregistering): Released all slaves
[14446.564200] ------------[ cut here ]------------
[14446.564208] WARNING: CPU: 0 PID: 6319 at fs/proc/generic.c:575 remove_proc_entry+0x112/0x160()
[14446.564211] remove_proc_entry: removing non-empty directory 'net/bonding', leaking at least 'bond0'
[14446.564212] Modules linked in: tun bonding(-) eql(O) 9p stp llc nfsd auth_rpcgss oid_registry nfs_acl nfs lockd grace fscache sunrpc crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel joydev hid_generic usbhid hid snd_hda_codec_generic ppdev aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd psmouse pcspkr snd_hda_intel evdev snd_hda_codec snd_hwdep qxl snd_hda_core serio_raw snd_pcm snd_timer snd 9pnet_virtio 9pnet virtio_balloon soundcore i2c_piix4 drm_kms_helper ttm drm i2c_core virtio_console pvpanic parport_pc parport acpi_cpufreq processor thermal_sys button autofs4 ext4 crc16 mbcache jbd2 sg sr_mod cdrom ata_generic virtio_blk virtio_net e1000 ata_piix floppy ehci_pci uhci_hcd ehci_hcd libata scsi_mod usbcore usb_common virtio_pci virtio_ring virtio [l
 ast unloaded: bridge]

[14446.564295] CPU: 0 PID: 6319 Comm: rmmod Tainted: G           O    4.2.0-rc2+ #6
[14446.564296] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[14446.564299]  0000000000000000 ffffffff81732d41 ffffffff81525b34 ffff880035bcbda8
[14446.564302]  ffffffff8106c521 ffff8800367c5f78 ffff8800367c5f40 ffff88003e3a4280
[14446.564304]  ffffffffa05a5040 0000000000000000 ffffffff8106c59a ffffffff8172ebd0
[14446.564307] Call Trace:
[14446.564313]  [<ffffffff81525b34>] ? dump_stack+0x40/0x50
[14446.564317]  [<ffffffff8106c521>] ? warn_slowpath_common+0x81/0xb0
[14446.564320]  [<ffffffff8106c59a>] ? warn_slowpath_fmt+0x4a/0x50
[14446.564323]  [<ffffffff81218352>] ? remove_proc_entry+0x112/0x160
[14446.564329]  [<ffffffffa059d0d6>] ? bond_destroy_proc_dir+0x26/0x30 [bonding]
[14446.564332]  [<ffffffffa058d40e>] ? bond_net_exit+0x8e/0xa0 [bonding]
[14446.564336]  [<ffffffff8142f407>] ? ops_exit_list.isra.4+0x37/0x70
[14446.564340]  [<ffffffff8142f52d>] ? unregister_pernet_operations+0x8d/0xd0
[14446.564343]  [<ffffffff8142f58d>] ? unregister_pernet_subsys+0x1d/0x30
[14446.564346]  [<ffffffffa059d259>] ? bonding_exit+0x23/0xdca [bonding]
[14446.564350]  [<ffffffff810e28ba>] ? SyS_delete_module+0x18a/0x250
[14446.564354]  [<ffffffff81086f99>] ? task_work_run+0x89/0xc0
[14446.564357]  [<ffffffff8152b732>] ? entry_SYSCALL_64_fastpath+0x16/0x75
[14446.564360] ---[ end trace a911dbcedf315986 ]---

The problem is in bond_release_and_destroy() and I'll post a proper fix
for -net in a few minutes after I run some tests.

Cheers,
 Nik
