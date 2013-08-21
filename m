From: Andrey Konovalov <andreyknvl@google.com>
Subject: Potential use-after-free in e1000_clean_tx_irq
Date: Wed, 21 Aug 2013 20:10:15 +0400
Message-ID: <CAAeHK+yxpbkSuzRNBis++q002sxW8TWv2f6tStOq5Z7cRBkkAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4181752635677439983=="
Cc: netdev@vger.kernel.org, Alexander Potapenko <glider@google.com>,
	Evgeniy Stepanov <eugenis@google.com>, Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============4181752635677439983==
Content-Type: multipart/alternative; boundary=089e013cc028bab52204e4776829

--089e013cc028bab52204e4776829
Content-Type: text/plain; charset=ISO-8859-1

Hi,

I'm working on a memory error detector AddressSanitizer for Linux kernel (
https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel),
which can detect use-after-free and buffer-overflow errors.
Currently the tool is in very early stage and it can contain bugs.

I was running a system call fuzzer and got some reports:

[   64.143848]
=========================================================================
[   64.144763] ERROR: AddressSanitizer: heap-use-after-free on address
ffff88002a3dae60
[   64.145945] Stack trace:
[   64.146302]   [<ffffffff810dd1f5>] asan_report_error+0x85/0x2c0
[   64.147112]   [<ffffffff810dc700>] asan_check_region+0x30/0x40
[   64.147966]   [<ffffffff810dd4b3>] __tsan_read4+0x13/0x20
[   64.148808]   [<ffffffffa00804d0>] e1000_clean+0x1d0/0x11b0 [e1000]
[   64.149742]   [<ffffffff817f8e1a>] net_rx_action+0x1aa/0x380
[   64.150574]   [<ffffffff810ee9d2>] __do_softirq+0x182/0x3a0
[   64.151391]   [<ffffffff8192629c>] call_softirq+0x1c/0x30
[   64.152179]   [<ffffffff8108040d>] do_softirq+0x5d/0xc0
[   64.152926]   [<ffffffff810ed3d7>] local_bh_enable+0x127/0x130
[   64.153717]   [<ffffffff8185d775>] ip_finish_output+0x365/0x640
[   64.154653]   [<ffffffff8185fc79>] ip_output+0xb9/0x100
[   64.155423]   [<ffffffff8185ed1c>] ip_local_out+0x4c/0x60
[   64.156216]   [<ffffffff818611b3>] ip_send_skb+0x23/0x70
[   64.156951]   [<ffffffff818a4bf4>] udp_send_skb+0x584/0x6e0
[   64.157761]   [<ffffffff818a681c>] udp_sendmsg+0x4dc/0xfd0
[   64.158581]   [<ffffffff818b93e8>] inet_sendmsg+0x108/0x160
[   64.159401]   [<ffffffff817d0f43>] sock_sendmsg+0x133/0x170
[   64.160143]   [<ffffffff817d1669>] SYSC_sendto+0x1e9/0x2d0
[   64.160932]   [<ffffffff817d2329>] SyS_sendto+0x49/0x70
[   64.161710]   [<ffffffff81826e55>] compat_sys_socketcall+0x305/0x530
[   64.162634]   [<ffffffff81926335>] sysenter_dispatch+0x7/0x1a
[   64.163471]   [<ffffffffffffffff>] 0xffffffffffffffff
[   64.164213] Free stack trace:
[   64.164660]   [<ffffffff810dc831>] asan_slab_free+0x61/0xb0
[   64.165466]   [<ffffffff8127f955>] kmem_cache_free+0x55/0x2e0
[   64.166261]   [<ffffffff817db68b>] kfree_skbmem+0x5b/0xd0
[   64.167046]   [<ffffffff817e003c>] consume_skb+0x4c/0xd0
[   64.167811]   [<ffffffff817f3f90>] dev_kfree_skb_any+0x60/0x70
[   64.168710]   [<ffffffffa007c6ba>]
e1000_unmap_and_free_tx_resource.isra.45+0xda/0x130 [e1000]
[   64.169954]   [<ffffffffa00804e9>] e1000_clean+0x1e9/0x11b0 [e1000]
[   64.170859]   [<ffffffff817f8e1a>] net_rx_action+0x1aa/0x380
[   64.171685]   [<ffffffff810ee9d2>] __do_softirq+0x182/0x3a0
[   64.172491]   [<ffffffff8192629c>] call_softirq+0x1c/0x30
[   64.173276]   [<ffffffff8108040d>] do_softirq+0x5d/0xc0
[   64.174041]   [<ffffffff810ed3d7>] local_bh_enable+0x127/0x130
[   64.174868]   [<ffffffff8185d775>] ip_finish_output+0x365/0x640
[   64.175734]   [<ffffffff8185fc79>] ip_output+0xb9/0x100
[   64.176518]   [<ffffffff8185ed1c>] ip_local_out+0x4c/0x60
[   64.177315]   [<ffffffff818611b3>] ip_send_skb+0x23/0x70
[   64.178087]   [<ffffffff818a4bf4>] udp_send_skb+0x584/0x6e0
[   64.178910]   [<ffffffff818a681c>] udp_sendmsg+0x4dc/0xfd0
[   64.179713]   [<ffffffff818b93e8>] inet_sendmsg+0x108/0x160
[   64.180524]   [<ffffffff817d0f43>] sock_sendmsg+0x133/0x170
[   64.181332]   [<ffffffff817d1669>] SYSC_sendto+0x1e9/0x2d0
[   64.182001]   [<ffffffff817d2329>] SyS_sendto+0x49/0x70
[   64.182771]   [<ffffffff817d238b>] SyS_send+0x3b/0x50
[   64.183508] Shadow bytes around the buggy address:
[   64.184258]   ffff88003ba7b570: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.185109]   ffff88003ba7b580: fa fa fa fa fa fa fa fa fd fd fd fd fd
fd fd fd
[   64.186184]   ffff88003ba7b590: fd fd fd fd fd fd fd fd fd fd fd fd fd
fd fd fd
[   64.187257]   ffff88003ba7b5a0: fd fd fd fd fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.188442]   ffff88003ba7b5b0: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.189520] =>ffff88003ba7b5c0: fd fd fd fd fd fd fd fd fd fd fd
fd[fd]fd fd fd
[   64.190600]   ffff88003ba7b5d0: fd fd fd fd fd fd fd fd fd fd fd fd fa
fa fa fa
[   64.191676]   ffff88003ba7b5e0: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.192730]   ffff88003ba7b5f0: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.193822]   ffff88003ba7b600: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.194903]   ffff88003ba7b610: fa fa fa fa fa fa fa fa 00 00 00 00 fa
fa fa fa
[   64.195954] Shadow byte legend (one shadow byte represents 8 application
bytes):
[   64.197039]   Addressable:           00
[   64.197585]   Partially addressable: 01 02 03 04 05 06 07
[   64.198407]   Heap redzone:          fa
[   64.198955]   Freed heap region:     fd
[   64.199519]
=========================================================================

