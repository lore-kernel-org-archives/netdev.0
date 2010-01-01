From: "Berck E. Nash" <flyboy@gmail.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 31 Dec 2009 20:06:18 -0700
Message-ID: <4B3D66AA.3030709@gmail.com>
References: <4B3C8323.1080301@ring3k.org> <4B3CF2C4.5070203@gmail.com> <4B3D38FB.40105@ring3k.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010802060508010803030805"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, dhazelton@enter.net, mbreuer@majjas.com
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:60823 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab0AADGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 22:06:21 -0500
Received: by ywh6 with SMTP id 6so13285636ywh.4
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 19:06:21 -0800 (PST)
In-Reply-To: <4B3D38FB.40105@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010802060508010803030805
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Well, that didn't fix it.  Oops attached, looks pretty much the same to me.

Mike McCormack wrote:
> Hi Jarek,
> 
> This is based on my analysis of the oops at:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=14925
> 
> Specifically:
> 
>>>> [ 8673.345873] sky2 eth0: receiver hang detected
>>>> [ 8673.350368] sky2 eth0: disabling interface
>>>> [ 8673.354749] BUG: unable to handle kernel NULL pointer dereference at
>>>> 0000000000000010
>>>> [ 8673.359748] IP: [<ffffffffa00373d3>] sky2_xmit_frame+0x321/0x5d8 
>>>> [sky2]
> 
> netif_device_detach() does not guarantee that all transmits have completed 
> after it returns.
> 
> CPU 1 stack will look like:
> 
>   dev_queue_xmit()
>      HARD_TX_LOCK() -> __netif_tx_lock()
>      ...
>      dev_hard_start_xmit()
>         ops->ndo_start_xmit()  -> sky2_xmit_frame()
>         sky2_xmit_frame() pushing skb to hardware
>           use NULL tx_ring here
> 
> 
> CPU 2 stack will look like:
>            
>   sky2_restart()
>      rtnl_lock()
>      sky2_detach()
>         netif_device_detach()
>         sky2_down()
>           printk("sky2 eth0: disabling interface")
>           ...
>           sky2_free_buffers(sky2);
>             sky2->tx_ring = NULL;
>           ...
> 
> Another way to solve the problem would be to take the transmit lock in 
> netif_device_detach() to make sure that any in progress transmits have
> completed before returning.
> 
> Note that most of these backtraces are using the nvidia binary only 
> module.  This may change the timings and make the sky2 race more likely,
> or be involved in the "tx timeout" condition that triggers a sky2_restart().
> 
> Will test with netif_tx_lock_bh and resubmit.
> 
> thanks,
> 
> Mike
>      
>   
>    
> 
> Jarek Poplawski wrote:
>> Mike McCormack wrote, On 12/31/2009 11:55 AM:
>>
>>> netif_device_detach() does not take the tx_lock, so it's
>>>  possible that a call to sky2_xmit_frame is still in
>>>  progress after netif_device_detach() is complete.
>>>
>>> Take netif_tx_lock() to make sure all transmits have
>>>  stopped while we're disabling the devices and that
>>>  no other CPU is still transmitting a frame after
>>>  we've disabling the device.
>>>
>>> Proposed fix for "sky2 panic under load" reported by Berck E. Nash.
>> Could you give some scenario of the oops/fix?
>> Btw, even if it worked, you should use netif_tx_lock_bh
>> version considering sky2_detach use contexts, I guess.
>>
>> Jarek P.
>>
>>> Signed-off-by: Mike McCormack <mikem@ring3k.org>
>>> ---
>>>  drivers/net/sky2.c |    2 ++
>>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
>>> index faa4841..8ae8520 100644
>>> --- a/drivers/net/sky2.c
>>> +++ b/drivers/net/sky2.c
>>> @@ -3176,7 +3176,9 @@ static void sky2_reset(struct sky2_hw *hw)
>>>  static void sky2_detach(struct net_device *dev)
>>>  {
>>>  	if (netif_running(dev)) {
>>> +		netif_tx_lock(dev);
>>>  		netif_device_detach(dev);	/* stop txq */
>>> +		netif_tx_unlock(dev);
>>>  		sky2_down(dev);
>>>  	}
>>>  }
>>
> 


