From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Mon, 7 Sep 2015 16:43:13 +0200
Message-ID: <55EDA281.3030706@gmail.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de> <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:32797 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbbIGOnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 10:43:17 -0400
Received: by wiclk2 with SMTP id lk2so91140675wic.0
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 07:43:16 -0700 (PDT)
In-Reply-To: <20150907085023.GA17511@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.09.2015 10:50, Corinna Vinschen wrote:
> On Sep  7 09:13, poma wrote:
>> On 06.09.2015 12:19, Corinna Vinschen wrote:
>>> On Sep  4 22:59, Francois Romieu wrote:
>>>>  Applies against davem's net as of f1ccbfce2fc787981d1182d09c1f6b67766783a8.
>>>>
>>>>  drivers/net/ethernet/realtek/r8169.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
>>>> index 24dcbe6..56829ea 100644
>>>> --- a/drivers/net/ethernet/realtek/r8169.c
>>>> +++ b/drivers/net/ethernet/realtek/r8169.c
>>>> @@ -2200,7 +2200,7 @@ static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
>>>>  	struct rtl8169_counters *counters;
>>>>  	u32 cmd;
>>>>  
>>>> -	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL);
>>>> +	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_ATOMIC);
>>>>  	if (counters) {
>>>>  		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
>>>>  		cmd = (u64)*paddr & DMA_BIT_MASK(32);
>>>> -- 
>>>> 2.4.3
>>> [...]
>> 1. Reverted to r8169.c?id=eb78139
>>    - the noise is still present
>> 2. Patches applied - Francois Romieu (3):
>>    r8169: decouple the counters data and the device private area.
>>    r8169: move rtl_reset_counters_cond before the hardware counters helpers.
>>    r8169: increase the lifespan of the hardware counters dump area.
>>    - the noise is still present
> 
> Sure you tested the right code?  I'm just asking because...
> 
>> [   70.016445]  [<ffffffff81847841>] dump_stack+0x4b/0x63
>> [   70.016456]  [<ffffffff811008c7>] lockdep_rcu_suspicious+0xd7/0x110
>> [   70.016465]  [<ffffffff810d5297>] ___might_sleep+0xa7/0x230
>> [   70.016472]  [<ffffffff810d5469>] __might_sleep+0x49/0x80
>> [   70.016481]  [<ffffffff811e54ce>] __alloc_pages_nodemask+0x2fe/0xb90
>> [   70.016490]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
>> [   70.016499]  [<ffffffff81024ab9>] ? sched_clock+0x9/0x10
>> [   70.016507]  [<ffffffff810e24ac>] ? local_clock+0x1c/0x20
>> [   70.016514]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
>> [   70.016524]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
>> [   70.016534]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
>> [   70.016541]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
>> [   70.016555]  [<ffffffffa003525e>] rtl8169_map_counters+0x3e/0x70 [r8169]
> 
> ...rtl8169_map_counters only exists before Francois patch.  The patch
> removes this function.
> 
> 
> Corinna
> 

I do not know, is this OK?

$ rpm -i https://kojipkgs.fedoraproject.org/packages/kernel/4.3.0/0.rc0.git7.1.fc24/src/kernel-4.3.0-0.rc0.git7.1.fc24.src.rpm
$ rpmbuild -bp rpmbuild/SPECS/kernel.spec
$ cd rpmbuild/BUILD/kernel-4.2.fc24/linux-4.3.0-0.rc0.git7.1.fc24.x86_64/

$ curl -s "http://marc.info/?l=linux-netdev&m=144145559429943&q=raw" | patch -p1
patching file drivers/net/ethernet/realtek/r8169.c
patch unexpectedly ends in middle of line
$ curl -s "http://marc.info/?l=linux-netdev&m=144145559729944&q=raw" | patch -p1
patching file drivers/net/ethernet/realtek/r8169.c
patch unexpectedly ends in middle of line
$ curl -s "http://marc.info/?l=linux-netdev&m=144145558929942&q=raw" | patch -p1
patching file drivers/net/ethernet/realtek/r8169.c
patch unexpectedly ends in middle of line

$ sed -i 's/PATCHLEVEL = 2/PATCHLEVEL = 3/' Makefile
$ sed -i 's/EXTRAVERSION =/EXTRAVERSION = -0.rc0.git7.1.fc24.x86_64/' Makefile

$ make -j drivers/net/ethernet/realtek/r8169.ko
$ su
# cp drivers/net/ethernet/realtek/r8169.ko /usr/lib/modules/4.3.0-0.rc0.git7.1.fc24.x86_64/updates/
# depmod 

# dracut -f --kver 4.3.0-0.rc0.git7.1.fc24.x86_64 
# lsinitrd --kver 4.3.0-0.rc0.git7.1.fc24.x86_64 | grep r8169
... usr/lib/modules/4.3.0-0.rc0.git7.1.fc24.x86_64/updates/r8169.ko

# systemctl reboot
