From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net/virtio_ring: fix race in enable_cb
Date: Mon, 17 Mar 2008 12:48:13 +1100
Message-ID: <200803171248.14570.rusty@rustcorp.com.au>
References: <200803141417.05696.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60537 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594AbYCQBtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Mar 2008 21:49:07 -0400
In-Reply-To: <200803141417.05696.borntraeger@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 15 March 2008 00:17:05 Christian Borntraeger wrote:
> There is a race in virtio_net, dealing with disabling/enabling the
> callback. I saw the following oops:
>
> kernel BUG at /space/kvm/drivers/virtio/virtio_ring.c:218!
> illegal operation: 0001 [#1] SMP
> Modules linked in: sunrpc dm_mod
> CPU: 2 Not tainted 2.6.25-rc1zlive-host-10623-gd358142-dirty #99
> Process swapper (pid: 0, task: 000000000f85a610, ksp: 000000000f873c60)
> Krnl PSW : 0404300180000000 00000000002b81a6 (vring_disable_cb+0x16/0x20)
>            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:3 PM:0 EA:3
> Krnl GPRS: 0000000000000001 0000000000000001 0000000010005800
> 0000000000000001 000000000f3a0900 000000000f85a610 0000000000000000
> 0000000000000000 0000000000000000 000000000f870000 0000000000000000
> 0000000000001237 000000000f3a0920 000000000010ff74 00000000002846f6
> 000000000fa0bcd8 Krnl Code: 00000000002b819a: a7110001           tmll   
> %r1,1
>            00000000002b819e: a7840004           brc     8,2b81a6
>            00000000002b81a2: a7f40001           brc     15,2b81a4
>
>           >00000000002b81a6: a51b0001           oill    %r1,1
>
>            00000000002b81aa: 40102000           sth     %r1,0(%r2)
>            00000000002b81ae: 07fe               bcr     15,%r14
>            00000000002b81b0: eb7ff0380024       stmg    %r7,%r15,56(%r15)
>            00000000002b81b6: a7f13e00           tmll    %r15,15872
> Call Trace:
> ([<000000000fa0bcd0>] 0xfa0bcd0)
>  [<00000000002b8350>] vring_interrupt+0x5c/0x6c
>  [<000000000010ab08>] do_extint+0xb8/0xf0
>  [<0000000000110716>] ext_no_vtime+0x16/0x1a
>  [<0000000000107e72>] cpu_idle+0x1c2/0x1e0
>
> The problem can be triggered with a high amount of host->guest traffic.

Are you seeing the "Unlikely: restart svq failed" message in the logs?  If 
not, I don't think it can be this race.

Your patch has some nice properties, however.  It means that enable_cb never 
actually fails, it just returns whether there may have been more work in the 
enabling window.

Unfortunately, this also implies that it'd be clearer to reverse the meaning 
of enable_cb's return code: true == more work came in, false == no more work.  
Doing this is unfortunately a PITA so I shall just apply your patch and fix 
up the documentation.

Thanks,
Rusty.
