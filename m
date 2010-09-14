From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 0/1] macvtap TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 08:15:56 -0700
Message-ID: <1284477356.13351.46.camel@localhost.localdomain>
References: <1284410580.13351.10.camel@localhost.localdomain>
	 <20100914120545.GC703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:49898 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555Ab0INPQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 11:16:03 -0400
In-Reply-To: <20100914120545.GC703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Miachel,

On Tue, 2010-09-14 at 14:05 +0200, Michael S. Tsirkin wrote:
> While others pointed out correctness issues with the patch,
> I would still like to see the performance numbers, just so we
> understand what's possible.

The performance looks good, it either saves the host CPU utilization the
guest is running on (by 8-10% in 8 cpus) or gain high BW w/i more guest
CPU utilization when host utilization is similar or less than before.
And I run 32 netperf instants and didn't hit any problem.

Here are output from host perf top: (I am upgrading my guest to most
recent kernel now to collect perf top data.) My guest has 2 vcpus, host
has 8 cpus.

Please let me know what performance data you would like to see. I will
run more

w/o zero copy patch:

-----------------------------------------------------------------------------------------------------------------------------------------------------------
   PerfTop:    1708 irqs/sec  kernel:63.7%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-----------------------------------------------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                     DSO
             _______ _____ ____________________________ __________________________________________________________

             6842.00 47.4% copy_user_generic_string     /lib/modules/2.6.36-rc3+/build/vmlinux
              329.00  2.3% get_page_from_freelist       /lib/modules/2.6.36-rc3+/build/vmlinux
              307.00  2.1% list_del                     /lib/modules/2.6.36-rc3+/build/vmlinux
              289.00  2.0% alloc_pages_current          /lib/modules/2.6.36-rc3+/build/vmlinux
              283.00  2.0% __alloc_pages_nodemask       /lib/modules/2.6.36-rc3+/build/vmlinux
              234.00  1.6% ixgbe_xmit_frame             /lib/modules/2.6.36-rc3+/kernel/drivers/net/ixgbe/ixgbe.ko
              232.00  1.6% vmx_vcpu_run                 /lib/modules/2.6.36-rc3+/kernel/arch/x86/kvm/kvm-intel.ko
              210.00  1.5% schedule                     /lib/modules/2.6.36-rc3+/build/vmlinux
              173.00  1.2% _cond_resched                /lib/modules/2.6.36-rc3+/build/vmlinux


w/i zero copy patch:

-------------------------------------------------------------------------------
   PerfTop:    1108 irqs/sec  kernel:43.0%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                 DSO
             _______ _____ ________________________ ___________

              281.00  5.1% copy_user_generic_string [kernel]
              235.00  4.3% vmx_vcpu_run             [kvm_intel]
              228.00  4.1% gup_pte_range            [kernel]
              211.00  3.8% tg_shares_up             [kernel]
              179.00  3.2% schedule                 [kernel]
              148.00  2.7% _raw_spin_lock_irqsave   [kernel]
              139.00  2.5% iommu_no_mapping         [kernel]
              124.00  2.2% ixgbe_xmit_frame         [ixgbe]
              123.00  2.2% kvm_arch_vcpu_ioctl_run  [kvm]
              122.00  2.2% _raw_spin_lock           [kernel]
              113.00  2.1% put_page                 [kernel]
               92.00  1.7% vhost_get_vq_desc        [vhost_net]
               81.00  1.5% get_user_pages_fast      [kernel]
               81.00  1.5% memcpy_fromiovec         [kernel]
               80.00  1.5% translate_desc           [vhost_net]

w/i zero copy patch, and NIC IRQ cpu affinity (netper/netserver on cpu 0, interrupts on cpu1)

[root@localhost ~]# netperf -H 10.0.4.74 -c -C -l 60 -T0,0 -- -m 65536
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.4.74 (10.0.4.74) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  65536    60.00      9384.25   53.92    13.62    0.941   0.951
[root@localhost ~]#