[   64.200424]
=========================================================================
[   64.201539] ERROR: AddressSanitizer: heap-use-after-free on address
ffff88002a3daedc
[   64.202432] Stack trace:
[   64.202814]   [<ffffffff810dd1f5>] asan_report_error+0x85/0x2c0
[   64.203636]   [<ffffffff810dc700>] asan_check_region+0x30/0x40
[   64.204481]   [<ffffffff810dd4b3>] __tsan_read4+0x13/0x20
[   64.205267]   [<ffffffff817e001b>] consume_skb+0x2b/0xd0
[   64.206066]   [<ffffffff817f3f90>] dev_kfree_skb_any+0x60/0x70
[   64.206923]   [<ffffffffa007c6ba>]
e1000_unmap_and_free_tx_resource.isra.45+0xda/0x130 [e1000]
[   64.208144]   [<ffffffffa00804e9>] e1000_clean+0x1e9/0x11b0 [e1000]
[   64.209067]   [<ffffffff817f8e1a>] net_rx_action+0x1aa/0x380
[   64.209866]   [<ffffffff810ee9d2>] __do_softirq+0x182/0x3a0
[   64.210671]   [<ffffffff8192629c>] call_softirq+0x1c/0x30
[   64.211463]   [<ffffffff8108040d>] do_softirq+0x5d/0xc0
[   64.212227]   [<ffffffff810ed3d7>] local_bh_enable+0x127/0x130
[   64.213074]   [<ffffffff8185d775>] ip_finish_output+0x365/0x640
[   64.213910]   [<ffffffff8185fc79>] ip_output+0xb9/0x100
[   64.214661]   [<ffffffff8185ed1c>] ip_local_out+0x4c/0x60
[   64.215451]   [<ffffffff818611b3>] ip_send_skb+0x23/0x70
[   64.216249]   [<ffffffff818a4bf4>] udp_send_skb+0x584/0x6e0
[   64.217064]   [<ffffffff818a681c>] udp_sendmsg+0x4dc/0xfd0
[   64.217838]   [<ffffffff818b93e8>] inet_sendmsg+0x108/0x160
[   64.218687]   [<ffffffff817d0f43>] sock_sendmsg+0x133/0x170
[   64.219496]   [<ffffffff817d1669>] SYSC_sendto+0x1e9/0x2d0
[   64.220297]   [<ffffffff817d2329>] SyS_sendto+0x49/0x70
[   64.221069]   [<ffffffff81826e55>] compat_sys_socketcall+0x305/0x530
[   64.222053]   [<ffffffff81926335>] sysenter_dispatch+0x7/0x1a
[   64.222867]   [<ffffffffffffffff>] 0xffffffffffffffff
[   64.223592] Free stack trace:
[   64.224050]   [<ffffffff810dc831>] asan_slab_free+0x61/0xb0
[   64.224841]   [<ffffffff8127f955>] kmem_cache_free+0x55/0x2e0
[   64.225559]   [<ffffffff817db68b>] kfree_skbmem+0x5b/0xd0
[   64.226342]   [<ffffffff817e003c>] consume_skb+0x4c/0xd0
[   64.227121]   [<ffffffff817f3f90>] dev_kfree_skb_any+0x60/0x70
[   64.227958]   [<ffffffffa007c6ba>]
e1000_unmap_and_free_tx_resource.isra.45+0xda/0x130 [e1000]
[   64.229240]   [<ffffffffa00804e9>] e1000_clean+0x1e9/0x11b0 [e1000]
[   64.230149]   [<ffffffff817f8e1a>] net_rx_action+0x1aa/0x380
[   64.230947]   [<ffffffff810ee9d2>] __do_softirq+0x182/0x3a0
[   64.231706]   [<ffffffff8192629c>] call_softirq+0x1c/0x30
[   64.232451]   [<ffffffff8108040d>] do_softirq+0x5d/0xc0
[   64.233219]   [<ffffffff810ed3d7>] local_bh_enable+0x127/0x130
[   64.234012]   [<ffffffff8185d775>] ip_finish_output+0x365/0x640
[   64.234842]   [<ffffffff8185fc79>] ip_output+0xb9/0x100
[   64.235621]   [<ffffffff8185ed1c>] ip_local_out+0x4c/0x60
[   64.236431]   [<ffffffff818611b3>] ip_send_skb+0x23/0x70
[   64.237221]   [<ffffffff818a4bf4>] udp_send_skb+0x584/0x6e0
[   64.237991]   [<ffffffff818a681c>] udp_sendmsg+0x4dc/0xfd0
[   64.238788]   [<ffffffff818b93e8>] inet_sendmsg+0x108/0x160
[   64.239604]   [<ffffffff817d0f43>] sock_sendmsg+0x133/0x170
[   64.240413]   [<ffffffff817d1669>] SYSC_sendto+0x1e9/0x2d0
[   64.241213]   [<ffffffff817d2329>] SyS_sendto+0x49/0x70
[   64.241954]   [<ffffffff817d238b>] SyS_send+0x3b/0x50
[   64.242681] Shadow bytes around the buggy address:
[   64.243422]   ffff88003ba7b580: fa fa fa fa fa fa fa fa fd fd fd fd fd
fd fd fd
[   64.244534]   ffff88003ba7b590: fd fd fd fd fd fd fd fd fd fd fd fd fd
fd fd fd
[   64.245615]   ffff88003ba7b5a0: fd fd fd fd fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.246691]   ffff88003ba7b5b0: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.247768]   ffff88003ba7b5c0: fd fd fd fd fd fd fd fd fd fd fd fd fd
fd fd fd
[   64.248886] =>ffff88003ba7b5d0: fd fd fd fd fd fd fd fd fd fd fd[fd]fa
fa fa fa
[   64.250001]   ffff88003ba7b5e0: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.251084]   ffff88003ba7b5f0: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.252162]   ffff88003ba7b600: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.253236]   ffff88003ba7b610: fa fa fa fa fa fa fa fa 00 00 00 00 fa
fa fa fa
[   64.254312]   ffff88003ba7b620: fa fa fa fa fa fa fa fa fa fa fa fa fa
fa fa fa
[   64.255431] Shadow byte legend (one shadow byte represents 8 application
bytes):
[   64.256500]   Addressable:           00
[   64.257083]   Partially addressable: 01 02 03 04 05 06 07
[   64.257851]   Heap redzone:          fa
[   64.258397]   Freed heap region:     fd
[   64.258942]
=========================================================================

There were more use-after-free reports after these two.

The first use-after-free was caused by accessing 'len' field in
'buffer_info->skb' in 'e1000_clean_tx_irq' (line 3835).
Our guess is that 'buffer_info->skb' had been freed in another thread (the
bottom frames of the stack traces are different) by
'e1000_unmap_and_free_tx_resource' (line 1972) but wasn't assigned to
'NULL' yet (line 1973).

The kernel version is 3.11-rc4 (last commit:
b7bc9e7d808ba55729bd263b0210cda36965be32).

e100_clean_tx_irq:
http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/e1000/e1000_main.c#L3835
e1000_unmap_and_free_tx_resource:
http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/e1000/e1000_main.c#L1958

Since these reports were caused by a system call fuzzer I don't know how to
reproduce them.

Could you confirm if this is a real bug?

Thanks!

--089e013cc028bab52204e4776829--


--===============4181752635677439983==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Introducing Performance Central, a new site from SourceForge and 
AppDynamics. Performance Central is your source for news, insights, 
analysis and resources for efficient Application Performance Management. 
Visit us today!
http://pubads.g.doubleclick.net/gampad/clk?id=48897511&iu=/4140/ostg.clktrk
--===============4181752635677439983==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4181752635677439983==--
