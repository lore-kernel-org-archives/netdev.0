From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sk-filter: Rate-limit WARNing, print dbg info.
Date: Tue, 17 May 2011 12:53:40 -0700
Message-ID: <1305662020.1722.42.camel@Joe-Laptop>
References: <1305657014-32736-1-git-send-email-greearb@candelatech.com>
	 <1305658349.1722.30.camel@Joe-Laptop>
	 <20110517.152357.85105240786269960.davem@davemloft.net>
	 <4DD2CDA9.7000009@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1720 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932084Ab1EQTxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 15:53:42 -0400
In-Reply-To: <4DD2CDA9.7000009@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 12:34 -0700, Ben Greear wrote:
> On 05/17/2011 12:23 PM, David Miller wrote:
> > From: Joe Perches<joe@perches.com>
> >> On Tue, 2011-05-17 at 11:30 -0700, greearb@candelatech.com wrote:
> >>> From: Ben Greear<greearb@candelatech.com>
> >>> A mis-configured filter can spam the logs with
> >>> lots of stack traces.  Rate-limit the warnings
> >>> and add printout of the bogus filter information.
> >>> -			WARN_ON(1);
> >>> +			if (net_ratelimit()) {
> >>> +				pr_err("filter: Unknown code: %hu jt: %u tf: %u"
> >>> +				       " k: %u\n",
> >>> +				       fentry->code, (unsigned int)(fentry->jt),
> >>> +				       (unsigned int)(fentry->jf), fentry->k);
> >>> +				WARN_ON(1);
> >>> +			}
> >> Maybe just using WARN is better.
> > Yep, it looks better to me.
> You want to just take his, or shall I re-spin it?
> Either is fine with me.

Another option is to add a WARN_ON_RATELIMIT
(there is already a WARN_RATELIMIT) to avoid
missing other messages.

Something like:

 include/asm-generic/bug.h |   16 ++++++++++++++++
 net/core/filter.c         |    4 +++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
index e5a3f58..12b250c 100644
--- a/include/asm-generic/bug.h
+++ b/include/asm-generic/bug.h
@@ -165,6 +165,22 @@ extern void warn_slowpath_null(const char *file, const int line);
 #define WARN_ON_RATELIMIT(condition, state)			\
 		WARN_ON((condition) && __ratelimit(state))
 
+#define __WARN_RATELIMIT(condition, state, format...)		\
+({								\
+	int rtn = 0;						\
+	if (unlikely(__ratelimit(state)))			\
+		rtn = WARN(condition, format);			\
+	rtn;							\
+})
+
+#define WARN_RATELIMIT(condition, format...)			\
+({								\
+	static DEFINE_RATELIMIT_STATE(_rs,			\
+				      DEFAULT_RATELIMIT_INTERVAL,	\
+				      DEFAULT_RATELIMIT_BURST);	\
+	__WARN_RATELIMIT(condition, &_rs, format);		\
+})
+
 /*
  * WARN_ON_SMP() is for cases that the warning is either
  * meaningless for !SMP or may even cause failures.
diff --git a/net/core/filter.c b/net/core/filter.c
index 0eb8c44..0e3622f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -350,7 +350,9 @@ load_b:
 			continue;
 		}
 		default:
-			WARN_ON(1);
+			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
+				       fentry->code, fentry->jt,
+				       fentry->jf, fentry->k);
 			return 0;
 		}
 	}


