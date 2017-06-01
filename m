From: Xin Long <lucien.xin@gmail.com>
Subject: Re: Oops with commit 6d18c73 bridge: start hello_timer when enabling
 KERNEL_STP in br_stp_start
Date: Thu, 1 Jun 2017 15:42:52 +0800
Message-ID: <CADvbK_c_bXnPL5NdADj=aCv8f-A0wPKdUmQJqm=XDRf0rizXcA@mail.gmail.com>
References: <alpine.LFD.2.20.1705311816090.1727@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Haidong Li <haili@redhat.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Ivan Vecera <cera@cera.cz>,
        Stephen Hemminger <stephen@networkplumber.org>,
        network dev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36859 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdFAHmx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 03:42:53 -0400
In-Reply-To: <alpine.LFD.2.20.1705311816090.1727@schleppi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 12:32 AM, Sebastian Ott
<sebott@linux.vnet.ibm.com> wrote:
[...]
>
> A system running v4.12-rc3-11-gf511c0b on s390 hangs after boot with no
> messages on the console. The message buffer obtained via a system dump
> looked like this:
>
> [...]
> [   17.870712] virbr0: port 1(virbr0-nic) entered disabled state
> [   19.618523] Unable to handle kernel pointer dereference in virtual kernel address space
> [  250.028426] INFO: task jbd2/dasda1-8:100 blocked for more than 120 seconds.
> [  250.028427]       Not tainted 4.12.0-rc3-00011-gf511c0b #573
> [  250.028428] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  250.028429] jbd2/dasda1-8   D12808   100      2 0x00000000
> [  250.028437] Stack:
> [  250.028437]        00000000e8c4f9b0 0000000000000000 0000000000233afe 00000000e8c48100
> [  250.028441]        00000000e8c4f978 00000000001b1c98 00000000e8c4f978 00000000e8c4f9d8
> [  250.028444]        04000000efdcce00 00000000e8c48890 0000000000000000 00000000efdcce18
> [  250.028447]        00000000e8c48100 00000000efdcce00 00000000e8ce8100 00000000e73c6900
> [  250.028450]        00000000008da090 00000000008c4f54 00000000e8c4f9d8 00000000e8c4fa60
> [  250.028453] Call Trace:
> [  250.028458] ([<00000000008c4f54>] __schedule+0xb14/0xc90)
> [  250.028459]  [<00000000008c5164>] schedule+0x94/0xc0
> [  250.028462]  [<00000000001802ac>] io_schedule+0x34/0x58
> [  250.028464]  [<00000000002a44c2>] wait_on_page_bit+0x16a/0x198
> [  250.028465]  [<00000000002a4576>] __filemap_fdatawait_range+0x86/0x188
> [  250.028467]  [<00000000002a46a6>] filemap_fdatawait_range+0x2e/0x58
> [  250.028471]  [<00000000004719d4>] jbd2_journal_commit_transaction+0x10e4/0x2200
> [  250.028473]  [<000000000047890a>] kjournald2+0xda/0x2c0
> [  250.028475]  [<000000000016da5e>] kthread+0x166/0x178
> [  250.028477]  [<00000000008cce7a>] kernel_thread_starter+0x6/0xc
> [  250.028479]  [<00000000008cce74>] kernel_thread_starter+0x0/0xc
> [  250.028480] INFO: lockdep is turned off.
> [...]
I couldn't see any bridge-related thing here, and it couldn't be reproduced
with virbr0 (stp=1) on my box (on both s390x and x86_64), I guess there
is something else in you machine.

With the latest upstream kernel, can you remove libvirt (virbr0) and boot your
machine normally, then:
# brctl addbr br0
# ip link set br0 up
# brctl stp br0 on

to check if it will still hang.

If it can't be reproduced in this way, pls add this on your kernel:

--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -178,9 +178,11 @@ static void br_stp_start(struct net_bridge *br)
                br->stp_enabled = BR_KERNEL_STP;
                br_debug(br, "using kernel STP\n");

+               WARN_ON(1);
                /* To start timers on any ports left in blocking */
                mod_timer(&br->hello_timer, jiffies + br->hello_time);
                br_port_state_selection(br);
+               pr_warn("hello timer start done\n");
        }

        spin_unlock_bh(&br->lock);
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 60b6fe2..c98b3e5 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -40,7 +40,7 @@ static void br_hello_timer_expired(unsigned long arg)
        if (br->dev->flags & IFF_UP) {
                br_config_bpdu_generation(br);

-               if (br->stp_enabled == BR_KERNEL_STP)
+               if (br->stp_enabled != BR_USER_STP)
                        mod_timer(&br->hello_timer,
                                  round_jiffies(jiffies + br->hello_time));


let's see if it hangs when starting the timer. Thanks.
