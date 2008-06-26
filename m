From: Joonwoo Park <joonwpark81@gmail.com>
Subject: Re: [PATCH 6/8 v2] netfilter: fix string extension for case
	insensitive pattern matching
Date: Wed, 25 Jun 2008 19:12:41 -0700
Message-ID: <20080626021241.GA26212@tp64>
References: <1214389505-21405-1-git-send-email-joonwpark81@gmail.com> <4862260A.9060304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4862260A.9060304@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2008 at 01:03:38PM +0200, Patrick McHardy wrote:
> Joonwoo Park wrote:
>> The flag XT_STRING_FLAG_IGNORECASE indicates case insensitive string
>> matching.
>> netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.
>
> I've asked you to provide some more information about this patch:
>
> <quote>
> A few words for the changelog why this won't break compatibility
> by changing the data structure would be nice, especially
> considering CRIS that doesn't perform any padding itself (you
> might be lucky though because of aligned attribute, but please
> verify that yourself).
> </quote>
>

I missed it and added few words for the changelog.

Thanks Patrick!

---
netfilter: fix string extension for case insensitive pattern matching

The flag XT_STRING_FLAG_IGNORECASE indicates case insensitive string
matching.
netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.

Also this patch won't break compatibility since we have 2 bytes space
between invert and config, due to config was 8 bytes aligned.
So we can put a new value 'flags' in xt_string_info between invert and
config safely.
If previous version of iptables interact with this kernel, to kernel
side, flags will be set to zero and to user side, flags will be ignored.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/netfilter/xt_string.h |    3 +++
 net/netfilter/xt_string.c           |    5 ++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
index bb21dd1..2de02e9 100644
--- a/include/linux/netfilter/xt_string.h
+++ b/include/linux/netfilter/xt_string.h
@@ -4,6 +4,8 @@
 #define XT_STRING_MAX_PATTERN_SIZE 128
 #define XT_STRING_MAX_ALGO_NAME_SIZE 16
 
+#define XT_STRING_FLAG_IGNORECASE 0x01
+
 struct xt_string_info
 {
 	u_int16_t from_offset;
@@ -12,6 +14,7 @@ struct xt_string_info
 	char 	  pattern[XT_STRING_MAX_PATTERN_SIZE];
 	u_int8_t  patlen;
 	u_int8_t  invert;
+	u_int8_t  flags;
 
 	/* Used internally by the kernel */
 	struct ts_config __attribute__((aligned(8))) *config;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index 72f694d..853ca35 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -46,6 +46,7 @@ string_mt_check(const char *tablename, const void *ip,
 {
 	struct xt_string_info *conf = matchinfo;
 	struct ts_config *ts_conf;
+	int flags = TS_AUTOLOAD;
 
 	/* Damn, can't handle this case properly with iptables... */
 	if (conf->from_offset > conf->to_offset)
@@ -54,8 +55,10 @@ string_mt_check(const char *tablename, const void *ip,
 		return false;
 	if (conf->patlen > XT_STRING_MAX_PATTERN_SIZE)
 		return false;
+	if (conf->flags & XT_STRING_FLAG_IGNORECASE)
+		flags |= TS_IGNORECASE;
 	ts_conf = textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
-				     GFP_KERNEL, TS_AUTOLOAD);
+				     GFP_KERNEL, flags);
 	if (IS_ERR(ts_conf))
 		return false;
 
-- 
1.5.4.3
---
