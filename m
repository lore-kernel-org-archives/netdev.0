From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] rtnl_unlock/lock in sch_api.c
Date: Mon, 28 Mar 2005 16:50:32 +0200
Message-ID: <424819B8.8000201@trash.net>
References: <Pine.LNX.4.62.0503281720430.20453@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020703090606070105060609"
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0503281720430.20453@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020703090606070105060609
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Catalin(ux aka Dino) BOIE wrote:
> Hello!
> 
> Trying to load a custom module (same for teql but I didn't tried it)
> whan the qdisc module is not loaded, makes tc hang.
> This is because qdisc_create aquires rtnl_sem and then tries to load a 
> module that tries to register_netdev (that tries to aquire the same 
> rtnl_sem).
> Applying this patch makes the problem go away.

You open a race by dropping the lock and not replaying the request
after acquiring it again. This is Dave's original patch, please
simply fix this one up so it applies again.

Regards
Patrick

--------------020703090606070105060609
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/sched/sch_api.c 1.41 vs edited =====
--- 1.41/net/sched/sch_api.c	2004-11-05 16:34:45 -08:00
+++ edited/net/sched/sch_api.c	2004-11-09 15:57:19 -08:00
@@ -396,17 +396,30 @@
 	struct Qdisc_ops *ops;
 	int size;
 
+	err = -EINVAL;
 	ops = qdisc_lookup_ops(kind);
 #ifdef CONFIG_KMOD
 	if (ops==NULL && tca[TCA_KIND-1] != NULL) {
 		if (RTA_PAYLOAD(kind) <= IFNAMSIZ) {
+			rtnl_unlock();
 			request_module("sch_%s", (char*)RTA_DATA(kind));
+			rtnl_lock();
+
 			ops = qdisc_lookup_ops(kind);
+
+			/* We dropped the RTNL semaphore in order to
+			 * perform the module load.  So, even if we
+			 * succeeded in loading the module we have to
+			 * tell the caller to replay the request.  We
+			 * indicate this using -EAGAIN.
+			 */
+			if (ops != NULL)
+				err = -EAGAIN;
+			goto err_out;
 		}
 	}
 #endif
 
-	err = -EINVAL;
 	if (ops == NULL)
 		goto err_out;
 	err = -EBUSY;
@@ -600,14 +613,19 @@
 
 static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
-	struct tcmsg *tcm = NLMSG_DATA(n);
-	struct rtattr **tca = arg;
+	struct tcmsg *tcm;
+	struct rtattr **tca;
 	struct net_device *dev;
-	u32 clid = tcm->tcm_parent;
-	struct Qdisc *q = NULL;
-	struct Qdisc *p = NULL;
+	u32 clid;
+	struct Qdisc *q, *p;
 	int err;
 
+replay:
+	tcm = NLMSG_DATA(n);
+	tca = arg;
+	clid = tcm->tcm_parent;
+	q = p = NULL;
+
 	if ((dev = __dev_get_by_index(tcm->tcm_ifindex)) == NULL)
 		return -ENODEV;
 
@@ -701,8 +719,14 @@
 		q = qdisc_create(dev, tcm->tcm_parent, tca, &err);
         else
 		q = qdisc_create(dev, tcm->tcm_handle, tca, &err);
-	if (q == NULL)
+	if (q == NULL) {
+		if (err == -EAGAIN) {
+			/* Replay the request. */
+			dev_put(dev);
+			goto replay;
+		}
 		return err;
+	}
 
 graft:
 	if (1) {


--------------020703090606070105060609--
