From: Patrick McHardy <kaber@trash.net>
Subject: Re: request_module while holding rtnl semaphore
Date: Tue, 11 Jan 2005 23:18:49 +0100
Message-ID: <41E450C9.80800@trash.net>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <41E34252.504@trash.net> <20050111094752.GD26856@postel.suug.ch> <41E43F83.1090503@trash.net> <20050111214720.GF26856@postel.suug.ch> <20050111215057.GG26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050403090701090801040501"
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050111215057.GG26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050403090701090801040501
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:

>>Of course, then there is no problem. Will you fix the request_module in
>>cls_api.c as well?
>>
>
>Just saw your patch, never mind.
>

Oops, embarassing :) The cls_api.c changes in my patch only deal with
EAGAIN from act_api.c, but I didn't fix module loading in cls_api.c
itself. Patch on top of the previous ones attached, I will also update
the bitkeeper tree.

Regards
Patrick


--------------050403090701090801040501
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 23:15:28+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: cls_api.c: drop rtnl for loading modules
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2005/01/11 23:15:20+01:00 kaber@coreworks.de +14 -5
#   [PKT_SCHED]: cls_api.c: drop rtnl for loading modules
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2005-01-11 23:17:58 +01:00
+++ b/net/sched/cls_api.c	2005-01-11 23:17:58 +01:00
@@ -219,20 +219,29 @@
 		err = -ENOBUFS;
 		if ((tp = kmalloc(sizeof(*tp), GFP_KERNEL)) == NULL)
 			goto errout;
+		err = -EINVAL;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND-1]);
+		if (tp_ops == NULL) {
 #ifdef CONFIG_KMOD
-		if (tp_ops==NULL && tca[TCA_KIND-1] != NULL) {
 			struct rtattr *kind = tca[TCA_KIND-1];
 			char name[IFNAMSIZ];
 
-			if (rtattr_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
+			if (kind != NULL &&
+			    rtattr_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
+				rtnl_unlock();
 				request_module("cls_%s", name);
+				rtnl_lock();
 				tp_ops = tcf_proto_lookup_ops(kind);
+				/* We dropped the RTNL semaphore in order to
+				 * perform the module load.  So, even if we
+				 * succeeded in loading the module we have to
+				 * replay the request.  We indicate this using
+				 * -EAGAIN.
+				 */
+				if (tp_ops != NULL)
+					err = -EAGAIN;
 			}
-		}
 #endif
-		if (tp_ops == NULL) {
-			err = -EINVAL;
 			kfree(tp);
 			goto errout;
 		}

--------------050403090701090801040501--
