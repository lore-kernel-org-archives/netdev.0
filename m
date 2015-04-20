From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/2] net: Fix "hw csum failure" message flood for ppp tunnel
Date: Mon, 20 Apr 2015 14:10:03 -0700
Message-ID: <1429564205-1661247-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47497 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751997AbbDTVKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 17:10:15 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t3KL9kqS021508
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 14:10:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1tw7pwr4y0-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 14:10:15 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a2ff1434e7a111e4b3f20002c9521c9e-b68a42c0 for <netdev@vger.kernel.org>;	Mon,
 20 Apr 2015 14:10:13 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses bug "Bug 95171 - "hw csum failure" message
flood for ppp tunnel since upgrade to 3.16". The problem is that pppoe
is being used over UDP with UDP checksusm enabled. On receive
checksum conversion turns checksum-unnecessary in checksum-
complete. The PPP receive functions do no properly pull
the checksum over its headers, so that when an encapsulated
checksums is considered the checksum-complete value is incorrect.

This patch adds skb_checksum_complete_unset which can be called
in the receive path in lieu of pulling checksum complete in
layer. This is useful when the packet is being modified (e.g.
decompressed) and the checksum-complete value is no longer
relevant.

In the ppp_receive_frame we call skb_checksum_complete_unset to toss
out checksum-complete. This should eliminate the reported messages.
Alternatively, we could add skb_postpull_rcsum and probably
special case handling for VJ compression if maintaining the
checksum-complete is needed (not clear to me this is worth the
effort).

I haven't tested this since setting up the failure scenario doesn't
seem trivial to configure.
Tom Herbert (2):
  net: add skb_checksum_complete_unset
  ppp: call skb_checksum_complete_unset in ppp_receive_frame

 drivers/net/ppp/ppp_generic.c |  1 +
 include/linux/skbuff.h        | 12 ++++++++++++
 2 files changed, 13 insertions(+)

-- 
1.8.1
