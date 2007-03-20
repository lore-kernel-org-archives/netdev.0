From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG?] ip ru flush && RTNETLINK answers: Numerical result
	out of range
Date: Tue, 20 Mar 2007 07:19:51 +0100
Message-ID: <45FF7D07.4040103@trash.net>
References: <200703190046.47021.luciano@lugmen.org.ar>
	<45FE2587.3050205@trash.net> <20070319152532.GL521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080001090807020500090204"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, lartc@mailman.ds9a.nl
To: Thomas Graf <tgraf@suug.ch>
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <20070319152532.GL521@postel.suug.ch>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080001090807020500090204
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2007-03-19 06:54
> 
>>Thomas, I can't see a clean way to fix this right now that
>>doesn't either bloat struct nla_policy or removes FRA_SRC/FRA_DST
>>from the policy, could you please look into this? Thanks.
> 
> 
> I guess the only way is to remove FRA_SRC/FRA_DST from the policy
> and validate it in configure() based on src_len/dst_len.


Its not too pretty, but I agree. This patch fixes the problem.
I'll also push it to -stable.

--------------080001090807020500090204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Fix fib_rules compatibility breakage

The fib_rules netlink attribute policy introduced in 2.6.19 broke
userspace compatibilty. When specifying a rule with "from all"
or "to all", iproute adds a zero byte long netlink attribute,
but the policy requires all addresses to have a size equal to
sizeof(struct in_addr)/sizeof(struct in6_addr), resulting in a
validation error.

Fix by only looking at the FRA_SRC/FRA_DST attributes if src_len
or dst_len is larger than zero.

DECnet is unaffected since iproute doesn't support specifying
addresses as "all".

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 39f42dd26f1f9c93b9700e1bace540ed9bb94e46
tree ecc71ef742d9d636bf129b34ae7a18173377ccc0
parent db98e0b434a6265c451ffe94ec0a29b8d0aaf587
author Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 07:08:38 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 07:08:38 +0100

 net/ipv4/fib_rules.c  |   18 ++++++++++++------
 net/ipv6/fib6_rules.c |   16 ++++++++++++----
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index b837c33..9524b2e 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -171,8 +171,6 @@ static struct fib_table *fib_empty_table
 
 static struct nla_policy fib4_rule_policy[FRA_MAX+1] __read_mostly = {
 	FRA_GENERIC_POLICY,
-	[FRA_SRC]	= { .type = NLA_U32 },
-	[FRA_DST]	= { .type = NLA_U32 },
 	[FRA_FLOW]	= { .type = NLA_U32 },
 };
 
@@ -187,6 +185,12 @@ static int fib4_rule_configure(struct fi
 	    (frh->tos & ~IPTOS_TOS_MASK))
 		goto errout;
 
+	if (frh->src_len && tb[FRA_SRC] && nla_len(tb[FRA_SRC]) != sizeof(u32))
+		goto errout;
+
+	if (frh->dst_len && tb[FRA_DST] && nla_len(tb[FRA_DST]) != sizeof(u32))
+		goto errout;
+
 	if (rule->table == RT_TABLE_UNSPEC) {
 		if (rule->action == FR_ACT_TO_TBL) {
 			struct fib_table *table;
@@ -201,10 +205,10 @@ static int fib4_rule_configure(struct fi
 		}
 	}
 
-	if (tb[FRA_SRC])
+	if (frh->src_len && tb[FRA_SRC])
 		rule4->src = nla_get_be32(tb[FRA_SRC]);
 
-	if (tb[FRA_DST])
+	if (frh->dst_len && tb[FRA_DST])
 		rule4->dst = nla_get_be32(tb[FRA_DST]);
 
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -242,10 +246,12 @@ #ifdef CONFIG_NET_CLS_ROUTE
 		return 0;
 #endif
 
-	if (tb[FRA_SRC] && (rule4->src != nla_get_be32(tb[FRA_SRC])))
+	if (frh->src_len && tb[FRA_SRC] &&
+	    (rule4->src != nla_get_be32(tb[FRA_SRC])))
 		return 0;
 
-	if (tb[FRA_DST] && (rule4->dst != nla_get_be32(tb[FRA_DST])))
+	if (frh->dst_len && tb[FRA_DST] &&
+	    (rule4->dst != nla_get_be32(tb[FRA_DST])))
 		return 0;
 
 	return 1;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 0862809..a15244e 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -145,6 +145,14 @@ static int fib6_rule_configure(struct fi
 	if (frh->src_len > 128 || frh->dst_len > 128)
 		goto errout;
 
+	if (frh->src_len && tb[FRA_SRC] &&
+	    nla_len(tb[FRA_SRC]) != sizeof(struct in6_addr))
+		goto errout;
+
+	if (frh->dst_len && tb[FRA_DST] &&
+	    nla_len(tb[FRA_DST]) != sizeof(struct in6_addr))
+		goto errout;
+
 	if (rule->action == FR_ACT_TO_TBL) {
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
@@ -155,11 +163,11 @@ static int fib6_rule_configure(struct fi
 		}
 	}
 
-	if (tb[FRA_SRC])
+	if (frh->src_len && tb[FRA_SRC])
 		nla_memcpy(&rule6->src.addr, tb[FRA_SRC],
 			   sizeof(struct in6_addr));
 
-	if (tb[FRA_DST])
+	if (frh->dst_len && tb[FRA_DST])
 		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
 			   sizeof(struct in6_addr));
 
@@ -186,11 +194,11 @@ static int fib6_rule_compare(struct fib_
 	if (frh->tos && (rule6->tclass != frh->tos))
 		return 0;
 
-	if (tb[FRA_SRC] &&
+	if (frh->src_len && tb[FRA_SRC] &&
 	    nla_memcmp(tb[FRA_SRC], &rule6->src.addr, sizeof(struct in6_addr)))
 		return 0;
 
-	if (tb[FRA_DST] &&
+	if (frh->dst_len && tb[FRA_DST] &&
 	    nla_memcmp(tb[FRA_DST], &rule6->dst.addr, sizeof(struct in6_addr)))
 		return 0;
 


--------------080001090807020500090204
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
LARTC mailing list
LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc

--------------080001090807020500090204--
