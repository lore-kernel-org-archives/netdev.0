From: Alexey Dobriyan <adobriyan@openvz.org>
Subject: Re: igmp: possible NULL dereference after GFP_ATOMIC allocation?
Date: Tue, 30 Jan 2007 18:04:27 +0300
Message-ID: <20070130150427.GB11121@localhost.sw.ru>
References: <20070130105701.GA6015@localhost.sw.ru> <OF52248A96.35A5CA3C-ON88257273.003E5791-88257273.003F9122@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:25877 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965565AbXA3O61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 09:58:27 -0500
Content-Disposition: inline
In-Reply-To: <OF52248A96.35A5CA3C-ON88257273.003E5791-88257273.003F9122@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 30, 2007 at 03:34:18AM -0800, David Stevens wrote:
>         I think you're correct-- looks like it needs:
>
>         if (!skb)
>                 return NULL;
>
> just before the skb_put(), since an allocation (and failure)
> could occur in either the igmpv3_newpack() call or in add_grhead().
>         Also, similar code in net/ipv6/mcast..c.
>
>         Will you be submitting the patch?

One box here can semi-reliably reproduce oops which is attributed to
these allocation failures. I'll tell if patch works or not soon.

BUG: unable to handle kernel NULL pointer dereference at virtual address 00000064
 EIP is at add_grec+0x22b/0x372
 eax: 00000000   ebx: 00000000   ecx: f567cb20   edx: f567cb20
 esi: e91ad540   edi: 00000001   ebp: 00000000   esp: c0787f54
 ds: 007b   es: 007b   ss: 0068
 Process swapper (pid: 0, veid: 0, ti=c0787000 task=c0670be0 task.ti=c073e000)
 Stack: c0787f80 00000001 00000005 e08a8920 c930a800 00000000 e08a892c 00000000
        00000000 00000000 00000000 00000000 e08a8920 e2000ea0 00000000 00000005
        c05f1510 00000000 00000001 00000000 c0678580 c07fbb00 00000100 c05f13ac
 Call Trace:
  [<c05f1510>] igmp_ifc_timer_expire+0x164/0x1db
  [<c042cd17>] run_timer_softirq+0x116/0x18d
  [<c0427ea8>] __do_softirq+0x84/0x109
  [<c0406234>] do_softirq+0x55/0xad
  =======================
 Code: fa ff ff 89 c3 c7 44 24 1c 00 00 00 00 eb 04 85 ff 74 18 8b 4c 24 08 8d 44 24 2c 8b 54 24 0c 89 04 24 89 d8 e8 66 fc ff ff 89 c3 <83> 7b 64 00 8b bb a0 00 00 00 74 0b 0f 0b 66 b8 5a 03 b8 52 e9
 EIP: [<c05f1265>] add_grec+0x22b/0x372 SS:ESP 0068:c0787f54
 Kernel panic - not syncing: Fatal exception in interrupt

