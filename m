From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 38/44] [IPV6] MIP6: Ignore to report if mobility headers is rejected.
Date: Thu, 24 Aug 2006 00:02:39 +0900
Message-ID: <11563453671463-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org> <11563453672531-git-send-email-yoshfuji@linux-ipv6.org> <11563453674194-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:10889 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964953AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <11563453674194-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Ignore to report user-space for known mobility headers rejected by
destination options header transformation.
Mobile IPv6 specification (RFC3775) says that mobility header
is used with destination options header carrying home address option
only for binding update message. Other type message cannot be used
and node must drop it silently (and must not send binding error) if
receving such packet.
To achieve it, (1) application should use transformation policy and
wild-card states to catch binding update message prior other packets
(2) kernel doesn't report the reject to user-space not to send
binding error message by application.
This patch is for (2).
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mip6.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 31445d0..7085403 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -234,6 +234,9 @@ static int mip6_destopt_reject(struct xf
 	struct timeval stamp;
 	int err = 0;
 
+	if (unlikely(fl->proto == IPPROTO_MH && fl->fl_mh_type <= IP6_MH_TYPE_MAX))
+		goto out;
+
 	if (likely(opt->dsthao)) {
 		offset = ipv6_find_tlv(skb, opt->dsthao, IPV6_TLV_HAO);
 		if (likely(offset >= 0))
-- 
1.4.0

