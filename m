From: Daniel Pittman <daniel@rimspace.net>
Subject: Linux IPSec crash.
Date: Mon, 19 Apr 2004 00:20:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87k70djrkz.fsf@enki.rimspace.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

[this is a resent version of a message I posted, but can't find, from
 the other day.  Sorry if it is a duplicate message.]

I have been trying to get IPSec, specifically tunnel mode ESP with
authentication, working between a couple of systems on my network.

This works fine in one direction, but caused a kernel panic in the
other, from the following assertion and oops.

I have attached the IPSec (setkey) configuration files for both ends,
since they are not for anything but testing anyway.

'enki' is the machine that originated the traffic, and 'achor' the
machine that crashed.

The kernel is a current BKCVS pull, built yesterday morning to enable
netconsole.

This was captured by netconsole, which is a very nice tool for debugging
this sort of thing. Thanks to those who put it in place.

If I can do anything more, please let me know.
   Daniel

KERNEL: assertion (x->km.state == XFRM_STATE_DEAD) failed at net/xfrm/xfrm_state.c (193)
Unable to handle kernel paging request at virtual address 90002033
 printing eip:
c029442f
*pde = 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c029442f>]    Not tainted
EFLAGS: 00010282   (2.6.5-achor)
EIP is at __xfrm4_state_lookup+0x6f/0xa0
eax: 9000202b   ebx: c2119808   ecx: c0378898   edx: 90002033
esi: 9000202b   edi: 211dd9cb   ebp: 00010000   esp: c0319ca8
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0318000 task=c02dca20)
Stack: 32000000 00000032 c02f41e0 c3f685e0 c3f685e0 c0298f6c c2119830 00010000
       00000032 00000000 c2721800 c0294760 c2119830 00010000 00000032 00000002
       00000000 00000001 00000000 00000282 c2721800 00000000 00000000 00010000
Call Trace:
 [<c0298f6c>] xfrm_state_lookup+0x4c/0x70
 [<c0294760>] xfrm4_rcv_encap+0x90/0x430
 [<c0223fef>] sock_def_readable+0x5f/0x70
 [<c026db02>] raw_rcv_skb+0xd2/0x140
 [<c026dc0c>] raw_rcv+0x9c/0x100
 [<c026d892>] raw_v4_input+0xc2/0x100
 [<c0294625>] xfrm4_rcv+0x15/0x20
 [<c024e315>] ip_local_deliver_finish+0xc5/0x1b0
 [<c023280b>] nf_hook_slow+0xdb/0x130
 [<c024e250>] ip_local_deliver_finish+0x0/0x1b0
 [<c024dda9>] ip_local_deliver+0x209/0x230
 [<c024e250>] ip_local_deliver_finish+0x0/0x1b0
 [<c024e5e9>] ip_rcv_finish+0x1e9/0x260
 [<c024e400>] ip_rcv_finish+0x0/0x260
 [<c023280b>] nf_hook_slow+0xdb/0x130
 [<c024e400>] ip_rcv_finish+0x0/0x260
 [<c024e18f>] ip_rcv+0x3bf/0x480
 [<c024e400>] ip_rcv_finish+0x0/0x260
 [<c010bf1a>] do_gettimeofday+0x1a/0xd0
 [<c0229081>] netif_receive_skb+0x141/0x180
 [<c01f9368>] rtl8139_rx+0x1a8/0x320
 [<c01132af>] scheduler_tick+0x1f/0x520
 [<c021eac0>] i8042_timer_func+0x0/0x20
 [<c01f96d3>] rtl8139_poll+0x43/0xc0
 [<c0229234>] net_rx_action+0x74/0x100
 [<c011a2d5>] do_softirq+0x95/0xa0
 [<c0108a35>] do_IRQ+0xc5/0xf0
 [<c0106f3c>] common_interrupt+0x18/0x20
 [<c0104c33>] default_idle+0x23/0x40
 [<c0104cc4>] cpu_idle+0x34/0x40
 [<c031a733>] start_kernel+0x153/0x170
 [<c031a490>] unknown_bootoption+0x0/0x120

Code: 8b 40 08 0f 18 00 90 39 ca 75 e6 31 c0 5a 5b 5e 5f 5d c3 3b
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing
 <0>Rebooting in 10 seconds..


--=-=-=
Content-Disposition: attachment; filename=enki.conf

#!/usr/sbin/setkey -f

# Configuration for enki (203.217.29.45) to achor (203.217.29.33)
# This is the enki side

# Flush the SAD and SPD
flush;
spdflush;

# Create the ESP session with encryption and authentication.
add 203.217.29.45 203.217.29.33 esp 0x100 -m tunnel
        -E blowfish-cbc  0xf4aaa016e85dcec8318f10b97aa237cf07a95734f53849d0bf461961ff3d828c 
        -A hmac-sha2-256 0x8338aca85649969d95765c96a17a622629752b095acfd80595b7e72da45264d2 
        ;

add 203.217.29.33 203.217.29.45 esp 0x101 -m tunnel
        -E blowfish-cbc  0xa55be4391df590938e00ce616eef526d7404fb9a4a8ee2077152e16ef41117bc
        -A hmac-sha2-256 0xb4ead5d3fdee487c81846155fed01ade8783900b5b8a2c9c50884db0459c6990
        ;


# Create the security policy that encrypts packets heading to the firewall.
# This is just a point-to-point link, for the moment, for ICMP only.
spdadd 203.217.29.45 203.217.29.33 icmp -P out ipsec
        esp/tunnel/203.217.29.45-203.217.29.33/require;

spdadd 203.217.29.33 203.217.29.45 icmp -P in ipsec
        esp/tunnel/203.217.29.33-203.217.29.45/require;

--=-=-=
Content-Disposition: attachment; filename=achor.conf

#!/usr/sbin/setkey -f

# Configuration for enki (203.217.29.45) to achor (203.217.29.33)
# This is the achor side.

# Flush the SAD and SPD
flush;
spdflush;

# Create the ESP session with encryption and authentication.
add 203.217.29.45 203.217.29.33 esp 0x100 -m tunnel
        -E blowfish-cbc  0xf4aaa016e85dcec8318f10b97aa237cf07a95734f53849d0bf461961ff3d828c 
        -A hmac-sha2-256 0x8338aca85649969d95765c96a17a622629752b095acfd80595b7e72da45264d2 
        ;

add 203.217.29.33 203.217.29.45 esp 0x101 -m tunnel
        -E blowfish-cbc  0xa55be4391df590938e00ce616eef526d7404fb9a4a8ee2077152e16ef41117bc
        -A hmac-sha2-256 0xb4ead5d3fdee487c81846155fed01ade8783900b5b8a2c9c50884db0459c6990
        ;


# Create the security policy that encrypts packets heading to the firewall.
# This is just a point-to-point link, for the moment, for ICMP only.
spdadd 203.217.29.45 203.217.29.33 icmp -P in ipsec
        esp/tunnel/203.217.29.45-203.217.29.33/require;

spdadd 203.217.29.33 203.217.29.45 icmp -P out ipsec
        esp/tunnel/203.217.29.45-203.217.29.33/require;

--=-=-=


-- 
Psychology is a rubber stamp pressed upon a slippery, dodging ghost.
        -- Maxwell Bodenheim

--=-=-=--
