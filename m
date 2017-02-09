From: Thomas Osterried <thomas@osterried.de>
Subject: linux mkiss.c panic: fix
Date: Thu, 9 Feb 2017 10:27:10 +0100
Message-ID: <B4836AA3-200E-4BDA-B1B1-CD3F6AF28F94@osterried.de>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: =?utf-8?Q?Ralf_B=C3=A4chle_DL5RB?= <ralf@linux-mips.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

linux mkiss driver could cause a panic. 

This patch fixes this issue:

Signed-off-by: Thomas Osterried <thomas@osterried.de>

mkiss kernel panic fix: Correct device variables guarantees proper skb room.

--- mkiss.c.orig        2015-11-18 11:08:46.000000000 +0100
+++ mkiss.c     2016-02-06 18:04:05.000000000 +0100
@@ -678,8 +678,8 @@
{
       /* Finish setting up the DEVICE info. */
       dev->mtu             = AX_MTU;
-       dev->hard_header_len = 0;
-       dev->addr_len        = 0;
+       dev->hard_header_len    = AX25_MAX_HEADER_LEN;
+       dev->addr_len           = AX25_ADDR_LEN;
       dev->type            = ARPHRD_AX25;
       dev->tx_queue_len    = 10;
       dev->header_ops      = &ax_header_ops;


Reason:
if you plug off i.e. your usb-serial-adapter, the driver re-initializes, with dev->hard_header_len and dev->addr_len set to zero, instead of the correct values.
If afterwards a packet should be sent to the half-dead interface, it causes a kernel panic.
These device parameters are used in other parts of the IP-stack when calculating the necessary room for the skb. After a packet goes to the mkiss driver for being sent out, there's no room left in the skb, due to the reserved length of 0. If skb_push pushes the ax25-header to the skb with no room left, we panic.

The panic looked like this:
=>
>> [<c0595468>] (skb_panic) from [<c0401f70>] (skb_push+0x4c/0x50)
>> [<c0401f70>] (skb_push) from [<bf0bdad4>] (ax25_hard_header+0x34/0xf4 [ax25])
>> [<bf0bdad4>] (ax25_hard_header [ax25]) from [<bf0d05d4>] (ax_header+0x38/0x40 [mkiss])
>> [<bf0d05d4>] (ax_header [mkiss]) from [<c041b584>] (neigh_compat_output+0x8c/0xd8)
>> [<c041b584>] (neigh_compat_output) from [<c043e7a8>] (ip_finish_output+0x2a0/0x914)
>> [<c043e7a8>] (ip_finish_output) from [<c043f948>] (ip_output+0xd8/0xf0)
>> [<c043f948>] (ip_output) from [<c043f04c>] (ip_local_out_sk+0x44/0x48)


This patch makes mkiss behave like the 6pack driver. 6pack does not panic.
In 6pack.c sp_setup() (same function name here) the values for dev->hard_header_len and dev->addr_len are set to the same values as in my mkiss patch.

vy 73,
	- Thomas  dl9sau
