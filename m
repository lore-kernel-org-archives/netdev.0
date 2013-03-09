From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: igb driver triggers BUILD_BUG_ON on s390
Date: Sat, 9 Mar 2013 11:00:04 +0100
Message-ID: <20130309100004.GA3584@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:41792 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756145Ab3CIKAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 05:00:09 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Sat, 9 Mar 2013 09:57:37 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 088E01B08066
	for <netdev@vger.kernel.org>; Sat,  9 Mar 2013 10:00:06 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r299xuHC30015646
	for <netdev@vger.kernel.org>; Sat, 9 Mar 2013 09:59:56 GMT
Received: from d06av08.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r29A05Cd007578
	for <netdev@vger.kernel.org>; Sat, 9 Mar 2013 03:00:05 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

git commit 74e238ead "igb: Support using build_skb in the case that
jumbo frames are disabled" added a BUILD_BUG_ON() to the igb drivers
which triggers on s390:

drivers/net/ethernet/intel/igb/igb_main.c:6231:2:
error: call to =E2=80=98__compiletime_assert_6235=E2=80=99 declared wit=
h attribute error:
  BUILD_BUG_ON failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) <
    (NET_SKB_PAD + NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH_FRAME_LEN + ETH_=
=46CS_LEN)

This happens mainly because s390 has an unusual large L1_CACHE_BYTES ak=
a
SMP_CACHE_BYTES define with 256 Bytes.

The BUILD_BUG_ON(..) translates to (taken from .i file):

__cond =3D !(!(((2048) - (((sizeof(struct skb_shared_info)) + (256 - 1)=
) & ~(256 - 1))) < (32 + 2 + 16 + 1514 + 4)));

With sizeof(struct skb_shared_info) =3D=3D 320 we end up with

BUILD_BUG_ON((2048 - 512 =3D 1536) < 1568)

One possible solution would be to simply disable the driver on s390.
Any opinions?
