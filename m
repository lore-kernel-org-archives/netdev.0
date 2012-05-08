From: Mike Galbraith <mgalbraith@suse.de>
Subject: qlge driver corrupting kernel memory
Date: Tue, 08 May 2012 13:00:18 +0200
Message-ID: <1336474818.21924.94.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35508 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895Ab2EHLAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 07:00:21 -0400
Received: from relay2.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id A97459BA06
	for <netdev@vger.kernel.org>; Tue,  8 May 2012 13:00:20 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings network wizards,

$subject is happening in an 2.6.32 enterprise kernel with the driver
updated to what looks to me to be 2.6.38 or so.

Allegedly, IFF boxen are running dual CNAs with storage and LAN sharing
a port, $subject happens fairly regularly.  Rummaging in crashdumps
seems to show corruption happens because we somehow end up stuffing
loads of frags into skb_shared_info, scribbling all over the place.

Before I proceed, what I know about skbs can be found here..

    http://vger.kernel.org/~davem/skb_data.html

..and that's the sum and total ;-)

I guess the first thing I should ask is whether anyone has seen such
scribbling with this driver.  Known issue would be a case of happiness,
but I doubt that will be the case from searching, so onward.

I've seen a few of these:

crash> struct sk_buff ffff88104b19d480
struct sk_buff {
  next = 0x0, 
  prev = 0x0, 
  sk = 0x0, 
  tstamp = {
    tv64 = 0
  }, 
  dev = 0xffff882040d98000, 
  _skb_dst = 0, 
  sp = 0x0, 
  cb = "\000 \033B
\210\377\377.\001\000\000\016\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
  len = 3025951, 
  data_len = 3025951,  <== size XXXL 
  mac_len = 14, 
  hdr_len = 0, 
  {
    csum = 0, 
    {
      csum_start = 0, 
      csum_offset = 0
    }
  }, 
...
 transport_header = 16, 
  network_header = 16, 
  mac_header = 2, 
  tail = 16, 
  end = 384, 
  head = 0xffff8810501ed000 "", 
  data = 0xffff8810501ed010 "", 
  truesize = 3026581, 
  users = {
    counter = 1
  }
crash> struct skb_shared_info 0xffff8810501ed180
struct skb_shared_info {
  dataref = {
    counter = 1
  }, 
  nr_frags = 4788, 
  gso_size = 0, 
  dma_head = 0, 
  gso_segs = 0, 
  gso_type = 0, 
  ip6_frag_id = 0, 
  tx_flags = {
    {
      hardware = 0 '\000', 
      software = 0 '\000', 
      in_progress = 0 '\000'
    }, 
    flags = 0 '\000'
  }, 
  frag_list = 0x0, 
  hwtstamps = {
    hwtstamp = {
      tv64 = 0
    }, 
    syststamp = {
      tv64 = 0
    }
  }, 
  frags = {{
      page = 0xffffea0070e75ef0, 
      page_offset = 14, 
      size = 288
    }, {
...
     page = 0xffffea0071bb80f0, 
      page_offset = 0, 
      size = 302
    }, {
      page = 0xffffea0071bb80f0, 
      page_offset = 2048, 
      size = 974
    }}, 
  dma_maps = {18446719886361854248, 4561255268352,....

Looking at dma_maps[] as being overwritten with skb_frag_struct data:

dma_maps[0] = page 0xffffea0071bb8128 page_offset 0    size 1026
dma_maps[1] = page 0xffffea0071bb8128 page_offset 2048 size 1454
dma_maps[2] = page 0xffffea0070e6f4a0 page_offset 0    size 1222
dma_maps[3] = page 0xffffea0070e6f4a0 page_offset 2048 size 302

Looks to me like we really are zipping past 18 frags somehow.

crash> dis ffffffff812ee2a7
0xffffffff812ee2a7 <skb_release_data+199>:      mov    0xcc(%rbp),%edx
crash> gdb list *skb_release_data+199
0xffffffff812ee2a7 is in skb_release_data
(/usr/src/debug/kernel-default-2.6.32.54/linux-2.6.32/net/core/skbuff.c:402).
397                 !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) +
1 : 1,
398                                    &skb_shinfo(skb)->dataref)) {
399     
400                     if (skb_shinfo(skb)->nr_frags) {
401                             int i;
402                             for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
{
403                                     skb_put_page(skb,
404                                                 
skb_shinfo(skb)->frags[i].page);
405                             }
406                     }

crash> gdb list *ql_build_rx_skb+1109
0xffffffffa0297705 is in ql_build_rx_skb
(/usr/src/debug/kernel-default-2.6.32.54/linux-2.6.32/include/linux/skbuff.h:1093).
1088            skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
1089    
1090            frag->page                = page;
1091            frag->page_offset         = off;
1092            frag->size                = size;
1093            skb_shinfo(skb)->nr_frags = i + 1;
1094    }
1095    
1096    extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page
*page,
1097

