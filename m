From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195647] New: Slab corruption with network packet poison
 data
Date: Wed, 3 May 2017 15:54:54 -0700
Message-ID: <20170503155454.3ae7df69@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35334 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751151AbdECWzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 18:55:04 -0400
Received: by mail-pg0-f54.google.com with SMTP id o3so1898015pgn.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 15:55:03 -0700 (PDT)
Received: from xeon-e3 (76-14-206-252.or.wavecable.com. [76.14.206.252])
        by smtp.gmail.com with ESMTPSA id l186sm296491pgd.42.2017.05.03.15.55.01
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 May 2017 15:55:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 03 May 2017 13:37:39 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195647] New: Slab corruption with network packet poison data


https://bugzilla.kernel.org/show_bug.cgi?id=195647

            Bug ID: 195647
           Summary: Slab corruption with network packet poison data
           Product: Networking
           Version: 2.5
    Kernel Version: 4.11.0-rc8+
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: imre.deak@intel.com
        Regression: No

Created attachment 256177
  --> https://bugzilla.kernel.org/attachment.cgi?id=256177&action=edit  
dmesg

During CI testing on a KBL machine we got the slab corruption below. Not sure
if it's really a network problem or which part of the network stack it would
originate from.

I attached the full dmesg. The poison data without the first 4 bytes looks like
an Ethernet packet containing a DHCP ACK message shown as such by WireShark if
imported as a hex dump.

[  536.637685]
=============================================================================
[  536.637703] BUG kmalloc-4096 (Tainted: G     U  W      ): Poison overwritten
[  536.637714]
-----------------------------------------------------------------------------

[  536.637730] Disabling lock debugging due to kernel taint
[  536.637731] INFO: 0xffff880264921198-0xffff8802649212f1. First byte 0x56
instead of 0x6b
[  536.637740] INFO: Allocated in kernfs_iop_get_link+0x3e/0x1e0 age=4142 cpu=2
pid=9676
[  536.637748]  ___slab_alloc.constprop.28+0x38f/0x3d0
[  536.637753]  __slab_alloc.isra.22.constprop.27+0x43/0x80
[  536.637758]  kmem_cache_alloc_trace+0x237/0x2e0
[  536.637762]  kernfs_iop_get_link+0x3e/0x1e0
[  536.637768]  trailing_symlink+0x1e5/0x230
[  536.637772]  path_lookupat+0x5b/0x100
[  536.637776]  filename_lookup+0xa0/0x120
[  536.637781]  user_path_at_empty+0x31/0x40
[  536.637785]  SyS_faccessat+0xa6/0x210
[  536.637789]  SyS_access+0x13/0x20
[  536.637793]  entry_SYSCALL_64_fastpath+0x1c/0xb1
[  536.637799] INFO: Freed in kfree_link+0x9/0x10 age=4142 cpu=2 pid=9676
[  536.637804]  __slab_free+0x3cb/0x580
[  536.637808]  kfree+0x266/0x2e0
[  536.637812]  kfree_link+0x9/0x10
[  536.637816]  walk_component+0xc4/0x2d0
[  536.637820]  path_lookupat+0x4f/0x100
[  536.637824]  filename_lookup+0xa0/0x120
[  536.637828]  user_path_at_empty+0x31/0x40
[  536.637833]  SyS_faccessat+0xa6/0x210
[  536.637836]  SyS_access+0x13/0x20
[  536.637840]  entry_SYSCALL_64_fastpath+0x1c/0xb1
[  536.637846] INFO: Slab 0xffffea0009924800 objects=7 used=7 fp=0x         
(null) flags=0x8000000000008100
[  536.637854] INFO: Object 0xffff880264921158 @offset=4440
fp=0xffff8802649267e8

[  536.637863] Redzone ffff880264921150: bb bb bb bb bb bb bb bb               
          ........
