From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: af_packet: use after free in prb_retire_rx_blk_timer_expired
Date: Mon, 10 Apr 2017 15:23:09 -0400
Message-ID: <20170410192309.35x7ddya2cyyv4y6@codemonkey.org.uk>
References: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "willemb@google.com" <willemb@google.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: alexander.levin@verizon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 07:03:30PM +0000, alexander.levin@verizon.com wrote:
 > Hi all,
 > 
 > I seem to be hitting this use-after-free on a -next kernel using trinity:
 >
 > [  531.036054] BUG: KASAN: use-after-free in prb_retire_rx_blk_timer_expired (net/packet/af_packet.c:688)                                                     [  531.036961] Read of size 8 at addr ffff88038c1fb0e8 by task swapper/1/0                                                                                    [  531.037727]                                                                                                                                                [  531.037928] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.11.0-rc5-next-20170407-dirty #24

Funny, I was just going over my old pending bugs, and found this one
from January that looks like what happens with the same bug, but without kasan..

context: PID: 0      TASK: ffff881ff2fa5100  CPU: 5   COMMAND: "swapper/5"
panic: general protection fault: 0000 [#1]
netversion: 2.2-1 (Feb 2014)
Backtrace:
 #0 [ffff881fffaa3c00] machine_kexec at ffffffff81044af8
 #1 [ffff881fffaa3c60] __crash_kexec at ffffffff810ec755
 #2 [ffff881fffaa3d28] crash_kexec at ffffffff810ec81f
 #3 [ffff881fffaa3d40] oops_end at ffffffff8101e348
 #4 [ffff881fffaa3d68] die at ffffffff8101e76b
 #5 [ffff881fffaa3d98] do_general_protection at ffffffff8101be76
 #6 [ffff881fffaa3dc0] general_protection at ffffffff817fe5a2
    [exception RIP: prb_retire_rx_blk_timer_expired+65]
    RIP: ffffffff817e6e41  RSP: ffff881fffaa3e78  RFLAGS: 00010246
    RAX: 0000000000000000  RBX: ffff881fd7075800  RCX: 0000000000000000
    RDX: ffff883ff0a16bb0  RSI: 0074636361757063  RDI: ffff881fd70758bc
    RBP: ffff881fffaa3e88   R8: 0000000000000001   R9: 0000000000000005
    R10: 0000000000000000  R11: 0000000000000000  R12: ffff881fd7075b78
    R13: 0000000000000100  R14: ffffffff817e6e00  R15: ffff881fd7075800
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #7 [ffff881fffaa3e90] call_timer_fn at ffffffff810cec35
 #8 [ffff881fffaa3ec8] run_timer_softirq at ffffffff810cf01c
 #9 [ffff881fffaa3f28] __softirqentry_text_start at ffffffff817ff05c
#10 [ffff881fffaa3f88] irq_exit at ffffffff8107d5fc
#11 [ffff881fffaa3f98] smp_apic_timer_interrupt at ffffffff817feea2
#12 [ffff881fffaa3fb0] apic_timer_interrupt at ffffffff817fd56f
--- <IRQ stack> ---
#13 [ffff881ff2fbfdd0] apic_timer_interrupt at ffffffff817fd56f
    RIP: 0000000000000018  RSP: 0000000000000000  RFLAGS: ffffffff81ebbb60
    RAX: ffffe8e0002a0400  RBX: 00000067b502e95f  RCX: 0000000000000006
    RDX: 000000000000002e  RSI: 0000000000000034  RDI: 0000000000000001
    RBP: ffffffff81150540   R8: ffff881ff2fbfee0   R9: 0000000000000001
    R10: 0000000000000005  R11: ffffffff81ebbb60  R12: ffff881ff2fbfe48
    R13: ffff881ff2fa5110  R14: 0000000000000000  R15: ffff881ff2fa5100
    ORIG_RAX: ffff881fffab5340  CS: 20c49ba5e353f7cf  SS: ffffffffffffff10
WARNING: possibly bogus exception frame
Dmesg:
Code: 00 00 48 8b 93 10 03 00 00 80 bb 21 03 00 00 00 44 0f b6 83 20 03 00 00 0f b7 c8 48 8b 34 ca 75 57 <44> 8b 5e 0c 45 85 db 74 1d 8b 93 68 03 00 00 85 d2 74 13 f3 90 

RIP 
 [<ffffffff817e6e41>] prb_retire_rx_blk_timer_expired+0x41/0x120
 RSP <ffff881fffaa3e78>
------------[ cut here ]------------
