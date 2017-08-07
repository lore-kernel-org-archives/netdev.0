From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH V1 0/3] asix: Improve robustness
Date: Mon, 7 Aug 2017 09:50:13 +0100
Message-ID: <1502095816-3255-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
        Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:36323 "EHLO
        relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752528AbdHGIuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:50:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please consider taking these patches to improve the robustness of the ASIX USB
to Ethernet driver.


Failures prompting an ASIX driver code review
=============================================

On an ARM i.MX6 embedded platform some strange one-off and two-off failures were
observed in and around the ASIX USB to Ethernet driver. This was observed on a
highly modified kernel 3.14 with the ASIX driver containing back-ported changes
from kernel.org up to kernel 4.8 approximately. 


a) A one-off failure in asix_rx_fixup_internal():

There was an occurrence of an attempt to write off the end of the netdev buffer
which was trapped by skb_over_panic() in skb_put().

[20030.846440] skbuff: skb_over_panic: text:7f2271c0 len:120 put:60 head:8366ecc0 data:8366ed02 tail:0x8366ed7a end:0x8366ed40 dev:eth0
[20030.863007] Kernel BUG at 8044ce38 [verbose debug info unavailable]

[20031.215345] Backtrace: 
[20031.217884] [<8044cde0>] (skb_panic) from [<8044d50c>] (skb_put+0x50/0x5c)
[20031.227408] [<8044d4bc>] (skb_put) from [<7f2271c0>] (asix_rx_fixup_internal+0x1c4/0x23c [asix])
[20031.242024] [<7f226ffc>] (asix_rx_fixup_internal [asix]) from [<7f22724c>] (asix_rx_fixup_common+0x14/0x18 [asix])
[20031.260309] [<7f227238>] (asix_rx_fixup_common [asix]) from [<7f21f7d4>] (usbnet_bh+0x74/0x224 [usbnet])
[20031.269879] [<7f21f760>] (usbnet_bh [usbnet]) from [<8002f834>] (call_timer_fn+0xa4/0x1f0)
[20031.283961] [<8002f790>] (call_timer_fn) from [<80030834>] (run_timer_softirq+0x230/0x2a8)
[20031.302782] [<80030604>] (run_timer_softirq) from [<80028780>] (__do_softirq+0x15c/0x37c)
[20031.321511] [<80028624>] (__do_softirq) from [<80028c38>] (irq_exit+0x8c/0xe8)
[20031.339298] [<80028bac>] (irq_exit) from [<8000e9c8>] (handle_IRQ+0x8c/0xc8)
[20031.350038] [<8000e93c>] (handle_IRQ) from [<800085c8>] (gic_handle_irq+0xb8/0xf8)
[20031.365528] [<80008510>] (gic_handle_irq) from [<8050de80>] (__irq_svc+0x40/0x70)

Analysis of the logic of the ASIX driver (containing backported changes from
kernel.org up to kernel 4.8 approximately) suggested that the software could not
trigger skb_over_panic(). The analysis of the kernel BUG() crash information
suggested that the netdev buffer was written with 2 minimal 60 octet length
Ethernet frames (ASIX hardware drops the 4 octet FCS field) and the 2nd Ethernet
frame attempted to write off the end of the netdev buffer.

Note that the netdev buffer should only contain 1 Ethernet frame so if an
attempt to write 2 Ethernet frames into the buffer is made then that is wrong.
However, the logic of the asix_rx_fixup_internal() only allows 1 Ethernet frame
to be written into the netdev buffer.

Potentially this failure was due to memory corruption because it was only seen
once.


b) Two-off failures in the NAPI layer's backlog queue:

There were 2 crashes in the NAPI layer's backlog queue presumably after
asix_rx_fixup_internal() called usbnet_skb_return().

[24097.273945] Unable to handle kernel NULL pointer dereference at virtual address 00000004

[24097.398944] PC is at process_backlog+0x80/0x16c

[24097.569466] Backtrace: 
[24097.572007] [<8045ad98>] (process_backlog) from [<8045b64c>] (net_rx_action+0xcc/0x248)
[24097.591631] [<8045b580>] (net_rx_action) from [<80028780>] (__do_softirq+0x15c/0x37c)
[24097.610022] [<80028624>] (__do_softirq) from [<800289cc>] (run_ksoftirqd+0x2c/0x84)

and

[ 1059.828452] Unable to handle kernel NULL pointer dereference at virtual address 00000000

[ 1059.953715] PC is at process_backlog+0x84/0x16c

