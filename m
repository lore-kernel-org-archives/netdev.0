From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/5 v2] netfilter: Fix format string of nfnetlink_log
 proc file
Date: Thu, 09 Apr 2015 15:39:37 -0700
Message-ID: <1428619177.5413.15.camel@perches.com>
References: <1428616637-21690-1-git-send-email-richard@nod.at>
	 <1428616637-21690-5-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, sameo@linux.intel.com,
	aloisio.almeida@openbossa.org, lauro.venancio@openbossa.org,
	davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net,
	pablo@netfilter.org
To: Richard Weinberger <richard@nod.at>,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428616637-21690-5-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-04-09 at 23:57 +0200, Richard Weinberger wrote:
> The printed values are all of type unsigned integer, therefore use
> %u instead of %d. Otherwise an user can face negative values.

Hey Richard.

Just to clarify, this patch is for net and not for net-next
as net-next has removed the seq_printf return uses.

Are you going to submit an equivalent patch for net-next?

> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
[]
> @@ -998,7 +998,7 @@ static int seq_show(struct seq_file *s, void *v)
>  {
>  	const struct nfulnl_instance *inst = v;
>  
> -	return seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
> +	return seq_printf(s, "%5u %6u %5u %1u %5u %6u %2u\n",
>  			  inst->group_num,
>  			  inst->peer_portid, inst->qlen,
>  			  inst->copy_mode, inst->copy_range,

And Steven,

commit e71456ae9871
("netfilter: Remove checks of seq_printf() return values")
mistakenly converted this to use seq_has_overflowed()

Ideally all seq_show functions would be converted from

int foo_seq_show(...)
{
	seq_printf(s, ...);
	return seq_has_overflowed(s);
}

to

int foo_seq_show(...)
{
	seq_printf(s, ...);
	return 0;
}

I made that mistake in a patch and corrected it later.

Here's a suggested -next patch:

Perhaps it shouldn't be submitted now as it may conflict
with what Richard might submit if he propses an equivalent
patch to above for -next.

There is an appropriate use of return seq_has_overflowed in: 

net/netfilter/xt_hashlimit.c:825:       return seq_has_overflowed(s);

That's not a seq_show function, it's a helper for one.

---
 net/netfilter/nfnetlink_queue_core.c |  3 ++-
 net/netfilter/x_tables.c             | 11 +++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 6e74655..5f827a1 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1248,7 +1248,8 @@ static int seq_show(struct seq_file *s, void *v)
 		   inst->copy_mode, inst->copy_range,
 		   inst->queue_dropped, inst->queue_user_dropped,
 		   inst->id_sequence, 1);
-	return seq_has_overflowed(s);
+
+	return 0;
 }
 
 static const struct seq_operations nfqnl_seq_ops = {
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 51a459c..4dcbea8 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -947,11 +947,10 @@ static int xt_table_seq_show(struct seq_file *seq, void *v)
 {
 	struct xt_table *table = list_entry(v, struct xt_table, list);
 
-	if (strlen(table->name)) {
+	if (strlen(table->name))
 		seq_printf(seq, "%s\n", table->name);
-		return seq_has_overflowed(seq);
-	} else
-		return 0;
+
+	return 0;
 }
 
 static const struct seq_operations xt_table_seq_ops = {
@@ -1090,7 +1089,7 @@ static int xt_match_seq_show(struct seq_file *seq, void *v)
 		if (*match->name == '\0')
 			return 0;
 		seq_printf(seq, "%s\n", match->name);
-		return seq_has_overflowed(seq);
+		break;
 	}
 	return 0;
 }
@@ -1145,7 +1144,7 @@ static int xt_target_seq_show(struct seq_file *seq, void *v)
 		if (*target->name == '\0')
 			return 0;
 		seq_printf(seq, "%s\n", target->name);
-		return seq_has_overflowed(seq);
+		break;
 	}
 	return 0;
 }