--------------010802060508010803030805
Content-Type: text/plain;
 name="sky2crash2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sky2crash2.txt"

[ 5768.704033] sky2 eth0: receiver hang detected
[ 5768.708579] sky2 eth0: disabling interface
[ 5768.712928] BUG: unable to handle kernel NULL pointer dereference at 0000000000000ad0
[ 5768.717776] IP: [<ffffffffa003d46f>] sky2_xmit_frame+0x321/0x5d8 [sky2]
[ 5768.726935] PGD beaa3067 PUD ba837067 PMD 0 
[ 5768.731121] Oops: 0002 [#1] SMP 
[ 5768.731121] last sysfs file: /sys/devices/platform/coretemp.0/temp1_label
[ 5768.740188] CPU 0 
[ 5768.742247] Modules linked in: nvidia(P) nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc nls_cp437 msdos fat kvm_intel kvm fuse snd_rtctimer usbhid hwmon_vid tuner_simple tuner_types wm8775 snd_hda_codec_realtek tda9887 tda8290 snd_hda_intel snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm tuner snd_seq_dummy cx25840 ivtv i2c_algo_bit cx2341x snd_seq_oss uhci_hcd snd_seq_midi_event ehci_hcd v4l2_common i2c_i801 snd_seq videodev snd_timer v4l1_compat v4l2_compat_ioctl32 snd_seq_device tveeprom snd floppy sky2 usbcore soundcore snd_page_alloc [last unloaded: nvidia]
[ 5768.794811] Pid: 4, comm: ksoftirqd/0 Tainted: P           2.6.32.2 #9 P5W DH Deluxe
[ 5768.801019] RIP: 0010:[<ffffffffa003d46f>]  [<ffffffffa003d46f>] sky2_xmit_frame+0x321/0x5d8 [sky2]
[ 5768.808600] RSP: 0018:ffff880001603df8  EFLAGS: 00010206
[ 5768.817679] RAX: 00000000000002b0 RBX: ffff8800bd184540 RCX: 0000000000000ac0
[ 5768.822147] RDX: 0000000000000000 RSI: 000000000000008c RDI: 0000000000000ac0
[ 5768.831325] RBP: ffff880001603e48 R08: 0000000000000001 R09: 0000000000000000
[ 5768.835840] R10: 000000000000001e R11: 0000000000000d7f R12: ffff880006a40ec8
[ 5768.844917] R13: ffff8800be922e00 R14: 0000000000560056 R15: 000000009553807e
[ 5768.853995] FS:  0000000000000000(0000) GS:ffff880001600000(0000) knlGS:0000000000000000
[ 5768.859584] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[ 5768.867708] CR2: 0000000000000ad0 CR3: 00000000ba8d8000 CR4: 00000000000026f0
[ 5768.872155] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 5768.881235] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 5768.888900] Process ksoftirqd/0 (pid: 4, threadinfo ffff8800bf8b4000, task ffff8800bf8a8650)
[ 5768.895027] Stack:
[ 5768.899363]  ffff88004c485ec0 ffff88009553807e ffff8800bd184000 0000004281229811
[ 5768.904093] <0> ffff880001603e48 ffff880006a40ec8 ffff88004c485ec0 ffffffff813ead30
[ 5768.913174] <0> ffff8800bd184000 ffff8800beb1dec0 ffff880001603e98 ffffffff81230fa0
[ 5768.922327] Call Trace:
[ 5768.922327]  <IRQ> 
[ 5768.926596]  [<ffffffff81230fa0>] dev_hard_start_xmit+0x21c/0x2b7
[ 5768.931393]  [<ffffffff8123f422>] sch_direct_xmit+0x5e/0x154
[ 5768.935678]  [<ffffffff8123f5d4>] __qdisc_run+0xbc/0xd5
[ 5768.944755]  [<ffffffff8122ecd1>] net_tx_action+0xbb/0x10e
[ 5768.949643]  [<ffffffff8103d292>] __do_softirq+0x91/0x11b
[ 5768.956054]  [<ffffffff8100be9c>] call_softirq+0x1c/0x28
[ 5768.958733]  <EOI> 
[ 5768.963566]  [<ffffffff8100d907>] do_softirq+0x33/0x6b
[ 5768.967800]  [<ffffffff8103cd9a>] ksoftirqd+0x60/0xd7
[ 5768.972644]  [<ffffffff8103cd3a>] ? ksoftirqd+0x0/0xd7
[ 5768.976939]  [<ffffffff8104a563>] kthread+0x7a/0x82
[ 5768.981727]  [<ffffffff8100bd9a>] child_rip+0xa/0x20
[ 5768.986004]  [<ffffffff8104a4e9>] ? kthread+0x0/0x82
[ 5768.990805]  [<ffffffff8100bd90>] ? child_rip+0x0/0x20
[ 5768.995081] Code: 06 00 00 00 00 89 08 66 c7 40 04 00 00 c6 40 06 01 c6 40 07 9f 41 0f b7 c6 48 89 c7 48 c1 e0 03 48 c1 e7 05 48 89 f9 48 03 4b 20 <4c> 89 79 10 48 c7 41 08 01 00 00 00 8b 75 cc 89 71 18 48 03 7b 
[ 5769.018044] RIP  [<ffffffffa003d46f>] sky2_xmit_frame+0x321/0x5d8 [sky2]
[ 5769.025816]  RSP <ffff880001603df8>
[ 5769.027123] CR2: 0000000000000ad0
[ 5769.033031] ---[ end trace 90bf20a10331c8d8 ]---
[ 5769.037702] Kernel panic - not syncing: Fatal exception in interrupt
[ 5769.044106] Pid: 4, comm: ksoftirqd/0 Tainted: P      D    2.6.32.2 #9
[ 5769.050724] Call Trace:
[ 5769.053213]  <IRQ>  [<ffffffff812975ed>] panic+0x75/0x11c
[ 5769.058677]  [<ffffffff8100e9a7>] oops_end+0x81/0x8e
[ 5769.063712]  [<ffffffff81026413>] no_context+0x1ee/0x1fd
[ 5769.069067]  [<ffffffff8102ee15>] ? walk_tg_tree+0x5e/0x74
[ 5769.074605]  [<ffffffff81026594>] __bad_area_nosemaphore+0x172/0x195
[ 5769.081044]  [<ffffffff810265c5>] bad_area_nosemaphore+0xe/0x10
[ 5769.087032]  [<ffffffff810267ff>] do_page_fault+0x114/0x252
[ 5769.092659]  [<ffffffff810307de>] ? update_shares+0x26/0x57
[ 5769.098291]  [<ffffffff81299bff>] page_fault+0x1f/0x30
[ 5769.103489]  [<ffffffffa003d46f>] ? sky2_xmit_frame+0x321/0x5d8 [sky2]
[ 5769.110097]  [<ffffffffa003d254>] ? sky2_xmit_frame+0x106/0x5d8 [sky2]
[ 5769.116706]  [<ffffffff81230fa0>] dev_hard_start_xmit+0x21c/0x2b7
[ 5769.122863]  [<ffffffff8123f422>] sch_direct_xmit+0x5e/0x154
[ 5769.128600]  [<ffffffff8123f5d4>] __qdisc_run+0xbc/0xd5
[ 5769.133933]  [<ffffffff8122ecd1>] net_tx_action+0xbb/0x10e
[ 5769.139468]  [<ffffffff8103d292>] __do_softirq+0x91/0x11b
[ 5769.144929]  [<ffffffff8100be9c>] call_softirq+0x1c/0x28
[ 5769.150291]  <EOI>  [<ffffffff8100d907>] do_softirq+0x33/0x6b
[ 5769.156125]  [<ffffffff8103cd9a>] ksoftirqd+0x60/0xd7
[ 5769.161240]  [<ffffffff8103cd3a>] ? ksoftirqd+0x0/0xd7
[ 5769.166430]  [<ffffffff8104a563>] kthread+0x7a/0x82
[ 5769.171370]  [<ffffffff8100bd9a>] child_rip+0xa/0x20
[ 5769.176398]  [<ffffffff8104a4e9>] ? kthread+0x0/0x82
[ 5769.181416]  [<ffffffff8100bd90>] ? child_rip+0x0/0x20

--------------010802060508010803030805--
