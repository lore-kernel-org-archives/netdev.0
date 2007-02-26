From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Mon, 26 Feb 2007 17:42:27 +1000
Message-ID: <45E28F63.8000208@snapgear.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061204000327.GE3625@electric-eye.fr.zoreil.com> <45D13578.8040405@snapgear.com> <20070213081439.GA21261@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0702131730570.14346@cnc.isely.net> <20070223231355.GA10930@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mike Isely <isely@pobox.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:57263 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932785AbXBZHnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 02:43:31 -0500
In-Reply-To: <20070223231355.GA10930@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> The experimental r8169 patch of the day against 2.6.21-rc1 is available at:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc1/

Is 0006-r8169-confusion-between-hardware-and-IP-header-alignment.txt
the only relevant patch?

This only partially helps.  Many of the packets are greater than 200
bytes so copybreak doesn't apply to them.

Can we assume anything about the alignment of skb->data?  I think it
should be 4 byte aligned, otherwise the whole NET_IP_ALIGN thing
won't work.  All the drivers I looked at just reserve NET_IP_ALIGN
without checking the alignment first.

So can you do something like set align to 0 for RTL_CFG_0 and change
rtl8169_alloc_rx_skb() to:
	skb_reserve(skb, align ? (align - 1) & (u32)skb->data : NET_IP_ALIGN);

BTW, should the alignment expression be:
	(((u32)skb->data + (align - 1)) & ~(align - 1)) - (u32)skb->data
