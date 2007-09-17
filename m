From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: 2.6.23-rc4-mm1 OOPS in forcedeth?
Date: Mon, 17 Sep 2007 17:00:22 -0400
Message-ID: <46EEEAE6.8050106@hp.com>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070901181352.GA4156@amd64.of.nowhere> <46D9B7EF.2050109@garzik.org> <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in> <20070902061900.GA5595@amd64.of.nowhere> <alpine.LFD.0.999.0709021504550.22654@enigma.security.iitk.ac.in> <20070913235133.0df3c590.ajwade+00@andrew.wade.networklinux.net> <20070917135729.GA19802@linux.vnet.ibm.com> <46EE8A13.1070102@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dhaval Giani <dhaval@linux.vnet.ibm.com>,
	ajwade+00@andrew.wade.mooo.com,
	Satyam Sharma <satyam@infradead.org>, thunder7@xs4all.nl,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:45945 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755428AbXIQVBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 17:01:43 -0400
In-Reply-To: <46EE8A13.1070102@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> I have also seen this OOPS on e1000 card. So, looks like driver independent.
> 
> By the way, this one has been triggered in a semi-stable way by the
> 'git-pull'

Do you have this patch:

commit 5c127c58ae9bf196d787815b1bd6b0aec5aee816
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Fri Aug 31 14:39:44 2007 -0700

    [TCP]: 'dst' can be NULL in tcp_rto_min()
    
    Reported by Rick Jones.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1ee7212..bbad2cd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -560,7 +560,7 @@ static u32 tcp_rto_min(struct sock *sk)
        struct dst_entry *dst = __sk_dst_get(sk);
        u32 rto_min = TCP_RTO_MIN;
 
-       if (dst_metric_locked(dst, RTAX_RTO_MIN))
+       if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
                rto_min = dst->metrics[RTAX_RTO_MIN-1];
        return rto_min;
 }



> 
> Regards,
> 	Den
> 
> Dhaval Giani wrote:
>> On Thu, Sep 13, 2007 at 11:51:33PM -0400, Andrew James Wade wrote:
>>> I have an Oops that may be related:
>>>
>>> BUG: unable to handle kernel NULL pointer dereference at virtual address 00000025
>>> printing eip: c037d81b *pde = 00000000
>>> Oops: 0000 [#1]
>>> last sysfs file: /devices/pci0000:00/0000:00:01.0/0000:01:00.0/class
>>>
>>> Pid: 0, comm: swapper Not tainted (2.6.23-rc4-mm1-config2 #2)
>>> EIP: 0060:[<c037d81b>] EFLAGS: 00010246 CPU: 0
>>> EIP is at tcp_rto_min+0xb/0x15
>>> EAX: 00000032 EBX: c4c98b68 ECX: fffffffe EDX: 00000000
>>> ESI: c4c98b68 EDI: c055f600 EBP: c4432e40 ESP: c0596dec
>>>  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>>> Process swapper (pid: 0, ti=c0596000 task=c052a340 task.ti=c0568000)
>>> Stack: c037d8de c4c98b68 c4c98b68 c037e0ec 00000001 c037f879 c052a8b4 c052a340
>>>        00000000 00000001 c25e1e60 00000000 00000000 00000001 8c176265 8c17678a
>>>        00000000 00000001 00000001 00000000 8c17678a 86000000 ffffffff 007d8b21
>>> Call Trace:
>>>  [<c037d8de>] tcp_rtt_estimator+0xb9/0xfe
>>>  [<c037e0ec>] tcp_ack_saw_tstamp+0x14/0x43
>>>  [<c037f879>] tcp_ack+0x6b8/0x17b8
>>>  [<c03833cc>] tcp_rcv_established+0x519/0x5f1
>>>  [<c038838d>] tcp_v4_do_rcv+0x28/0x2f8
>>>  [<c038a4ce>] tcp_v4_rcv+0x7df/0x83d
>>>  [<c0372542>] ip_local_deliver+0xcc/0x148
>>>  [<c0372975>] ip_rcv+0x3b7/0x3de
>>>  [<c035fa0e>] netif_receive_skb+0x17a/0x1c2
>>>  [<c02cc121>] rtl8139_poll+0x2d9/0x425
>>>  [<c03616d7>] net_rx_action+0xa8/0xc8
>>>  [<c011e8e0>] __do_softirq+0x40/0x90
>>>  [<c010635d>] do_softirq+0x4d/0xb6
>>>  =======================
>>> INFO: lockdep is turned off.
>>> Code: 24 8b 82 88 03 00 00 89 82 40 05 00 00 a1 a0 23 53 c0 89 82 44 05 00 00 83 c4 0c 5b 5e 5f 5d c3 8b 90 88 00 00 00 b8 32 00 00 00 <f6> 42 25 20 74 03 8b 42 54 c3 56
>>>  85 d2 b9 01 00 00 00 0f 45 ca
>>> EIP: [<c037d81b>] tcp_rto_min+0xb/0x15 SS:ESP 0068:c0596dec
>>> Kernel panic - not syncing: Fatal exception in interrupt
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

