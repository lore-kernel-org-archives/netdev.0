From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 2/3] cgroup: make sure memcg margin is 0 when over limit
Date: Fri, 20 Jan 2012 18:57:15 +0400
Message-ID: <1327071436-20763-3-git-send-email-glommer@parallels.com>
References: <1327071436-20763-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1327071436-20763-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For the memcg sock code, we'll need to register allocations
that are temporarily over limit. Let's make sure that margin
is 0 in this case.

I am keeping this as a separate patch, so that if any weirdness
interaction appears in the future, we can now exactly what caused
it.

Suggested by Johannes Weiner 

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
CC: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
CC: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
CC: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
CC: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/res_counter.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index c9d625c..d06d014 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -142,7 +142,10 @@ static inline unsigned long long res_counter_margin(struct res_counter *cnt)
 	unsigned long flags;
 
 	spin_lock_irqsave(&cnt->lock, flags);
-	margin = cnt->limit - cnt->usage;
+	if (cnt->limit > cnt->usage)
+		margin = cnt->limit - cnt->usage;
+	else
+		margin = 0;
 	spin_unlock_irqrestore(&cnt->lock, flags);
 	return margin;
 }
-- 
1.7.7.4
