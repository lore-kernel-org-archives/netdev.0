From: "Alan J. Wylie" <alan@wylie.me.uk>
Subject: skb_pull_rcsum - Fatal exception in interrupt
Date: Wed, 15 Aug 2007 16:07:23 +0100
Message-ID: <18115.5803.588114.372952@wylie.me.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wylie.me.uk ([82.68.155.89]:43958 "EHLO mail.wylie.me.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758909AbXHOPHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 11:07:24 -0400
Received: from frodo.localnet (frodo.localnet [192.168.21.2])
	by mail.wylie.me.uk (Postfix) with ESMTP id 9F006FC002
	for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 16:07:23 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We have been shipping Linux based servers to customers for several
years now, with few problems. Recently, however, a single customer has
been seeing kernel panics. Unfortunately, the customer is about 200
miles away, so physical access is limited. There are two ethernet
interfaces, one should be plugged into a local RFC1918 network, the
other is connected to the internet. If eth0 is plugged into the local
network, a short time later the system panics.

Hardware: Intel S5000VSA server

Network cards: Intel e1000
   Intel Corporation 80003ES2LAN Gigabit Ethernet Controller (Copper) 

We shipped a second system, and this displayed identical symptoms.  We
have tested with several recent 2.6 kernels, including

2.6.22
2.6.17.14
2.6.20.15

all of which crash.

We have a couple of photographs showing the tail end of the messages
on the screen.

The last two lines are:

EIP: [<c02b6fb2>] skb_pull_rcsum+0x6d/0x71 SS:ESP 09068:c03e1ea4
Kernel panic - not syncing: Fatal exception in interrupt

The photos, along with the following information are available at
http://wylie.me.uk/skb_pull_rcsum/

lspci
lspci -n
lspci -v
ethtool -d
/proc/interrupts
kernel config

There are no related messages in the syslog files.

The code for skb_pull_rcsum is short, but contains two calls
to BUG_ON, checking for invalid lengths.

unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
{
        BUG_ON(len > skb->len);
        skb->len -= len;
        BUG_ON(skb->len < skb->data_len);
        skb_postpull_rcsum(skb, skb->data, len);
        return skb->data += len;
}

I wonder whether this problem bears any resemblance to 

http://bugzilla.kernel.org/show_bug.cgi?id=2979

| We were overreacting to invalid incoming AppleTalk frames. Better
| just drop invalid frames than crash the kernel ;)

<http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=75559c167bddc1254db5bcff032ad5eed8bd6f4a>

| [APPLETALK]: Fix a remotely triggerable crash

| When we receive an AppleTalk frame shorter than what its header
| says, we still attempt to verify its checksum, and trip on the
| BUG_ON() at the end of function atalk_sum_skb() because of the
| length mismatch.

| This has security implications because this can be triggered by
| simply sending a specially crafted ethernet frame to a target
| victim, effectively crashing that host. Thus this qualifies, I
| think, as a remote DoS.

Our system is also installed in a school. We have remote access to the
box, and can, with some inconvenience, arrange for the box to be
rebooted. We are currently arranging for two different network cards
(RealTek RTL8139) to be installed.

I am pretty certain that the problem is to do with network traffic,
rather than hardware or software configurations - this box is pretty
well identical to tens of other boxes working successfully, the only
difference being that recently the on-board ethernet changed from
8086:1079 (rev 03) to 8086:1096 (rev 01) requiring an updated e1000
driver.

What is the best way to track this bug down, remembering that we have
little more than ssh access and a remote finger to press the reboot
button?

Could we modify the code to log and drop the packet, rather than
panicking the kernel?

-- 
Alan J. Wylie                                          http://www.wylie.me.uk/
"Perfection [in design] is achieved not when there is nothing left to add,
but rather when there is nothing left to take away."
  -- Antoine de Saint-Exupery