[ 1060.140896] Backtrace: 
[ 1060.143434] [<8045ad98>] (process_backlog) from [<8045b64c>] (net_rx_action+0xcc/0x248)
[ 1060.163075] [<8045b580>] (net_rx_action) from [<80028780>] (__do_softirq+0x15c/0x37c)
[ 1060.181474] [<80028624>] (__do_softirq) from [<80028c38>] (irq_exit+0x8c/0xe8)
[ 1060.199256] [<80028bac>] (irq_exit) from [<8000e9c8>] (handle_IRQ+0x8c/0xc8)
[ 1060.210006] [<8000e93c>] (handle_IRQ) from [<800085c8>] (gic_handle_irq+0xb8/0xf8)
[ 1060.225492] [<80008510>] (gic_handle_irq) from [<8050de80>] (__irq_svc+0x40/0x70)

The embedded board was only using an ASIX USB to Ethernet adaptor eth0.

Analysis suggested that the doubly-linked list pointers of the backlog queue had
been corrupted because one of the link pointers was NULL.

Potentially this failure was due to memory corruption because it was only seen
twice.


Results of the ASIX driver code review
======================================

During the code review some weaknesses were observed in the ASIX driver and the
following patches have been created to improve the robustness.


Brief overview of the patches
-----------------------------

1. asix: Add rx->ax_skb = NULL after usbnet_skb_return()

The current ASIX driver sends the received Ethernet frame to the NAPI layer of
the network stack via the call to usbnet_skb_return() in
asix_rx_fixup_internal() but retains the rx->ax_skb pointer to the netdev
buffer. The driver no longer needs the rx->ax_skb pointer at this point because
the NAPI layer now has the Ethernet frame.

This means that asix_rx_fixup_internal() must not use rx->ax_skb after the call
to usbnet_skb_return() because it could corrupt the handling of the Ethernet
frame within the network layer.

Therefore, to remove the risk of erroneous usage of rx->ax_skb, set rx->ax_skb
to NULL after the call to usbnet_skb_return(). This avoids potential erroneous
freeing of rx->ax_skb and erroneous writing to the netdev buffer.  If the
software now somehow inappropriately reused rx->ax_skb, then a NULL pointer
dereference of rx->ax_skb would occur which makes investigation easier.

2. asix: Ensure asix_rx_fixup_info members are all reset

This patch creates reset_asix_rx_fixup_info() to allow all the
asix_rx_fixup_info structure members to be consistently reset to initial
conditions.

Call reset_asix_rx_fixup_info() upon each detectable error condition so that the
next URB is processed from a known state.

Otherwise, there is a risk that some members of the asix_rx_fixup_info structure
may be incorrect after an error occurred so potentially leading to a
malfunction.

3. asix: Fix small memory leak in ax88772_unbind()

This patch creates asix_rx_fixup_common_free() to allow the rx->ax_skb to be
freed when necessary.

asix_rx_fixup_common_free() is called from ax88772_unbind() before the parent
private data structure is freed.

Without this patch, there is a risk of a small netdev buffer memory leak each
time ax88772_unbind() is called during the reception of an Ethernet frame that
spans across 2 URBs.


Testing
=======

The patches have been sanity tested on a 64-bit Linux laptop running kernel
4.13-rc2 with the 3 patches applied on top.

The ASIX USB to Adaptor used for testing was (output of lsusb):
ID 0b95:772b ASIX Electronics Corp. AX88772B

Test #1
-------

The test ran a flood ping test script which slowly incremented the ICMP Echo
Request's payload from 0 to 5000 octets. This eventually causes IPv4
fragmentation to occur which causes Ethernet frames to be sent very close to
each other so increases the probability that an Ethernet frame will span 2 URBs.
The test showed that all pings were successful. The test took about 15 minutes
to complete.

Test #2
-------

A script was run on the laptop to periodically run ifdown and ifup every second
so that the ASIX USB to Adaptor was up for 1 second and down for 1 second.

>From a Linux PC connected to the laptop, the following ping command was used
ping -f -s 5000 <ip address of laptop>

The large ICMP payload causes IPv4 fragmentation resulting in multiple
Ethernet frames per original IP packet.

Kernel debug within the ASIX driver was enabled to see whether any ASIX errors
were generated. The test was run for about 24 hours and no ASIX errors were
seen.


Patches
=======

The 3 patches have been rebased off the net-next repo master branch with HEAD
fbbeefd net: fec: Allow reception of frames bigger than 1522 bytes

Dean Jenkins (3):
  asix: Add rx->ax_skb = NULL after usbnet_skb_return()
  asix: Ensure asix_rx_fixup_info members are all reset
  asix: Fix small memory leak in ax88772_unbind()

 drivers/net/usb/asix.h         |  1 +
 drivers/net/usb/asix_common.c  | 53 ++++++++++++++++++++++++++++++++++--------
 drivers/net/usb/asix_devices.c |  1 +
 3 files changed, 45 insertions(+), 10 deletions(-)

-- 
2.7.4
