From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Subject: [PATCH net v2] Fixing a bug in team driver due to incorrect 'unsigned int' to 'int' conversion
Date: Fri, 07 Oct 2016 09:02:33 -0400
Message-ID: <14617987.qnk3Z4yzn3@zbook>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: eric.dumazet@gmail.com, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:44069 "EHLO
        g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756301AbcJGNCj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 09:02:39 -0400
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com [15.241.48.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 11CBA616D7
        for <netdev@vger.kernel.org>; Fri,  7 Oct 2016 13:02:38 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roundrobin runner of team driver uses 'unsigned int' variable to count
the number of sent_packets. Later it is passed to a subroutine
team_num_to_port_index(struct team *team, int num) as 'num' and when
we reach MAXINT (2**31-1), 'num' becomes negative.

This leads to using incorrect hash-bucket for port lookup
and as a result, packets are dropped. The fix consists of changing 
'int num' to 'unsigned int num'. Testing of a fixed kernel shows that
there is no packet drop anymore.


Signed-off-by: Alex Sidorenko <alexandre.sidorenko@hpe.com>


---
v2: fixed formatting

 include/linux/if_team.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 174f43f..c05216a 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -245,7 +245,7 @@ static inline struct team_port *team_get_port_by_index(struct team *team,
 	return NULL;
 }
 
-static inline int team_num_to_port_index(struct team *team, int num)
+static inline int team_num_to_port_index(struct team *team, unsigned int num)
 {
 	int en_port_count = ACCESS_ONCE(team->en_port_count);
 
-- 
2.7.4
