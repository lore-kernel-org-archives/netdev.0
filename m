From: Kaiwen Xu <kevin@kevxu.net>
Subject: loopback device reference count leakage
Date: Tue, 24 Jan 2017 05:17:16 +0000
Message-ID: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt004-omc4s41.hotmail.com ([65.54.51.92]:57235 "EHLO
        SNT004-OMC4S41.hotmail.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750703AbdAXFWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 00:22:20 -0500
Content-Language: en-US
Content-ID: <BB76E9FE21828941B9CB80C9EAA25D4F@namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev folks,

I am currently experiencing an issue related with the loopback during
network devices shutdown inside a network namespace, which mainfested as

    unregister_netdevice: waiting for lo to become free. Usage count = 1

showing up every 10 seconds or so in the kernel log. It eventually
causes a deadlock on new network namespace creation.

When I was trying to debug the issue, I tested from latest kernel 4.10-rc
back to 3.19, which all can be reproduced on. I also tried to disable
IPv6, which doesn't help either.

So I tried to patch the kernel with following change to add addtional
logging message for dev_put() and dev_hold().

    https://lkml.org/lkml/2008/7/20/5

Here are all the dev_put/hold() calls for the loopback device inside a 
namespace from creation to shutdown, when the issue occurs.

Jan 11 16:17:43 <hostname> kernel: [ 2196.943640] lo: dev_hold 1 rx_queue_add_kobject
Jan 11 16:17:43 <hostname> kernel: [ 2196.943652] lo: dev_hold 2 netdev_queue_add_kobject
Jan 11 16:17:43 <hostname> kernel: [ 2196.943654] lo: dev_hold 3 register_netdevice
Jan 11 16:17:43 <hostname> kernel: [ 2196.943658] lo: dev_hold 4 neigh_parms_alloc
Jan 11 16:17:43 <hostname> kernel: [ 2196.943660] lo: dev_hold 5 inetdev_init
Jan 11 16:17:43 <hostname> kernel: [ 2197.001771] lo: dev_hold 6 qdisc_alloc
Jan 11 16:17:43 <hostname> kernel: [ 2197.001815] lo: dev_hold 7 dev_get_by_index
Jan 11 16:17:43 <hostname> kernel: [ 2197.001824] lo: dev_hold 8 dev_get_by_index
Jan 11 16:17:43 <hostname> kernel: [ 2197.001831] lo: dev_hold 9 fib_check_nh
Jan 11 16:17:43 <hostname> kernel: [ 2197.001836] lo: dev_hold 10 fib_check_nh
Jan 11 16:17:43 <hostname> kernel: [ 2197.001843] lo: dev_hold 11 dev_get_by_index
Jan 11 16:17:43 <hostname> kernel: [ 2197.001849] lo: dev_hold 12 dev_get_by_index
Jan 11 16:17:43 <hostname> kernel: [ 2197.001852] lo: dev_hold 13 fib_check_nh
Jan 11 16:17:43 <hostname> kernel: [ 2197.001856] lo: dev_hold 14 fib_check_nh
Jan 11 16:17:43 <hostname> kernel: [ 2197.025451] lo: dev_put 14 free_fib_info_rcu
Jan 11 16:17:43 <hostname> kernel: [ 2197.025473] lo: dev_put 13 free_fib_info_rcu
Jan 11 16:17:43 <hostname> kernel: [ 2197.025475] lo: dev_put 12 free_fib_info_rcu
Jan 11 16:17:43 <hostname> kernel: [ 2197.025477] lo: dev_put 11 free_fib_info_rcu
Jan 11 16:17:43 <hostname> kernel: [ 2197.025480] lo: dev_put 10 free_fib_info_rcu
Jan 11 16:17:43 <hostname> kernel: [ 2197.025482] lo: dev_put 9 free_fib_info_rcu
Jan 11 16:17:43 <hostname> kernel: [ 2197.414900] lo: dev_hold 9 dst_init
Jan 11 16:17:43 <hostname> kernel: [ 2197.418634] lo: dev_hold 10 dst_init
Jan 11 16:17:43 <hostname> kernel: [ 2197.418638] lo: dev_hold 11 dst_init
Jan 11 16:17:43 <hostname> kernel: [ 2197.445496] lo: dev_put 11 dst_destroy
Jan 11 16:17:44 <hostname> kernel: [ 2197.614240] lo: dev_hold 11 dst_init
Jan 11 16:20:41 <hostname> kernel: [ 2374.898896] lo: dev_hold 12 dst_init
Jan 11 16:20:41 <hostname> kernel: [ 2374.898917] lo: dev_hold 13 __neigh_create
Jan 11 16:23:42 <hostname> kernel: [ 2555.900160] lo: dev_hold 14 dst_init
Jan 11 16:24:10 <hostname> kernel: [ 2583.573193] lo: dev_hold 15 dst_init
Jan 11 16:26:09 <hostname> kernel: [ 2702.992174] lo: dev_hold 16 dst_init
Jan 11 16:27:15 <hostname> kernel: [ 2769.188044] lo: dev_hold 17 dst_init
Jan 11 16:31:57 <hostname> kernel: [ 3050.821593] lo: dev_hold 18 dst_init
Jan 11 16:37:41 <hostname> kernel: [ 3394.962714] lo: dev_hold 19 dst_init
Jan 11 16:46:27 <hostname> kernel: [ 3921.376163] lo: dev_hold 20 dst_init
Jan 11 16:46:30 <hostname> kernel: [ 3923.759813] lo: dev_hold 21 dst_init
Jan 11 16:47:01 <hostname> kernel: [ 3954.802588] lo: dev_hold 22 dst_ifdown
Jan 11 16:47:01 <hostname> kernel: [ 3954.802596] lo: dev_hold 23 dst_ifdown
Jan 11 16:47:01 <hostname> kernel: [ 3954.802599] lo: dev_hold 24 dst_ifdown
Jan 11 16:47:01 <hostname> kernel: [ 3954.802602] lo: dev_hold 25 dst_ifdown
Jan 11 16:47:01 <hostname> kernel: [ 3954.802605] lo: dev_hold 26 dst_ifdown
Jan 11 16:47:01 <hostname> kernel: [ 3954.802609] lo: dev_hold 27 dst_ifdown
Jan 11 16:47:01 <hostname> kernel: [ 3955.482563] lo: dev_put 27 dst_destroy
Jan 11 16:47:01 <hostname> kernel: [ 3955.482566] lo: dev_put 26 dst_destroy
Jan 11 16:47:01 <hostname> kernel: [ 3955.482568] lo: dev_put 25 dst_destroy
Jan 11 16:47:01 <hostname> kernel: [ 3955.482570] lo: dev_put 24 dst_destroy
Jan 11 16:47:01 <hostname> kernel: [ 3955.482572] lo: dev_put 23 dst_destroy
Jan 11 16:47:01 <hostname> kernel: [ 3955.482574] lo: dev_put 22 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.651505] lo: dev_put 21 neigh_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.653397] lo: dev_put 20 qdisc_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.653432] lo: dev_put 19 neigh_parms_release
Jan 11 16:49:20 <hostname> kernel: [ 4093.653463] lo: dev_put 18 rx_queue_release
Jan 11 16:49:20 <hostname> kernel: [ 4093.653474] lo: dev_put 17 netdev_queue_release
Jan 11 16:49:20 <hostname> kernel: [ 4093.653520] lo: dev_put 16 rollback_registered_many
Jan 11 16:49:20 <hostname> kernel: [ 4093.663424] lo: dev_put 15 free_fib_info_rcu
Jan 11 16:49:20 <hostname> kernel: [ 4093.667401] lo: dev_put 14 free_fib_info_rcu
Jan 11 16:49:20 <hostname> kernel: [ 4093.667430] lo: dev_put 13 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667432] lo: dev_put 12 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667434] lo: dev_put 11 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667436] lo: dev_put 10 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667438] lo: dev_put 9 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667441] lo: dev_put 8 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667446] lo: dev_put 7 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667453] lo: dev_put 6 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667459] lo: dev_put 5 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667461] lo: dev_put 4 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667463] lo: dev_put 3 dst_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667478] lo: dev_put 2 in_dev_finish_destroy
Jan 11 16:49:20 <hostname> kernel: [ 4093.667493] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:20 <hostname> kernel: [ 4093.667495] lo: dev_put 2 dst_ifdown
Jan 11 16:49:21 <hostname> kernel: [ 4094.691406] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:21 <hostname> kernel: [ 4094.691409] lo: dev_put 2 dst_ifdown
Jan 11 16:49:22 <hostname> kernel: [ 4095.715386] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:22 <hostname> kernel: [ 4095.715390] lo: dev_put 2 dst_ifdown
Jan 11 16:49:23 <hostname> kernel: [ 4096.739367] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:23 <hostname> kernel: [ 4096.739370] lo: dev_put 2 dst_ifdown
Jan 11 16:49:24 <hostname> kernel: [ 4097.763338] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:24 <hostname> kernel: [ 4097.763342] lo: dev_put 2 dst_ifdown
Jan 11 16:49:25 <hostname> kernel: [ 4098.787312] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:25 <hostname> kernel: [ 4098.787315] lo: dev_put 2 dst_ifdown
Jan 11 16:49:26 <hostname> kernel: [ 4099.811293] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:26 <hostname> kernel: [ 4099.811297] lo: dev_put 2 dst_ifdown
Jan 11 16:49:27 <hostname> kernel: [ 4100.835270] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:27 <hostname> kernel: [ 4100.835273] lo: dev_put 2 dst_ifdown
Jan 11 16:49:28 <hostname> kernel: [ 4101.859249] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:28 <hostname> kernel: [ 4101.859252] lo: dev_put 2 dst_ifdown
Jan 11 16:49:29 <hostname> kernel: [ 4102.883228] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:29 <hostname> kernel: [ 4102.883231] lo: dev_put 2 dst_ifdown
Jan 11 16:49:30 <hostname> kernel: [ 4103.907196] unregister_netdevice: waiting for lo to become free. Usage count = 1
Jan 11 16:49:30 <hostname> kernel: [ 4103.916753] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:30 <hostname> kernel: [ 4103.916755] lo: dev_put 2 dst_ifdown
Jan 11 16:49:31 <hostname> kernel: [ 4104.939171] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:31 <hostname> kernel: [ 4104.939174] lo: dev_put 2 dst_ifdown
Jan 11 16:49:32 <hostname> kernel: [ 4105.963147] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:32 <hostname> kernel: [ 4105.963150] lo: dev_put 2 dst_ifdown
Jan 11 16:49:33 <hostname> kernel: [ 4106.987135] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:33 <hostname> kernel: [ 4106.987138] lo: dev_put 2 dst_ifdown
Jan 11 16:49:34 <hostname> kernel: [ 4108.011109] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:34 <hostname> kernel: [ 4108.011112] lo: dev_put 2 dst_ifdown
Jan 11 16:49:35 <hostname> kernel: [ 4109.035084] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:35 <hostname> kernel: [ 4109.035087] lo: dev_put 2 dst_ifdown
Jan 11 16:49:36 <hostname> kernel: [ 4110.059057] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:36 <hostname> kernel: [ 4110.059060] lo: dev_put 2 dst_ifdown
Jan 11 16:49:37 <hostname> kernel: [ 4111.095053] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:37 <hostname> kernel: [ 4111.095056] lo: dev_put 2 dst_ifdown
Jan 11 16:49:38 <hostname> kernel: [ 4112.119017] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:38 <hostname> kernel: [ 4112.119020] lo: dev_put 2 dst_ifdown
Jan 11 16:49:39 <hostname> kernel: [ 4113.142987] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:39 <hostname> kernel: [ 4113.142990] lo: dev_put 2 dst_ifdown
Jan 11 16:49:40 <hostname> kernel: [ 4114.166957] unregister_netdevice: waiting for lo to become free. Usage count = 1
Jan 11 16:49:40 <hostname> kernel: [ 4114.176525] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:40 <hostname> kernel: [ 4114.176527] lo: dev_put 2 dst_ifdown
Jan 11 16:49:41 <hostname> kernel: [ 4115.198945] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:41 <hostname> kernel: [ 4115.198949] lo: dev_put 2 dst_ifdown
Jan 11 16:49:42 <hostname> kernel: [ 4116.222927] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:42 <hostname> kernel: [ 4116.222931] lo: dev_put 2 dst_ifdown
Jan 11 16:49:43 <hostname> kernel: [ 4117.246894] lo: dev_hold 2 dst_ifdown
Jan 11 16:49:43 <hostname> kernel: [ 4117.246897] lo: dev_put 2 dst_ifdown

