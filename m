From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Bridge vlan malfunctions for vid greater than 63
Date: Tue, 20 Aug 2013 17:07:40 +0900
Message-ID: <1376986060.5740.7.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:37940 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab3HTIHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 04:07:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Bridge vlan behaves unexpectedly for certain vids.
These are examples on Fedora 19 x86_64:
- "bridge vlan show" command cannot retrieve vids greater than 63,
  even if patch 3e805ad (using ifinfomsg instead of rtgenmsg) is
  applied.
- When we delete a vid, if no configured vid less than 64 remains,
  vlan_info will be freed prematurely, which could delete other
  configured vids.
- Parmanent fdb entries could not be deleted even if corresponding vid
  is deleted.

I'm afraid that some bitmap functions are given the number of elements
in a bitmap array (BR_VLAN_BITMAP_LEN), which is less than the bit
length.

Example:
static int br_fill_ifinfo(struct sk_buff *skb,
...
		if (!pv || bitmap_empty(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN))

As BR_VLAN_BITMAP_LEN is "BITS_TO_LONGS(VLAN_N_VID)", I tested after
changing BR_VLAN_BITMAP_LEN to VLAN_N_VID, and confirmed that this
resolves that malfunctions.

The following mail contains the patch described above.
Please comment if I misunderstood something.

Thanks,
Toshiaki Makita
