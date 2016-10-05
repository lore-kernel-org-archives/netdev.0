From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Subject: [PATCH net] Fixing a bug in team driver due to incorrect 'unsigned  int' to 'int' conversion
Date: Wed, 05 Oct 2016 09:06:04 -0400
Message-ID: <2440068.EFRMUI8i5V@zbook>
References: <3444639.ILgt5kU9OR@zbook> <1475636928.28155.196.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:11560 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbcJENGI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 09:06:08 -0400
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com [15.241.140.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 60FB8110C
        for <netdev@vger.kernel.org>; Wed,  5 Oct 2016 13:06:07 +0000 (UTC)
In-Reply-To: <1475636928.28155.196.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roundrobin runner of team driver uses 'unsigned int' variable to count the number of sent_packets.
Later it is passed to a subroutine team_num_to_port_index(struct team *team, int num) as
'num' and when we reach MAXINT (2**31-1), 'num' becomes negative.

This leads to using incorrect hash-bucket for port lookup and as a result, packets are dropped. The fix
consists of changing 'int num' to 'unsigned int num'. Testing of a fixed kernel shows that there
is no packet drop anymore.


Signed-off-by: Alex Sidorenko <alexandre.sidorenko@hpe.com>

---
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
 


-- 

------------------------------------------------------------------
Alex Sidorenko	email: asid@hpe.com
ERT  Linux 	Hewlett-Packard Enterprise (Canada)
------------------------------------------------------------------