As a comparison, here are the calls when the issue didn't occur.

Jan 11 15:59:57 <hostname> kernel: [ 1131.509464] lo: dev_hold 1 rx_queue_add_kobject
Jan 11 15:59:57 <hostname> kernel: [ 1131.509477] lo: dev_hold 2 netdev_queue_add_kobject
Jan 11 15:59:57 <hostname> kernel: [ 1131.509480] lo: dev_hold 3 register_netdevice
Jan 11 15:59:57 <hostname> kernel: [ 1131.509483] lo: dev_hold 4 neigh_parms_alloc
Jan 11 15:59:57 <hostname> kernel: [ 1131.509485] lo: dev_hold 5 inetdev_init
Jan 11 15:59:57 <hostname> kernel: [ 1131.560173] lo: dev_hold 6 qdisc_alloc
Jan 11 15:59:57 <hostname> kernel: [ 1131.560203] lo: dev_hold 7 dev_get_by_index
Jan 11 15:59:57 <hostname> kernel: [ 1131.560210] lo: dev_hold 8 dev_get_by_index
Jan 11 15:59:57 <hostname> kernel: [ 1131.560217] lo: dev_hold 9 fib_check_nh
Jan 11 15:59:57 <hostname> kernel: [ 1131.560221] lo: dev_hold 10 fib_check_nh
Jan 11 15:59:57 <hostname> kernel: [ 1131.560228] lo: dev_hold 11 dev_get_by_index
Jan 11 15:59:57 <hostname> kernel: [ 1131.560234] lo: dev_hold 12 dev_get_by_index
Jan 11 15:59:57 <hostname> kernel: [ 1131.560237] lo: dev_hold 13 fib_check_nh
Jan 11 15:59:57 <hostname> kernel: [ 1131.560240] lo: dev_hold 14 fib_check_nh
Jan 11 15:59:57 <hostname> kernel: [ 1131.580072] lo: dev_put 14 free_fib_info_rcu
Jan 11 15:59:57 <hostname> kernel: [ 1131.580077] lo: dev_put 13 free_fib_info_rcu
Jan 11 15:59:57 <hostname> kernel: [ 1131.580079] lo: dev_put 12 free_fib_info_rcu
Jan 11 15:59:57 <hostname> kernel: [ 1131.580081] lo: dev_put 11 free_fib_info_rcu
Jan 11 15:59:57 <hostname> kernel: [ 1131.580084] lo: dev_put 10 free_fib_info_rcu
Jan 11 15:59:57 <hostname> kernel: [ 1131.580097] lo: dev_put 9 free_fib_info_rcu
Jan 11 16:00:00 <hostname> kernel: [ 1134.594026] lo: dev_hold 9 dst_init
Jan 11 16:00:01 <hostname> kernel: [ 1135.020297] lo: dev_hold 10 dst_init
Jan 11 16:00:01 <hostname> kernel: [ 1135.020304] lo: dev_hold 11 dst_init
Jan 11 16:00:01 <hostname> kernel: [ 1135.039974] lo: dev_put 11 dst_destroy
Jan 11 16:00:02 <hostname> kernel: [ 1136.453739] lo: dev_hold 11 dst_init
Jan 11 16:10:03 <hostname> kernel: [ 1736.603352] lo: dev_hold 12 dst_init
Jan 11 16:10:03 <hostname> kernel: [ 1736.603374] lo: dev_hold 13 __neigh_create
Jan 11 16:11:01 <hostname> kernel: [ 1795.209103] lo: dev_hold 14 dst_init
Jan 11 16:11:26 <hostname> kernel: [ 1820.491721] lo: dev_hold 15 dst_init
Jan 11 16:11:31 <hostname> kernel: [ 1825.519853] lo: dev_hold 16 dst_init
Jan 11 16:12:08 <hostname> kernel: [ 1861.911872] lo: dev_hold 17 dst_init
Jan 11 16:12:10 <hostname> kernel: [ 1864.509095] lo: dev_hold 18 dst_init
Jan 11 16:12:11 <hostname> kernel: [ 1865.094510] lo: dev_hold 19 dst_init
Jan 11 16:12:11 <hostname> kernel: [ 1865.510777] lo: dev_hold 20 dst_init
Jan 11 16:12:12 <hostname> kernel: [ 1865.994909] lo: dev_hold 21 dst_init
Jan 11 16:12:13 <hostname> kernel: [ 1866.861904] lo: dev_hold 22 dst_init
Jan 11 16:12:13 <hostname> kernel: [ 1867.195370] lo: dev_hold 23 dst_init
Jan 11 16:12:14 <hostname> kernel: [ 1868.167117] lo: dev_hold 24 dst_init
Jan 11 16:12:48 <hostname> kernel: [ 1902.280896] lo: dev_hold 25 dst_ifdown
Jan 11 16:12:49 <hostname> kernel: [ 1902.960852] lo: dev_put 25 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.413561] lo: dev_put 24 neigh_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.415441] lo: dev_put 23 qdisc_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.415476] lo: dev_put 22 neigh_parms_release
Jan 11 16:14:59 <hostname> kernel: [ 2033.415508] lo: dev_put 21 rx_queue_release
Jan 11 16:14:59 <hostname> kernel: [ 2033.415518] lo: dev_put 20 netdev_queue_release
Jan 11 16:14:59 <hostname> kernel: [ 2033.415563] lo: dev_put 19 rollback_registered_many
Jan 11 16:14:59 <hostname> kernel: [ 2033.425510] lo: dev_put 18 free_fib_info_rcu
Jan 11 16:14:59 <hostname> kernel: [ 2033.429481] lo: dev_put 17 free_fib_info_rcu
Jan 11 16:14:59 <hostname> kernel: [ 2033.429499] lo: dev_put 16 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429507] lo: dev_put 15 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429509] lo: dev_put 14 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429511] lo: dev_put 13 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429513] lo: dev_put 12 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429515] lo: dev_put 11 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429517] lo: dev_put 10 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429519] lo: dev_put 9 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429523] lo: dev_put 8 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429529] lo: dev_put 7 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429536] lo: dev_put 6 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429541] lo: dev_put 5 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429543] lo: dev_put 4 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429545] lo: dev_put 3 dst_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429551] lo: dev_put 2 in_dev_finish_destroy
Jan 11 16:14:59 <hostname> kernel: [ 2033.429563] lo: dev_hold 2 dst_ifdown
Jan 11 16:14:59 <hostname> kernel: [ 2033.429565] lo: dev_put 2 dst_ifdown
Jan 11 16:15:00 <hostname> kernel: [ 2034.453484] lo: dev_hold 2 dst_ifdown
Jan 11 16:15:00 <hostname> kernel: [ 2034.453487] lo: dev_put 2 dst_ifdown
Jan 11 16:15:01 <hostname> kernel: [ 2035.129452] lo: dev_put 1 dst_destroy

Could you please give me some pointers why this issue could occur? I can
also provide addtional information if needed.

Thanks,
Kaiwen
