From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Fri, 28 Aug 2015 12:20:54 -0700
Message-ID: <1440789654.11525.137.camel@perches.com>
References: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <20150827.113823.214019265460582055.davem@davemloft.net>
	 <55E00238.10909@linux.vnet.ibm.com>
	 <20150828.112413.424099339331017970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: raghavendra.kt@linux.vnet.ibm.com, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150828.112413.424099339331017970.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-28 at 11:24 -0700, David Miller wrote:
> From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> Date: Fri, 28 Aug 2015 12:09:52 +0530
> 
> > On 08/28/2015 12:08 AM, David Miller wrote:
> >> From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> >> Date: Wed, 26 Aug 2015 23:07:33 +0530
> >>
> >>> @@ -4641,10 +4647,12 @@ static inline void __snmp6_fill_stats64(u64
> >>> *stats, void __percpu *mib,
> >>>   static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int
> >>>   attrtype,
> >>>   			     int bytes)
> >>>   {
> >>> +	u64 buff[IPSTATS_MIB_MAX] = {0,};
> >>> +
>  ...
> > hope you wanted to know the overhead than to change the current
> > patch. please let me know..
> 
> I want you to change that variable initializer to an explicit memset().
> 
> The compiler is emitting a memset() or similar _anyways_.
> 
> Not because it will have any impact at all upon performance, but because
> of how it looks to people trying to read and understand the code.

I don't read it as particularly different.

There are > 100 uses of the not quite a memset initialization
style using "= { <0,> }" in net/

$ git grep -E "=\s*\{\s*0?\s*,?\s*\}" net | wc -l
138

There is a difference though if a struct is copied to
user-space as a {} initialization only guarantees that
struct members are initialized to 0 where memset also
zeros any alignment padding.

Maybe a checkpatch rule like this?
---
 scripts/checkpatch.pl | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index e14dcdb..f79e5c9 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3237,6 +3237,13 @@ sub process {
 			next;
 		}
 
+# check for non-global initializations that could be memset
+		if ($realfile =~ m@^(drivers/net/|net/)@ &&
+		    $sline =~ /^.\s+$Declare\s*$Ident\s*=\s*\{\s*0?\s*,?\s*\}/) {
+			CHK("BRACE_INITIALIZATION",
+			    "Prefer an explicit memset to a declaration initialization\n" . $herecurr);
+		}
+
 # check for initialisation to aggregates open brace on the next line
 		if ($line =~ /^.\s*{/ &&
 		    $prevline =~ /(?:^|[^=])=\s*$/) {