[  536.637870] Object ffff880264921158: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.637877] Object ffff880264921168: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.637885] Object ffff880264921178: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.637892] Object ffff880264921188: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.637899] Object ffff880264921198: 56 01 a9 fe 00 10 60 31 d6 53 68 05 ca
2f 15 dd  V.....`1.Sh../..
[  536.637907] Object ffff8802649211a8: 08 00 45 10 01 48 00 00 00 00 80 11 b6
29 c0 a8  ..E..H.......)..
[  536.637914] Object ffff8802649211b8: 01 01 c0 a8 01 1a 00 43 00 44 01 34 2d
a0 02 01  .......C.D.4-...
[  536.637921] Object ffff8802649211c8: 06 00 bf be 60 1b 00 00 00 00 00 00 00
00 c0 a8  ....`...........
[  536.637929] Object ffff8802649211d8: 01 1a 00 00 00 00 00 00 00 00 00 10 60
31 d6 53  ............`1.S
[  536.637936] Object ffff8802649211e8: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637943] Object ffff8802649211f8: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637951] Object ffff880264921208: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637958] Object ffff880264921218: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637965] Object ffff880264921228: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637973] Object ffff880264921238: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637980] Object ffff880264921248: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637987] Object ffff880264921258: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.637995] Object ffff880264921268: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.638002] Object ffff880264921278: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.638009] Object ffff880264921288: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.638017] Object ffff880264921298: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00  ................
[  536.638024] Object ffff8802649212a8: 00 00 00 00 00 00 00 00 00 00 63 82 53
63 35 01  ..........c.Sc5.
[  536.638031] Object ffff8802649212b8: 05 36 04 c0 a8 01 01 33 04 00 00 0e 10
01 04 ff  .6.....3........
[  536.638039] Object ffff8802649212c8: ff ff 00 03 04 c0 a8 01 01 0f 0c 66 69
2e 69 6e  ...........fi.in
[  536.638046] Object ffff8802649212d8: 74 65 6c 2e 63 6f 6d 06 0c 0a f8 02 01
a3 21 fd  tel.com.......!.
[  536.638053] Object ffff8802649212e8: 4c 0a b8 09 09 ff 00 00 00 00 6b 6b 6b
6b 6b 6b  L.........kkkkkk
[  536.638061] Object ffff8802649212f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638068] Object ffff880264921308: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638075] Object ffff880264921318: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638083] Object ffff880264921328: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638090] Object ffff880264921338: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638097] Object ffff880264921348: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638105] Object ffff880264921358: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638112] Object ffff880264921368: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638119] Object ffff880264921378: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638127] Object ffff880264921388: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638134] Object ffff880264921398: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638141] Object ffff8802649213a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638149] Object ffff8802649213b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638156] Object ffff8802649213c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638163] Object ffff8802649213d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638171] Object ffff8802649213e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638178] Object ffff8802649213f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638186] Object ffff880264921408: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638193] Object ffff880264921418: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638200] Object ffff880264921428: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638208] Object ffff880264921438: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638215] Object ffff880264921448: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638222] Object ffff880264921458: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638229] Object ffff880264921468: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638237] Object ffff880264921478: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638244] Object ffff880264921488: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638252] Object ffff880264921498: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638259] Object ffff8802649214a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638266] Object ffff8802649214b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638274] Object ffff8802649214c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638281] Object ffff8802649214d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638288] Object ffff8802649214e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638296] Object ffff8802649214f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638303] Object ffff880264921508: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638310] Object ffff880264921518: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638318] Object ffff880264921528: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638325] Object ffff880264921538: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638332] Object ffff880264921548: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638340] Object ffff880264921558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638347] Object ffff880264921568: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638354] Object ffff880264921578: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638362] Object ffff880264921588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638369] Object ffff880264921598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638376] Object ffff8802649215a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638384] Object ffff8802649215b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638391] Object ffff8802649215c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638398] Object ffff8802649215d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638406] Object ffff8802649215e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638413] Object ffff8802649215f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638420] Object ffff880264921608: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638428] Object ffff880264921618: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638435] Object ffff880264921628: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638443] Object ffff880264921638: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638450] Object ffff880264921648: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638457] Object ffff880264921658: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638465] Object ffff880264921668: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638472] Object ffff880264921678: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638479] Object ffff880264921688: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638487] Object ffff880264921698: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638494] Object ffff8802649216a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638501] Object ffff8802649216b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638509] Object ffff8802649216c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638516] Object ffff8802649216d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638523] Object ffff8802649216e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638531] Object ffff8802649216f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638538] Object ffff880264921708: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638545] Object ffff880264921718: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638553] Object ffff880264921728: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638560] Object ffff880264921738: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638567] Object ffff880264921748: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638574] Object ffff880264921758: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638582] Object ffff880264921768: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638589] Object ffff880264921778: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638597] Object ffff880264921788: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638604] Object ffff880264921798: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638611] Object ffff8802649217a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638619] Object ffff8802649217b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638626] Object ffff8802649217c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638633] Object ffff8802649217d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638640] Object ffff8802649217e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638648] Object ffff8802649217f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638655] Object ffff880264921808: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638662] Object ffff880264921818: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638670] Object ffff880264921828: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638677] Object ffff880264921838: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638684] Object ffff880264921848: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638692] Object ffff880264921858: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638699] Object ffff880264921868: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638707] Object ffff880264921878: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638714] Object ffff880264921888: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638721] Object ffff880264921898: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638729] Object ffff8802649218a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638736] Object ffff8802649218b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638760] Object ffff8802649218c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638768] Object ffff8802649218d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638775] Object ffff8802649218e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638783] Object ffff8802649218f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638790] Object ffff880264921908: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638798] Object ffff880264921918: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638820] Object ffff880264921928: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638827] Object ffff880264921938: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638834] Object ffff880264921948: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638842] Object ffff880264921958: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638849] Object ffff880264921968: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638857] Object ffff880264921978: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638864] Object ffff880264921988: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638871] Object ffff880264921998: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638879] Object ffff8802649219a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638886] Object ffff8802649219b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638893] Object ffff8802649219c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638901] Object ffff8802649219d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638908] Object ffff8802649219e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638915] Object ffff8802649219f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638923] Object ffff880264921a08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638930] Object ffff880264921a18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638937] Object ffff880264921a28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638945] Object ffff880264921a38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638952] Object ffff880264921a48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638959] Object ffff880264921a58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638967] Object ffff880264921a68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638974] Object ffff880264921a78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638981] Object ffff880264921a88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638988] Object ffff880264921a98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.638996] Object ffff880264921aa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639003] Object ffff880264921ab8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639010] Object ffff880264921ac8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639018] Object ffff880264921ad8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639025] Object ffff880264921ae8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639032] Object ffff880264921af8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639040] Object ffff880264921b08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639047] Object ffff880264921b18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639054] Object ffff880264921b28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639062] Object ffff880264921b38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639069] Object ffff880264921b48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639076] Object ffff880264921b58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639084] Object ffff880264921b68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639091] Object ffff880264921b78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639098] Object ffff880264921b88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639106] Object ffff880264921b98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639113] Object ffff880264921ba8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639120] Object ffff880264921bb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639128] Object ffff880264921bc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639135] Object ffff880264921bd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639142] Object ffff880264921be8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639150] Object ffff880264921bf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639157] Object ffff880264921c08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639164] Object ffff880264921c18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639172] Object ffff880264921c28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639179] Object ffff880264921c38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639186] Object ffff880264921c48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639194] Object ffff880264921c58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639201] Object ffff880264921c68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639208] Object ffff880264921c78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639216] Object ffff880264921c88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639223] Object ffff880264921c98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639230] Object ffff880264921ca8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639238] Object ffff880264921cb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639245] Object ffff880264921cc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639252] Object ffff880264921cd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639259] Object ffff880264921ce8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639267] Object ffff880264921cf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639274] Object ffff880264921d08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639282] Object ffff880264921d18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639289] Object ffff880264921d28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639296] Object ffff880264921d38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639304] Object ffff880264921d48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639311] Object ffff880264921d58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639318] Object ffff880264921d68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639325] Object ffff880264921d78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639333] Object ffff880264921d88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639340] Object ffff880264921d98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639347] Object ffff880264921da8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639355] Object ffff880264921db8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639362] Object ffff880264921dc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639369] Object ffff880264921dd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639377] Object ffff880264921de8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639384] Object ffff880264921df8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639391] Object ffff880264921e08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639399] Object ffff880264921e18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639406] Object ffff880264921e28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639413] Object ffff880264921e38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639421] Object ffff880264921e48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639428] Object ffff880264921e58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639435] Object ffff880264921e68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639443] Object ffff880264921e78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639450] Object ffff880264921e88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639457] Object ffff880264921e98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639465] Object ffff880264921ea8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639472] Object ffff880264921eb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639479] Object ffff880264921ec8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639487] Object ffff880264921ed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639494] Object ffff880264921ee8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639501] Object ffff880264921ef8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639509] Object ffff880264921f08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639516] Object ffff880264921f18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639523] Object ffff880264921f28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639531] Object ffff880264921f38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639538] Object ffff880264921f48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639545] Object ffff880264921f58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639553] Object ffff880264921f68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639560] Object ffff880264921f78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639567] Object ffff880264921f88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639575] Object ffff880264921f98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639582] Object ffff880264921fa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639589] Object ffff880264921fb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639597] Object ffff880264921fc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639604] Object ffff880264921fd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639611] Object ffff880264921fe8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639619] Object ffff880264921ff8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639626] Object ffff880264922008: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639633] Object ffff880264922018: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639641] Object ffff880264922028: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639648] Object ffff880264922038: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639655] Object ffff880264922048: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639663] Object ffff880264922058: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639670] Object ffff880264922068: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639677] Object ffff880264922078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639685] Object ffff880264922088: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639692] Object ffff880264922098: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639699] Object ffff8802649220a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639707] Object ffff8802649220b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639714] Object ffff8802649220c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639721] Object ffff8802649220d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639729] Object ffff8802649220e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639736] Object ffff8802649220f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639760] Object ffff880264922108: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639768] Object ffff880264922118: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639790] Object ffff880264922128: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639797] Object ffff880264922138: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[  536.639804] Object ffff880264922148: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b a5  kkkkkkkkkkkkkkk.
[  536.639812] Redzone ffff880264922158: bb bb bb bb bb bb bb bb               
          ........
[  536.639819] Padding ffff880264922298: 5a 5a 5a 5a 5a 5a 5a 5a               
          ZZZZZZZZ
[  536.639826] CPU: 1 PID: 9693 Comm: kms_setmode Tainted: G    BU  W      
4.11.0-rc8-CI-Patchwork_4598+ #1
[  536.639827] Hardware name: Dell Inc. XPS 13 9360/093TW6, BIOS 1.3.2
01/18/2017
[  536.639828] Call Trace:
[  536.639831]  dump_stack+0x67/0x92
[  536.639832]  print_trailer+0x14b/0x230
[  536.639834]  check_bytes_and_report+0xc0/0x100
[  536.639835]  check_object+0x261/0x2b0
[  536.639855]  ? __pdp_init.isra.4+0x44/0x90 [i915]
[  536.639857]  alloc_debug_processing+0x199/0x1b0
[  536.639858]  ___slab_alloc.constprop.28+0x38f/0x3d0
[  536.639871]  ? __pdp_init.isra.4+0x44/0x90 [i915]
[  536.639872]  ? ___slab_alloc.constprop.28+0x2ab/0x3d0
[  536.639874]  ? ___slab_alloc.constprop.28+0x2ab/0x3d0
[  536.639885]  ? alloc_pdp+0x3a/0xd0 [i915]
[  536.639887]  ? save_stack.isra.2+0x53/0xa0
[  536.639899]  ? __pdp_init.isra.4+0x44/0x90 [i915]
[  536.639900]  __slab_alloc.isra.22.constprop.27+0x43/0x80
[  536.639902]  ? __slab_alloc.isra.22.constprop.27+0x43/0x80
[  536.639903]  __kmalloc+0x288/0x330
[  536.639914]  __pdp_init.isra.4+0x44/0x90 [i915]
[  536.639925]  alloc_pdp+0x62/0xd0 [i915]
[  536.639935]  gen8_ppgtt_alloc_4lvl+0xba/0x150 [i915]
[  536.639946]  ppgtt_bind_vma+0x2c/0x80 [i915]
[  536.639959]  i915_vma_bind+0xb9/0x240 [i915]
[  536.639972]  __i915_vma_do_pin+0x404/0x6b0 [i915]
[  536.639983]  i915_gem_execbuffer_reserve_vma.isra.9+0xc3/0x240 [i915]
[  536.639994]  i915_gem_execbuffer_reserve.isra.10+0x43e/0x470 [i915]
[  536.640005]  i915_gem_do_execbuffer.isra.16+0x639/0x1b80 [i915]
[  536.640007]  ? __lock_acquire+0x484/0x1ac0
[  536.640019]  i915_gem_execbuffer2+0xb5/0x220 [i915]
[  536.640021]  drm_ioctl+0x1f4/0x480
[  536.640031]  ? i915_gem_execbuffer+0x330/0x330 [i915]
[  536.640034]  do_vfs_ioctl+0x90/0x6e0
[  536.640035]  ? entry_SYSCALL_64_fastpath+0x5/0xb1
[  536.640038]  ? __this_cpu_preempt_check+0x13/0x20
[  536.640039]  ? trace_hardirqs_on_caller+0xe7/0x200
[  536.640041]  SyS_ioctl+0x3c/0x70
[  536.640042]  entry_SYSCALL_64_fastpath+0x1c/0xb1
[  536.640044] RIP: 0033:0x7f002a137357
[  536.640045] RSP: 002b:00007fffb9318468 EFLAGS: 00000246 ORIG_RAX:
0000000000000010
[  536.640046] RAX: ffffffffffffffda RBX: ffffffff8147cea3 RCX:
00007f002a137357
[  536.640047] RDX: 00007fffb9318500 RSI: 0000000040406469 RDI:
0000000000000004
[  536.640047] RBP: ffffc900003d7f88 R08: 0000000000000008 R09:
0000000000000000
[  536.640048] R10: 000000000000001f R11: 0000000000000246 R12:
0000000000000000
[  536.640049] R13: 0000000000000004 R14: 0000000040406469 R15:
0000000000000001
[  536.640051]  ? __this_cpu_preempt_check+0x13/0x20
[  536.640052] FIX kmalloc-4096: Restoring
0xffff880264921198-0xffff8802649212f1=0x6b

[  536.640061] FIX kmalloc-4096: Marking all objects used

-- 
You are receiving this mail because:
You are the assignee for the bug.
