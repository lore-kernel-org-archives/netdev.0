From: Florian Lohoff <f@zz.de>
Subject: Crash in skb_segment / KVM GSO GRE IPV6
Date: Sat, 14 Nov 2015 10:53:26 +0100
Message-ID: <20151114095326.GC3958@pax.zz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pax.zz.de ([88.198.69.77]:49973 "EHLO pax.zz.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbbKNKAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Nov 2015 05:00:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

we experienced a reproducible crash on a KVM/qemu Host running
Kernel 4.3.0 in skb_segment. (Setup is kvm guest, openvswitch 1.9 up to
2.something, host on 4.3.0). User in the guest kvm with virtio reportedly tried
to set up an v4 GRE tunnel with IPv6 Addresses and as soon as he started a simple
wget the host crashed.

I couldnt catch the full backtrace on the Host (IPMI redirect) 
here is what i typed from the video:

        NULL pointer dereference at 00000000084

        IP skb_segment+0x487/0x970

        RIP skb_segment+0x487/0x970

        ? __enqueue_entity
        tcp_gso_segment+0x11d/0x4a0
        ? debug_smp_processor_id
        tcp6_gso_segment
        ipv6_gso_segment
        ? default_wake_function
        skb_mac_gso_segment
        gre_gso_segment
        ? __wake_up_sync_key
        inet_gso_segment

Using gdb on skbuff.o i find this:

3120                            if (i >= nfrags) {
   0x0000000000005492 <+1154>:  cmp    %r15d,%r11d
   0x0000000000005495 <+1157>:  jg     0x54d5 <skb_segment+1221>

3121                                    BUG_ON(skb_headlen(list_skb));
   0x0000000000005497 <+1159>:  mov    0x84(%r13),%eax
   0x000000000000549e <+1166>:  cmp    %eax,0x80(%r13)
   0x00000000000054a5 <+1173>:  jne    0x5962 <skb_segment+2386>
   0x0000000000005962 <+2386>:  ud2

Where 0x84 is skb->data_len - So skb_headlen(list_skb) hits
an NULL list_skb.

Flo
-- 
Florian Lohoff                                                 f@zz.de
      We need to self-defend - GnuPG/PGP enable your email today!
