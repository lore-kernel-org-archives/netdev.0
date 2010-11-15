From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] r8169: fix checksum broken
Date: Mon, 15 Nov 2010 11:31:32 +0800
Message-ID: <4CE0A994.4080606@cn.fujitsu.com>
References: <4CDD13BD.7060109@cn.fujitsu.com> <20101112224746.GA6676@electric-eye.fr.zoreil.com> <20101112231325.GB6676@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54691 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751901Ab0KODdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 22:33:06 -0500
In-Reply-To: <20101112231325.GB6676@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote, at 11/13/2010 07:13 AM:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>> Which kind of device do you use : PCI-E 8168 / 810x or PCI 8169 ?
> 
> Wrong page. Forget it.
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

While grepping IPFail variable, maybe cp_rx_csum_ok() in 8139cp driver also has same bug.
There is no NIC on hand using RealTek RTL-8139C+ series 10/100 PCI Ethernet driver, 
So don't confirm it.

===
[PATCH] 8139cp: fix checksum broken

I am not family with RealTek RTL-8139C+ series 10/100 PCI Ethernet driver. 
I try to guess the meaning of RxProtoIP and IPFail. 
RxProtoIP stands for received IPv4 packet that upper protocol is not tcp and udp. 
!(status & IPFail) is true means that driver correctly to check checksum in IPv4 header.

If these are right, driver will set ip_summed with CHECKSUM_UNNECESSARY for other
upper protocol, e.g. sctp, igmp protocol. This will cause protocol stack ignores 
checksum check for packets with invalid checksum. 

This patch is only compile-test.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/8139cp.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index ac422cd..dd16e83 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -490,13 +490,11 @@ static inline unsigned int cp_rx_csum_ok (u32 status)
 {
 	unsigned int protocol = (status >> 16) & 0x3;
 
-	if (likely((protocol == RxProtoTCP) && (!(status & TCPFail))))
+	if (((protocol == RxProtoTCP) && !(status & TCPFail)) ||
+	    ((protocol == RxProtoUDP) && !(status & UDPFail)))
 		return 1;
-	else if ((protocol == RxProtoUDP) && (!(status & UDPFail)))
-		return 1;
-	else if ((protocol == RxProtoIP) && (!(status & IPFail)))
-		return 1;
-	return 0;
+	else
+		return 0;
 }
 
 static int cp_rx_poll(struct napi_struct *napi, int budget)
-- 
1.6.3.3
