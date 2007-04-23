From: Andrew Morton <akpm@linux-foundation.org>
Subject: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 13:07:34 -0700
Message-ID: <20070423130734.d3d90b20.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:34216 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbXDWUHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 16:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I have a problem here.  To eliminate other -mm things I tested bare
git+ssh://master.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.22.git
as of 15 minutes ago and the problem is there too.

The machine is x86_64 running FC6.  The config is based on RH's own FC6
config and it's at http://userweb.kernel.org/~akpm/config-akpm2.txt

Symptoms are that networking-related initscripts take a looooong time. 
statd and cups take maybe a minute and when it gets to starting sendmail,
things appear to hang permanently - I hit the switch after a few minutes.

A sysrq-T was taken during the statd bringup stall:
http://userweb.kernel.org/~akpm/dmesg-akpm2.txt

The interesting bit is:


Apr 23 12:01:15 akpm2 kernel: rpc.statd     S 0000001f2b1f297b     0  3479   3478 (NOTLB)
Apr 23 12:01:15 akpm2 kernel:  ffff81024ef2fb28 0000000000000082 0000000000000000 00000009000000c6
Apr 23 12:01:15 akpm2 kernel:  0000000000000246 000000000000004c ffff81025eba8040 ffff81025fe08100
Apr 23 12:01:15 akpm2 kernel:  ffff81025eba8258 000000075e936000 00000000ffff29e4 0000000000000286
Apr 23 12:01:15 akpm2 kernel: Call Trace:
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8048c513>] udp_poll+0x0/0x104
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8025e759>] schedule_timeout+0x8a/0xad
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8028d7a3>] process_timeout+0x0/0x5
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8022ed7b>] do_sys_poll+0x27a/0x35c
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8021e6a6>] __pollwait+0x0/0xdd
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff80284486>] default_wake_function+0x0/0xe
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff80333c56>] socket_has_perm+0x5b/0x68
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff802510ea>] sock_sendmsg+0xea/0x107
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8048eacb>] arp_bind_neighbour+0x6b/0x9f
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8029696e>] autoremove_wake_function+0x0/0x2e
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff80254bf4>] __ip_route_output_key+0x709/0x7c4
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff804565a5>] sys_sendto+0x128/0x151
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff80331502>] file_has_perm+0x48/0xa3
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff80249319>] sys_poll+0x32/0x3b
Apr 23 12:01:15 akpm2 kernel:  [<ffffffff8025911e>] system_call+0x7e/0x83
Apr 23 12:01:15 akpm2 kernel: 
Apr 23 12:01:51 akpm2 rpc.statd[3479]: gethostbyname error for akpm2.corp.google.com

I think I saw the same problem maybe 1.5 weeks ago on this machine, but I
didn't have time to investigate further.  So it's not some recent thing.
