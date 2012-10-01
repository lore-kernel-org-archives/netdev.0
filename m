From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network namespace and kernel bind issue
Date: Mon, 01 Oct 2012 15:40:56 -0700
Message-ID: <87fw5xeryf.fsf@xmission.com>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60200 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889Ab2JAWlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 18:41:04 -0400
In-Reply-To: <20121001145838.5eafef4c@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Mon, 1 Oct 2012 14:58:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Mon, 1 Oct 2012 14:16:09 -0700
> Stephen Hemminger <shemminger@vyatta.com> wrote:
>
>> When testing VXLAN I noticed that the kernel bind seems to be a problem for
>> network tunnels. The init_net function is called repeatedly for the same
>> network namespace!

It definitely should not be.

>> 1. Create vxlan device:
>>  # ip li add vxlan0 type vxlan id 11 group 239.1.1.1 dev eth0
>>  # dmesg | tail
>> [11580.671016] vxlan: vxlan_init_net in net 1

Net 1?  What are you printing out?  It isn't the net_id by any chance?

>> 2. Start Chrome (or other application using namespaces)
>>  
>>   dmesg | tail
>> [11587.371195] vxlan: vxlan_init_net in net 1
>> [11587.371211] vxlan: bind for UDP socket 0.0.0.0:8472 (-98)
>> 
>> 
>> Isn't init_net supposed to be unique. The current semantics also break
>> L2TP.

The init method should be called exactly once per network namespace.

The timing of the init methods you report seems correct.

The vxlan code isn't in net-next or I would take a look.

I took a quick look at l2tp and the code is doing some weird things.
There are a bunch of references to &init_net that I would expect
to references to either sk_net() or dev_net().  

Adding support for multiple network namespaces and then reaching
out to the initial network namespace for things is definitely a recipe
for getting confused.

So my blind guess would be that someone half implemented network
namespace support for l2tp and vxlan copied the bugs.

Eric


>> This is with 3.6.0-rc7-net-next
>
> Here is back trace from where duplicate network namespace init gets done.

> [13532.579900] vxlan: bind for UDP socket 0.0.0.0:8472 (-98)
> [13532.579903] ------------[ cut here ]------------
> [13532.579906] WARNING: at drivers/net/vxlan.c:1148 vxlan_init_net+0xc9/0x126 [vxlan]()
> [13532.579907] Hardware name: System Product Name
> [13532.579908] Modules linked in: vxlan nfnetlink_log nfnetlink ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle xt_tcpudp iptable_filter ip_tables x_tables tun bridge stp llc cpufreq_stats cpufreq_powersave cpufreq_conservative cpufreq_userspace binfmt_misc fuse loop snd_hda_codec_hdmi snd_hda_codec_realtek i915 hid_belkin hid_generic snd_hda_intel evdev snd_hda_codec drm_kms_helper snd_hwdep drm snd_pcm_oss snd_pcm psmouse microcode snd_page_alloc serio_raw pcspkr i2c_i801 snd_timer i2c_algo_bit i2c_core acpi_cpufreq mperf processor video button btrfs libcrc32c lzo_compress zlib_deflate crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 ablk_hel
 per cryptd usbhid hid ixgbe r8169 mii mdio thermal [last unloaded: vxlan]
> [13532.579965] Pid: 7130, comm: chromium-sandbo Not tainted 3.6.0-rc7-net-next+ #10
> [13532.579966] Call Trace:
> [13532.579972]  [<ffffffff8106674e>] warn_slowpath_common+0x83/0x9c
> [13532.579974]  [<ffffffff81066781>] warn_slowpath_null+0x1a/0x1c
> [13532.579976]  [<ffffffffa03ea87d>] vxlan_init_net+0xc9/0x126 [vxlan]
> [13532.579980]  [<ffffffff8136b4dd>] ops_init+0xcd/0xfc
> [13532.579982]  [<ffffffff8136b824>] setup_net+0x51/0xd8
> [13532.579984]  [<ffffffff8136bd37>] copy_net_ns+0x6c/0xd7
> [13532.579987]  [<ffffffff810882bb>] create_new_namespaces+0xd8/0x14f
> [13532.579989]  [<ffffffff81088417>] copy_namespaces+0x69/0x9e
> [13532.579991]  [<ffffffff81065b10>] copy_process.part.27+0x12ae/0x12f5
> [13532.579994]  [<ffffffff8144170f>] ? do_page_fault+0x2fb/0x37c
> [13532.579997]  [<ffffffff8111d4d8>] ? might_fault+0x5c/0xac
> [13532.579998]  [<ffffffff81065cb2>] do_fork+0x120/0x2fc
> [13532.580001]  [<ffffffff810e7343>] ? time_hardirqs_off+0x15/0x2a
> [13532.580004]  [<ffffffff8143ea53>] ? error_sti+0x5/0x6
> [13532.580007]  [<ffffffff810a7204>] ? trace_hardirqs_off_caller+0x3f/0x9e
> [13532.580009]  [<ffffffff8143e646>] ? retint_swapgs+0xe/0x13
> [13532.580012]  [<ffffffff8103e541>] sys_clone+0x28/0x2a
> [13532.580014]  [<ffffffff814450e3>] stub_clone+0x13/0x20
> [13532.580016]  [<ffffffff81444d92>] ? system_call_fastpath+0x16/0x1b
> [13532.580018] ---[ end trace 2c2b222e23a4d880 ]---
> [13573.765721] vxlan: bind for UDP socket 0.0.0.0:8472 (-98)
