From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/2] average: provide macro to create static EWMA
Date: Thu, 13 Aug 2015 11:11:48 +0200
Message-ID: <1439457109-21833-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46995 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425AbbHMJLx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 05:11:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Having the EWMA parameters stored in the runtime struct imposes
memory requirements for the constant values that could just be
inlined in the code. This particularly makes sense if there are
a lot of such structs, for example in mac80211 in the station
table where each station has a number of these in an array, and
there can be many stations.

Provide a macro DECLARE_EWMA() that declares the necessary struct
and inline functions to access it with the parameters hard-coded;
using this also means the user no longer needs to 'select AVERAGE'
as it's entirely self-contained.

In the mac80211 case, on x86-64, this actually slightly *reduces*
code size, while also saving 80 bytes of runtime memory per sta.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
As the next patch relies on this, I'll take this through my tree
unless I hear objections.
---
 include/linux/average.h | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/include/linux/average.h b/include/linux/average.h
index c6028fd742c1..802adeab7037 100644
--- a/include/linux/average.h
+++ b/include/linux/average.h
@@ -27,4 +27,43 @@ static inline unsigned long ewma_read(const struct ewma *avg)
 	return avg->internal >> avg->factor;
 }
 
+#define DECLARE_EWMA(name, _factor, _weight)				\
+	struct ewma_##name {						\
+		unsigned long internal;					\
+	};								\
+	static inline void ewma_##name##_init(struct ewma_##name *e)	\
+	{								\
+		BUILD_BUG_ON(!__builtin_constant_p(_factor));		\
+		BUILD_BUG_ON(!__builtin_constant_p(_weight));		\
+		BUILD_BUG_ON(!is_power_of_2(_factor));			\
+		BUILD_BUG_ON(!is_power_of_2(_weight));			\
+		e->internal = 0;					\
+	}								\
+	static inline unsigned long					\
+	ewma_##name##_read(struct ewma_##name *e)			\
+	{								\
+		BUILD_BUG_ON(!__builtin_constant_p(_factor));		\
+		BUILD_BUG_ON(!__builtin_constant_p(_weight));		\
+		BUILD_BUG_ON(!is_power_of_2(_factor));			\
+		BUILD_BUG_ON(!is_power_of_2(_weight));			\
+		return e->internal >> ilog2(_factor);			\
+	}								\
+	static inline void ewma_##name##_add(struct ewma_##name *e,	\
+					     unsigned long val)		\
+	{								\
+		unsigned long internal = ACCESS_ONCE(e->internal);	\
+		unsigned long weight = ilog2(_weight);			\
+		unsigned long factor = ilog2(_factor);			\
+									\
+		BUILD_BUG_ON(!__builtin_constant_p(_factor));		\
+		BUILD_BUG_ON(!__builtin_constant_p(_weight));		\
+		BUILD_BUG_ON(!is_power_of_2(_factor));			\
+		BUILD_BUG_ON(!is_power_of_2(_weight));			\
+									\
+		ACCESS_ONCE(e->internal) = internal ?			\
+			(((internal << weight) - internal) +		\
+				(val << factor)) >> weight :		\
+			(val << factor);				\
+	}
+
 #endif /* _LINUX_AVERAGE_H */
-- 
2.1.4
