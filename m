From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: [RFC] igmp: address pmc kmemleak from on igmpv3_del_delrec()
Date: Fri,  3 Feb 2017 13:20:47 -0800
Message-ID: <20170203212047.31653-1-mcgrof@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Luis R. Rodriguez" <mcgrof@kernel.org>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we igmpv3_add_delrec() we kzalloc the pmc, but when users
call    igmpv3_del_delrec() we never free the pmc. This was caught
by the following kmemleak splat:

unreferenced object 0xffff99666ff43b40 (size 192):
  comm "systemd-resolve", pid 1258, jiffies 4309905600 (age 2138.352s)
  hex dump (first 32 bytes):
    00 6a 64 72 66 99 ff ff e0 00 00 fc 00 00 00 00  .jdrf...........
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffffb3a5f7ea>] kmemleak_alloc+0x4a/0xa0
    [<ffffffffb36044e7>] kmem_cache_alloc_trace+0x107/0x240
    [<ffffffffb39ddbed>] igmp_group_dropped+0xfd/0x270
    [<ffffffffb39de5cf>] ip_mc_dec_group+0xaf/0x110
    [<ffffffffb39de6e6>] ip_mc_leave_group+0xb6/0x140
    [<ffffffffb39a55d7>] do_ip_setsockopt.isra.13+0x4c7/0xed0
    [<ffffffffb39a6014>] ip_setsockopt+0x34/0xb0
    [<ffffffffb39ced9b>] udp_setsockopt+0x1b/0x30
    [<ffffffffb393f064>] sock_common_setsockopt+0x14/0x20
    [<ffffffffb393dd10>] SyS_setsockopt+0x80/0xe0
    [<ffffffffb3403b4b>] do_syscall_64+0x5b/0xc0
    [<ffffffffb3a6b3af>] return_from_SYSCALL_64+0x0/0x6a
    [<ffffffffffffffff>] 0xffffffffffffffff

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---

I can reproduce this over time on a qemu box running next-20170125.
After running this for a while I no longer see the splat. This needs
confirmation form folks more familiar with the code, hence RFC. If
this is a real fix we need appropriate tags for the patch.

 net/ipv4/igmp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 5b15459955f8..44fd86de2823 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1172,6 +1172,7 @@ static void igmpv3_del_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 				psf->sf_crcount = im->crcount;
 		}
 		in_dev_put(pmc->interface);
+		kfree(pmc);
 	}
 	spin_unlock_bh(&im->lock);
 }
-- 
2.11.0
