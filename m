From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: Re: [PATCH] ethtool: Add register dump support for all r8169 driver cards
Date: Wed, 26 Mar 2008 20:11:39 -0400
Message-ID: <76366b180803261711g3534f427q4e16e29766211dc4@mail.gmail.com>
References: <76366b180803260519t7c446210n62d4c91209c5e971@mail.gmail.com>
	 <20080326214432.GA9356@electric-eye.fr.zoreil.com>
	 <76366b180803261511x518e4475n72dbcee2d1942be3@mail.gmail.com>
	 <20080326221147.GB9034@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jeff Garzik" <jeff@garzik.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:38326 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317AbYC0ALl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 20:11:41 -0400
Received: by wr-out-0506.google.com with SMTP id c48so3067791wra.1
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 17:11:41 -0700 (PDT)
In-Reply-To: <20080326221147.GB9034@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 6:11 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>  Can you elaborate on the kind of hang ? Which kernel do you use ?

Thanks for the contact, I'll give that a try. The hang I'm
experiencing is after performing a very simple test. I set up the
8110SC box to netcat /dev/zero to the port of another machine which is
just running netcat and piping it to /dev/null. After anywhere from a
few minutes to an hour of this traffic, all network traffic
mysteriously hangs. SysRq dump shows netcat waiting inside
sk_stream_memory_free(). netstat on the interface shows the Send-Q is
really high, around 180000. If I ping other hosts, it lags for a long
time and comes back with ping times like 35,500ms. If I ifconfig eth0
down / up, everything goes back to normal and I can reproduce the
problem again by repeating the steps.

I've tried both the in-kernel driver as well as the Realtek 6.005.00
driver in 2.6.24.4 (I patched the Realtek driver to work with the API
changes) both with and without NAPI enabled. I've reproduced this
problem on more than one board, with different hosts acting as the
/dev/null sink and with different switches being used inbetween them
(1000mbit and 100mbit).

If you have any suggestions, I'm not sure where I should continue looking.

If it helps at all, this is the SysRq dump for the nc and ping
processes while the computer was in this state:

nc            S 7fffffff     0  2131    659
       cf3800a0 00000086 cf308880 7fffffff 00000000 cf255e60 c047db5e 0000000a
       cf0024a0 00000010 00000020 00000004 00000286 c04377c3 cf308880 cf308880
       7fffffff c043c97e 00000000 cf2a9050 c0228505 cec9ea38 cec9ea38 cc474860
Call Trace:
 [<c047db5e>] schedule_timeout+0x13/0x97
 [<c04377c3>] release_sock+0xc/0x74
 [<c043c97e>] sk_stream_wait_memory+0x15e/0x176
 [<c0228505>] autoremove_wake_function+0x0/0x35
 [<c045a64b>] tcp_sendmsg+0x830/0x9fa
 [<c021e438>] __do_softirq+0x35/0x75
 [<c0435553>] sock_aio_write+0xbc/0xc8
 [<c0253959>] pipe_read+0x330/0x33c
 [<c024e569>] do_sync_write+0xc6/0x109
 [<c0228505>] autoremove_wake_function+0x0/0x35
 [<c026e19f>] inotify_inode_queue_event+0xc8/0xd0
 [<c024ed00>] vfs_write+0x9e/0x111
 [<c024f197>] sys_write+0x41/0x67
 [<c0203b4e>] syscall_call+0x7/0xb
 =======================
ping          S 7fffffff     0  7005    599
       cf380220 00000082 00000000 7fffffff cc45fd84 cc45fd70 c047db5e bfe5a571
       cc45ff44 c046a7ba 00000000 00000000 cc45fda8 00000202 00000000 00000000
       cf0df040 c043c664 00000000 7fffffff 00000001 cf2a9ab0 c0228505 cec9e4b8
Call Trace:
 [<c047db5e>] schedule_timeout+0x13/0x97
 [<c046a7ba>] raw_sendmsg+0x5bd/0x673
 [<c043c664>] skb_recv_datagram+0x118/0x194
 [<c0228505>] autoremove_wake_function+0x0/0x35
 [<c046a034>] raw_recvmsg+0x71/0x143
 [<c0437271>] sock_common_recvmsg+0x3e/0x54
 [<c0435d2a>] sock_recvmsg+0xce/0xe7
 [<c0435dfe>] sock_sendmsg+0xbb/0xd3
 [<c0228505>] autoremove_wake_function+0x0/0x35
 [<c043692c>] sys_recvfrom+0xd8/0x12d
 [<c0391c91>] rtl8169_rx_interrupt+0x378/0x405
 [<c022c877>] getnstimeofday+0x2b/0xac
 [<c022a6eb>] enqueue_hrtimer+0xd7/0xe2
 [<c0436e37>] sys_socketcall+0x1b0/0x242
 [<c0203b4e>] syscall_call+0x7/0xb

Thanks,
-Andrew
