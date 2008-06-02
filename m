From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist outgoing
 interface
Date: Mon, 02 Jun 2008 12:14:58 -0400
Message-ID: <48441C82.1070609@hp.com>
References: <4843AB51.6010206@cn.fujitsu.com> <20080602.172009.84304151.yoshfuji@linux-ipv6.org> <4843B65C.1060702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040102040208000703090006"
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:25440 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972AbYFBQPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 12:15:01 -0400
In-Reply-To: <4843B65C.1060702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040102040208000703090006
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Shan Wei wrote:
>   When specifying the outgoing interface with sendmsg, if the ipi6_addr is 
> the unspecified address and the ipi6_ifindex is the not-exist interface, 
> it should be fail and the errno should be set ENODEV.
>   Actually, it does well(sendmsg returns on success ), because the kernel 
> don't check the interface。

This patch changes this code path to be different than most others that 
completely ignore the device for the unspecified address - for example 
inet6_bind() and rawv6_bind().  Those paths only care about the device 
for a link-local address, so I don't think this patch is correct.

In the current git tree, this :: address is going to turn-into ::1, so 
the ifindex is irrelevant, the packet will be looped-back.  Older 
kernels could transmit the packet on the wire using the default route. 
Can you elaborate on the problem you were seeing?

I did notice a slight problem where if fl->oif is set in the caller (for 
example via SO_BINDTODEVICE), it's ignored in datagram_send_ctl() if 
src_info->ipi6_ifindex is zero, attached patch fixes that.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------040102040208000703090006
Content-Type: text/x-diff;
 name="datagram_send_ctl.floif.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="datagram_send_ctl.floif.patch"

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..b6a7c7b 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -541,7 +541,7 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 				break;
 
 			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
+				if (!fl->oif)
 					return -EINVAL;
 				else {
 					dev = dev_get_by_index(&init_net, src_info->ipi6_ifindex);

--------------040102040208000703090006--
