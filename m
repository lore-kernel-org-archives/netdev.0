From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: q == &noop_qdisc warning from 802.11 code
Date: Wed, 23 Jul 2008 10:41:22 -0300
Message-ID: <48873502.1030106@linux.vnet.ibm.com>
References: <488723FF.8070707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Michael Wu <flamingice@sourmilk.net>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Jiri Slaby <jirislaby@GMAIL.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:51155 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741AbYGWNlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 09:41:52 -0400
In-Reply-To: <488723FF.8070707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby wrote:
> Hi,
> 
> I hit the warning from __netif_schedule:

I also hit a bug related to noop_qdisc running the net-next kernel. 
I hit this bug every time I run "ifconfig eth0 mtu 9000; ifconfg eth0 1500" for any
interface (tested against s2io and e1000) that is up, otherwise the bug isn't
reproducible.

The bug dumps the following calltrace: 

[root@io-dolphins net-next-2.6]# ifconfig eth0  mtu 9000; ifconfig eth0 mtu 1500
------------[ cut here ]------------
kernel BUG at net/core/dev.c:1328!
cpu 0x1: Vector: 700 (Program Check) at [c0000000be3d3460]
    pc: c0000000003603ac: .__netif_schedule+0x2c/0xb8
    lr: d00000000026b014: .s2io_change_mtu+0x1c4/0x27c [s2io]
    sp: c0000000be3d36e0
   msr: 8000000000029032
  current = 0xc0000000bc4042b0
  paca    = 0xc0000000006f3680
    pid   = 3496, comm = ifconfig
kernel BUG at net/core/dev.c:1328!
enter ? for help
[c0000000be3d3760] d00000000026b014 .s2io_change_mtu+0x1c4/0x27c [s2io]
[c0000000be3d3800] c0000000003631ac .dev_set_mtu+0x68/0xb0
[c0000000be3d3880] c000000000364bc4 .dev_ioctl+0x67c/0x780
[c0000000be3d3990] c000000000354394 .sock_ioctl+0x2d8/0x310
[c0000000be3d3a30] c0000000001054b4 .vfs_ioctl+0x5c/0xf0
[c0000000be3d3ad0] c000000000105954 .do_vfs_ioctl+0x40c/0x448
[c0000000be3d3b80] c000000000105a00 .sys_ioctl+0x70/0xb4
[c0000000be3d3c30] c00000000013a2e8 .dev_ifsioc+0x1b0/0x3e4
[c0000000be3d3d40] c0000000001398a8 .compat_sys_ioctl+0x3d4/0x468
[c0000000be3d3e30] c0000000000086b4 syscall_exit+0x0/0x40
--- Exception: c00 (System Call) at 000000000ff15fe8
SP (ffecf8a0) is in userspace

And the code which is causing the bug is the following: 

void __netif_schedule(struct Qdisc *q)
{
        BUG_ON(q == &noop_qdisc);

So, somehow we're reaching __netif_schedule() using a noop_qdisc. 
-- 
Breno Leitao
leitao@linux.vnet.ibm.com
