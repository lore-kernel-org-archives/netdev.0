From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: annoying u32 double listing
Date: Sun, 06 Feb 2005 22:39:46 +0100
Message-ID: <42068EA2.6030507@trash.net>
References: <1107719343.1055.22.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060009020002090402080907"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1107719343.1055.22.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060009020002090402080907
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

jamal wrote:

>bug is around since 2.1.x; never cared about chasing it until now
>because it is affecting someone i know.
>Dave, please apply. I will prepare a 2.4.x version.
>
The patch is wrong. The "divisor"-lines are missing in the output with
your patch and it only hides the real error. ->walk is supposed to walk
all filters of the given priority/protocol, but u32 walks all filters.
This patch fixes it. Output with new patch:

filter protocol ip pref 6 u32
filter protocol ip pref 6 u32 fh 800: ht divisor 1
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0 
flowid 1:16  (rule hit 0 success 0)
  match 0a0000d2/ffffffff at 12 (success 0 )
filter protocol ip pref 7 u32
filter protocol ip pref 7 u32 fh 801: ht divisor 1
filter protocol ip pref 7 u32 fh 801::800 order 2048 key ht 801 bkt 0 
flowid 1:15  (rule hit 0 success 0)
  match 0a000090/ffffffff at 12 (success 0 )

Signed-off-by: Patrick McHardy <kaber@trash.net>

BTW: u32_walk seems to have another bug, it uses tcf_walker->count and
tcf_walker->skip for skipping over both hnodes and knodes and doesn't
skip hnodes properly at all. I'll have a look at this now.

Regards
Patrick

>AFTER FIX: 
>---------
>
>root@jdev:/usr/src# tc -s filter show parent ffff: dev eth0
>filter protocol ip pref 6 u32
>filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
>flowid 1:16  
>  match 0a0000d2/ffffffff at 12 
>  filter protocol ip pref 7 u32
>  filter protocol ip pref 7 u32 fh 801::800 order 2048 key ht 801 bkt 0
>flowid 1:15  
>    match 0a000090/ffffffff at 12 
>
>  
>

--------------060009020002090402080907
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/sched/cls_u32.c 1.25 vs edited =====
--- 1.25/net/sched/cls_u32.c	2005-01-11 20:25:16 +01:00
+++ edited/net/sched/cls_u32.c	2005-02-06 22:20:33 +01:00
@@ -91,6 +91,7 @@
 {
 	struct tc_u_hnode	*next;
 	u32			handle;
+	u32			prio;
 	struct tc_u_common	*tp_c;
 	int			refcnt;
 	unsigned		divisor;
@@ -323,6 +324,7 @@
 	root_ht->divisor = 0;
 	root_ht->refcnt++;
 	root_ht->handle = tp_c ? gen_new_htid(tp_c) : 0x80000000;
+	root_ht->prio = tp->prio;
 
 	if (tp_c == NULL) {
 		tp_c = kmalloc(sizeof(*tp_c), GFP_KERNEL);
@@ -703,6 +705,8 @@
 		return;
 
 	for (ht = tp_c->hlist; ht; ht = ht->next) {
+		if (ht->prio != tp->prio)
+			continue;
 		if (arg->count >= arg->skip) {
 			if (arg->fn(tp, (unsigned long)ht, arg) < 0) {
 				arg->stop = 1;

--------------060009020002090402080907--