One skb_fill_page_desc() in the xmit path would certainly do evil if
nr_frags was nutty.

Question: when changing mtu, we schedule delayed work for 3 seconds from
now, but diddle ndev->mtu whether the device is busy or not, so what
prevents ndev->mtu from changing while interrupt is being handled?  I
ask because I saw the below.

crash> bt
PID: 0      TASK: ffffffff8180c020  CPU: 0   COMMAND: "swapper"
 #0 [ffff880028203a90] machine_kexec at ffffffff81020a62
 #1 [ffff880028203ae0] crash_kexec at ffffffff81088780
 #2 [ffff880028203bb0] oops_end at ffffffff8139efe0
 #3 [ffff880028203bd0] general_protection at ffffffff8139e22f
 #4 [ffff880028203c58] put_page at ffffffff810c0ef5
 #5 [ffff880028203cb8] skb_release_data at ffffffff812ee2a7
 #6 [ffff880028203cd8] __kfree_skb at ffffffff812edd29
 #7 [ffff880028203ce8] ip_rcv at ffffffff81323117
 #8 [ffff880028203d18] netif_receive_skb at ffffffff812f82e9
 #9 [ffff880028203d88] ql_process_mac_rx_page at ffffffffa0296918
#10 [ffff880028203dd8] __wake_up_common at ffffffff8103807a
#11 [ffff880028203e18] ql_build_rx_skb at ffffffffa0297405
#12 [ffff880028203ee8] __do_softirq at ffffffff810545af
#13 [ffff880028203f38] call_softirq at ffffffff810040bc
#14 [ffff880028203f50] do_softirq at ffffffff81005cfd
#15 [ffff880028203f70] irq_exit at ffffffff81054435
#16 [ffff880028203f80] do_IRQ at ffffffff8100525e
--- <IRQ stack> ---
#17 [ffffffff81801e78] ret_from_intr at ffffffff81003913
    [exception RIP: acpi_idle_enter_c1+138]
    RIP: ffffffffa00ec0eb  RSP: ffffffff81801f28  RFLAGS: 00000202
    RAX: 0000000000000000  RBX: ffff88107b9774a0  RCX: 0000000000000000
    RDX: 0000000000000054  RSI: 0000000000000000  RDI: 000000000001482b
    RBP: ffffffff8100390e   R8: ffffffff81801fd8   R9: 0000000000000003
    R10: 0000000000000000  R11: ffffffff812d6520  R12: 0000000000000000
    R13: 0000000000000000  R14: ffffffff81072ef8  R15: 0000000000000092
    ORIG_RAX: ffffffffffffffbb  CS: 0010  SS: 0018
#18 [ffffffff81801f60] cpuidle_idle_call at ffffffff812d576a
#19 [ffffffff81801f80] cpu_idle at ffffffff8100204a

Note wakeup and ql_process_mac_rx_page in above.

crash> gdb list *0xffffffffa0296918
0xffffffffa0296918 is in qlge_change_mtu
(/usr/src/debug/kernel-default-2.6.32.54/linux-2.6.32/include/linux/kobject.h:81).
76      extern int kobject_set_name_vargs(struct kobject *kobj, const char
*fmt,
77                                        va_list vargs);
78      
79      static inline const char *kobject_name(const struct kobject *kobj)
80      {
81              return kobj->name;
82      }
83      
84      extern void kobject_init(struct kobject *kobj, struct kobj_type
*ktype);
85      extern int __must_check kobject_add(struct kobject *kobj,
crash> gdb list *0xffffffffa0296910
0xffffffffa0296910 is in qlge_change_mtu
(/usr/src/debug/kernel-default-2.6.32.54/linux-2.6.32/drivers/net/qlge/qlge_main.c:4112).
4107            int status;
4108    
4109            if (ndev->mtu == 1500 && new_mtu == 9000) {
4110                    QPRINTK(qdev, IFUP, ERR, "Changing to jumbo MTU.\n");
4111            } else if (ndev->mtu == 9000 && new_mtu == 1500) {
4112                    QPRINTK(qdev, IFUP, ERR, "Changing to normal MTU.\n");
4113            } else if ((ndev->mtu == 1500 && new_mtu == 1500) ||
4114                       (ndev->mtu == 9000 && new_mtu == 9000)) {
4115                    return 0;
4116            } else
crash>

	-Mike
