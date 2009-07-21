From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: [Qemu-devel] [PATCH] net: add raw backend  - some performance
 measurements
Date: Tue, 21 Jul 2009 13:17:21 +0300
Message-ID: <4A6595B1.4070806@Voltaire.com>
References: <20090701162115.GA4555@shareable.org>	<4A4CA747.1050509@Voltaire.com> <20090703023911.GD938@shareable.org>	<4A534EC4.5030209@voltaire.com> <20090707145739.GB14392@shareable.org>	<4A54B0F1.3070201@voltaire.com> <20090715203806.GF3056@shareable.org>	<4A647B72.5090404@Voltaire.com> <20090720155308.GA9327@gondor.apana.org.au>	<4A656824.7070100@Voltaire.com> <20090721072546.GA16131@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
	Jan Kiszka <jan.kiszka@web.de>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Mark McLoughlin <markmc@redhat.com>,
	Dor Laor <dlaor@redhat.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:29900 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754710AbZGUKRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 06:17:32 -0400
In-Reply-To: <20090721072546.GA16131@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> I find this hard to believe this bridge sans netfilter does a single lookup based 
> on the MAC address and then just passes the packet to the underlying driver.
> Can you do an oprofile run to see if something else is chewing
> up CPU time under the guise of bridging?

okay, here are the top twenty time consumers for the three VM TX modes, the bridge code 
is not anywhere high... I'll send you the complete oprofile logs.

Or.

VM TX with the raw mode -->

samples  %        image name               app name                 symbol name
697453   25.2468  kvm-intel.ko             kvm_intel                vmx_vcpu_run
105024    3.8017  vmlinux                  vmlinux                  _raw_spin_lock
95443     3.4549  igb.ko                   igb                      igb_xmit_frame_adv
68617     2.4838  vmlinux                  vmlinux                  __slab_free
68168     2.4676  qemu-system-x86_64       qemu-system-x86_64       cpu_physical_memory_rw
56272     2.0370  vmlinux                  vmlinux                  tg_shares_up
48573     1.7583  igb.ko                   igb                      igb_clean_tx_irq
46128     1.6698  libc-2.5.so              libc-2.5.so              memcpy
44371     1.6062  vmlinux                  vmlinux                  kmem_cache_alloc
41485     1.5017  vmlinux                  vmlinux                  __alloc_skb
38719     1.4016  qemu-system-x86_64       qemu-system-x86_64       phys_page_find_alloc
38016     1.3761  vmlinux                  vmlinux                  copy_user_generic_string
37690     1.3643  qemu-system-x86_64       qemu-system-x86_64       qemu_get_ram_ptr
34321     1.2424  vmlinux                  vmlinux                  dev_kfree_skb_irq
34313     1.2421  vmlinux                  vmlinux                  __kmalloc_track_caller
28726     1.0398  vmlinux                  vmlinux                  sock_alloc_send_pskb
25195     0.9120  vmlinux                  vmlinux                  kfree
24790     0.8974  vmlinux                  vmlinux                  __slab_alloc
23406     0.8473  vmlinux                  vmlinux                  dev_queue_xmit

VM TX with the tap/bridge+netfilter OFF mode -->

samples  %        image name               app name                 symbol name
447119   21.5219  kvm-intel.ko             kvm_intel                vmx_vcpu_run
70774     3.4067  igb.ko                   igb                      igb_xmit_frame_adv
66324     3.1925  vmlinux                  vmlinux                  _raw_spin_lock
53817     2.5905  vmlinux                  vmlinux                  __slab_free
47494     2.2861  vmlinux                  vmlinux                  tg_shares_up
47213     2.2726  qemu-system-x86_64       qemu-system-x86_64       cpu_physical_memory_rw
40364     1.9429  igb.ko                   igb                      igb_clean_tx_irq
39545     1.9035  vmlinux                  vmlinux                  kmem_cache_alloc
36027     1.7341  libc-2.5.so              libc-2.5.so              memcpy
34945     1.6821  vmlinux                  vmlinux                  __alloc_skb
29747     1.4319  vmlinux                  vmlinux                  dev_kfree_skb_irq
29145     1.4029  vmlinux                  vmlinux                  __kmalloc_track_caller
28680     1.3805  vmlinux                  vmlinux                  copy_user_generic_string
26251     1.2636  qemu-system-x86_64       qemu-system-x86_64       phys_page_find_alloc
25123     1.2093  qemu-system-x86_64       qemu-system-x86_64       qemu_get_ram_ptr
23231     1.1182  vmlinux                  vmlinux                  eth_type_trans
22356     1.0761  vmlinux                  vmlinux                  sock_alloc_send_pskb
22108     1.0642  vmlinux                  vmlinux                  __slab_alloc
21288     1.0247  vmlinux                  vmlinux                  kfree

VM TX with the tap/bridge+netfilter ON mode -->

samples  %        image name               app name                 symbol name
319271   21.1411  kvm-intel.ko             kvm_intel                vmx_vcpu_run
46559     3.0830  vmlinux                  vmlinux                  _raw_spin_lock
39703     2.6290  vmlinux                  vmlinux                  tg_shares_up
35773     2.3688  vmlinux                  vmlinux                  __slab_free
35045     2.3206  qemu-system-x86_64       qemu-system-x86_64       cpu_physical_memory_rw
32612     2.1595  igb.ko                   igb                      igb_xmit_frame_adv
31779     2.1043  vmlinux                  vmlinux                  kmem_cache_alloc
29134     1.9292  libc-2.5.so              libc-2.5.so              memcpy
23031     1.5250  vmlinux                  vmlinux                  copy_user_generic_string
19713     1.3053  vmlinux                  vmlinux                  __kmalloc_track_caller
19303     1.2782  qemu-system-x86_64       qemu-system-x86_64       phys_page_find_alloc
19038     1.2606  vmlinux                  vmlinux                  __alloc_skb
18559     1.2289  vmlinux                  vmlinux                  kfree
18460     1.2224  qemu-system-x86_64       qemu-system-x86_64       qemu_get_ram_ptr
18409     1.2190  vmlinux                  vmlinux                  eth_type_trans
17828     1.1805  igb.ko                   igb                      igb_clean_tx_irq
17622     1.1669  igb.ko                   igb                      igb_poll
17303     1.1457  vmlinux                  vmlinux                  __slab_alloc
17033     1.1279  vmlinux                  vmlinux                  dev_kfree_skb_irq
