From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 18 Sep 2012 15:21:37 +0100
Message-ID: <50588371.40103@googlemail.com>
References: <5057455A.7050108@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61352 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab2IROV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 10:21:29 -0400
Received: by bkwj10 with SMTP id j10so3184958bkw.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 07:21:28 -0700 (PDT)
In-Reply-To: <5057455A.7050108@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/17/12 16:44, Chris Clayton wrote:
> Hi,
>
> I'm having a problem with networking. I'm running Windows XP as a KVM
> guest on a laptop running kernel 3.6.0-rc6. The identical configuration
> works fine with kernels 3.5.4 and 3.4.11 (and has done so, largely
> unchanged, since since KVM was introduced in 2.6.<whatever>.)
>
> The configuration is:
>
> XP guest:    192.168.200.1 (gateway 192.168.200.254)
> tap0:        192.168.200.254
> host:        192.168.0.40 (gateway 192.168.0.1)
> router:        192.168.0.1
>
> The script that starts up the firewall includes the following commands:
>
> # Load the connection-sharing for qemu/kvm guests
> echo 1 > /proc/sys/net/ipv4/ip_forward
> iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
> ...
> # allow traffic to and from the qemu/kvm virtual networks
> NETS="200 201"
> for net in $NETS; do
>    iptables -A INPUT -s 192.168.$net.0/24 -j ACCEPT
>    iptables -A OUTPUT -d 192.168.$net.0/24 -j ACCEPT
> done
> ...
>
> The network-related modules that are loaded are:
>
> $ lsmod
> Module                  Size  Used by
> tun                    12412  0
> xt_state                 891  1
> iptable_filter           852  1
> ipt_MASQUERADE          1222  1
> iptable_nat             3087  1
> nf_nat                 10901  2 ipt_MASQUERADE,iptable_nat
> nf_conntrack_ipv4       4942  4 nf_nat,iptable_nat
> nf_defrag_ipv4           815  1 nf_conntrack_ipv4
> nf_conntrack           37644  5
> ipt_MASQUERADE,nf_nat,xt_state,iptable_nat,nf_conntrack_ipv4
> ...
> r8169                  47159  0
>
>  From the host I can successfully ping the guest, tap0 and the router as
> you would expect, but from the guest, although I can ping the host and
> tap0, I cannot ping the router. In practice, this means I have no
> internet access from the guest. As I say, this configuration works
> perfectly under 3.5.x and 3.4.x kernels.
>
> I'll do a coarse-grained "bisect" of Linus' 3.6 release candidates and
> report back, but does anyone have any prime-suspect patches that may be
> at the cause of this problem?
>

-rc1 turned out to have the problem so I've bisected between 3.5 and 
3.6-rc1. I arrived at:

$ git bisect bad
d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5 is the first bad commit
commit d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Jul 17 12:58:50 2012 -0700

     ipv4: Cache input routes in fib_info nexthops.

     Caching input routes is slightly simpler than output routes, since we
     don't need to be concerned with nexthop exceptions.  (locally
     destined, and routed packets, never trigger PMTU events or redirects
     that will be processed by us).

     However, we have to elide caching for the DIRECTSRC and non-zero itag
     cases.

     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 6bbc75c1cbe62bf84ea412d3b98adf2b614779cd 
3ad7256b4a71e63ca4530977c0550121ea803d35 M      include
:040000 040000 18c2a950a53c4eec9bfa12185d1e382dfed74af8 
a2ab6157d6cd54930da395758c6ded3a225d1f04 M      net

The bisect log:
git bisect start
# bad: [0d7614f09c1ebdbaa1599a5aba7593f147bf96ee] Linux 3.6-rc1
git bisect bad 0d7614f09c1ebdbaa1599a5aba7593f147bf96ee
# good: [28a33cbc24e4256c143dce96c7d93bf423229f92] Linux 3.5
git bisect good 28a33cbc24e4256c143dce96c7d93bf423229f92
# bad: [614a6d4341b3760ca98a1c2c09141b71db5d1e90] Merge branch 'for-3.6' 
of git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup
git bisect bad 614a6d4341b3760ca98a1c2c09141b71db5d1e90
# bad: [320f5ea0cedc08ef65d67e056bcb9d181386ef2c] genetlink: define 
lockdep_genl_is_held() when CONFIG_LOCKDEP
git bisect bad 320f5ea0cedc08ef65d67e056bcb9d181386ef2c
# good: [0cd06647b7c24f6633e32a505930a9aa70138c22] Merge branch 'master' 
of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next
git bisect good 0cd06647b7c24f6633e32a505930a9aa70138c22
# good: [dbfa600148a25903976910863c75dae185f8d187] cxgb3: set maximal 
number of default RSS queues
git bisect good dbfa600148a25903976910863c75dae185f8d187
# good: [efdfad3205403e1d1c5c0bdcbdb647ddd89bfaa3] bnx2: Try to recover 
from PCI block reset
git bisect good efdfad3205403e1d1c5c0bdcbdb647ddd89bfaa3
# good: [1bf91cdc1bba94ea062a9147d924815c13f029f2] ixgbe: Drop 
references to deprecated pci_ DMA api and instead use dma_ API
git bisect good 1bf91cdc1bba94ea062a9147d924815c13f029f2
# good: [b6dfd939fdc249fcf8cd7b8006f76239b33eb581] ixgbe: add support 
for new 82599 device
git bisect good b6dfd939fdc249fcf8cd7b8006f76239b33eb581
# good: [3ba97381343b271296487bf073eb670d5465a8b8] net: ethernet: 
davinci_emac: add pm_runtime support
git bisect good 3ba97381343b271296487bf073eb670d5465a8b8
# bad: [5e9965c15ba88319500284e590733f4a4629a288] Merge branch 
'kill_rtcache'
git bisect bad 5e9965c15ba88319500284e590733f4a4629a288
# good: [f5b0a8743601a4477419171f5046bd07d1c080a0] net: Document 
dst->obsolete better.
git bisect good f5b0a8743601a4477419171f5046bd07d1c080a0
# bad: [ba3f7f04ef2b19aace38f855aedd17fe43035d50] ipv4: Kill 
FLOWI_FLAG_RT_NOCACHE and associated code.
git bisect bad ba3f7f04ef2b19aace38f855aedd17fe43035d50
# good: [f2bb4bedf35d5167a073dcdddf16543f351ef3ae] ipv4: Cache output 
routes in fib_info nexthops.
git bisect good f2bb4bedf35d5167a073dcdddf16543f351ef3ae
# bad: [d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5] ipv4: Cache input 
routes in fib_info nexthops.
git bisect bad d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5

Checking out the parent commit 
(f2bb4bedf35d5167a073dcdddf16543f351ef3ae) and building and installing 
the kernel gives a working configuration, so I'm pretty confident in the 
outcome of the bisect. Reversing the patch gives errors, so I've not 
tested master with the patch reversed.

Let me know if I can help in any way to identify a fix.

Chris

> Let me know if there are any other diagnostics I can provide. Also, as
> I'm not subscribed to netdev, please cc me to any reply.
>
> Thanks,
>
> Chris
