From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 0/3] [v3] Revert Backoff on ICMP destination unreachable
Date: Wed, 26 Aug 2009 12:16:22 +0200
Message-ID: <4A950B76.1070002@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:38208 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756793AbZHZKQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 06:16:22 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOZ00GTVB7BUDA0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 26 Aug 2009 12:16:23 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n7QAGM9h012735	for
 <netdev@vger.kernel.org>; Wed, 26 Aug 2009 12:16:23 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches implements the TCP improvement of the Internet Draft
"Make TCP more Robust to Long Connectivity Disruptions"
(http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).

Exponential backoff is TCP's standard behaviour during long connectivity
disruptions, which is a countermeasure against network congestion.
If congestion can be excluded as the reason for RTO retransmission loss,
backoff is not desirable, as it yields longer TCP recovery times, when
the communication path is repaired shortly after an unsuccessful
retransmission probe.

1) This patch renames the skb in tcp_v4_err() in preparation for patch 2.
2) Contains the main reversion logic.
   Reintroduces tcp_bound_rto() and __tcp_set_rto()
3) This patch modifies the interpretation of the tcp_retries{1,2} sysctls.
   It became necessary because with patch2 the assumption that the number
   of retransmits corresponds to an specific timeout value is not accurate
   anymore. With this patch tcp_retries{1,2} specifies a timeout value,
   equivalent to the time a connection with an rto value of MIN_RTO (200ms)
   would need to retransmit N segments. IOW: The meaning (in sense of time)
   is mostly preserved, but the actual connection timeout does not depend
   on the calculated rto of the connection, anymore.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
