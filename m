From: Patrick McHardy <kaber@trash.net>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 01:38:07 +0100
Message-ID: <419162EF.5000601@trash.net>
References: <41899DCF.3050804@trash.net>	<E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041109161126.376f755c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On Sat, 06 Nov 2004 10:35:45 +1100
>Herbert Xu <herbert@gondor.apana.org.au> wrote:
>  
>
>>2) Hooking random net/sched requests into rtnetlink.  By being an
>>rtnetlink user you pay the price of taking the rtnl.  Most of the
>>net/sched stuff has nothing to do with rtnetlink.
>>    
>>
>
>I believe this is a false statement.  Every single networking
>config change depends upon device existence and state in some
>way.  By virtue of that, they really depend upon the RTNL being
>held during the duration of their execution.
>
>Only the actual implementations know when and where such a
>dependency on device state et al. does not exist, and therefore
>where RTNL holding is not necessary.
>
Agreed. Restructuring only net/sched to be independant
of the rtnl requires alot of non-trivial work, with not
much to gain.

>Therefore I suggest we just implement the fix for this inside of
>the packet scheduler layer itself.  Simply by dropping the RTNL
>semaphore during the module request, and then regrabbing the RTNL
>semaphore and replaying the request from the beginning.
>
Nicely done. I feel smarter just by looking at it :)

>
>The net/sched/sch_api.c version of the fix would look like the
>following.  The act_api.c case would require a bit more surgery,
>but with the right restructuring it can be done too.
>

I'll have a look at this while cleaning up the code.

Regards
Patrick

>===== net/sched/sch_api.c 1.41 vs edited =====
>--- 1.41/net/sched/sch_api.c	2004-11-05 16:34:45 -08:00
>+++ edited/net/sched/sch_api.c	2004-11-09 15:57:19 -08:00
>@@ -396,17 +396,30 @@
> 	struct Qdisc_ops *ops;
> 	int size;
> 
>+	err = -EINVAL;
> 	ops = qdisc_lookup_ops(kind);
> #ifdef CONFIG_KMOD
> 	if (ops==NULL && tca[TCA_KIND-1] != NULL) {
> 		if (RTA_PAYLOAD(kind) <= IFNAMSIZ) {
>+			rtnl_unlock();
> 			request_module("sch_%s", (char*)RTA_DATA(kind));
>+			rtnl_lock();
>+
> 			ops = qdisc_lookup_ops(kind);
>+
>+			/* We dropped the RTNL semaphore in order to
>+			 * perform the module load.  So, even if we
>+			 * succeeded in loading the module we have to
>+			 * tell the caller to replay the request.  We
>+			 * indicate this using -EAGAIN.
>+			 */
>+			if (ops != NULL)
>+				err = -EAGAIN;
>+			goto err_out;
> 		}
> 	}
> #endif
> 
>-	err = -EINVAL;
> 	if (ops == NULL)
> 		goto err_out;
> 	err = -EBUSY;
>@@ -600,14 +613,19 @@
> 
> static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
> {
>-	struct tcmsg *tcm = NLMSG_DATA(n);
>-	struct rtattr **tca = arg;
>+	struct tcmsg *tcm;
>+	struct rtattr **tca;
> 	struct net_device *dev;
>-	u32 clid = tcm->tcm_parent;
>-	struct Qdisc *q = NULL;
>-	struct Qdisc *p = NULL;
>+	u32 clid;
>+	struct Qdisc *q, *p;
> 	int err;
> 
>+replay:
>+	tcm = NLMSG_DATA(n);
>+	tca = arg;
>+	clid = tcm->tcm_parent;
>+	q = p = NULL;
>+
> 	if ((dev = __dev_get_by_index(tcm->tcm_ifindex)) == NULL)
> 		return -ENODEV;
> 
>@@ -701,8 +719,14 @@
> 		q = qdisc_create(dev, tcm->tcm_parent, tca, &err);
>         else
> 		q = qdisc_create(dev, tcm->tcm_handle, tca, &err);
>-	if (q == NULL)
>+	if (q == NULL) {
>+		if (err == -EAGAIN) {
>+			/* Replay the request. */
>+			dev_put(dev);
>+			goto replay;
>+		}
> 		return err;
>+	}
> 
> graft:
> 	if (1) {
>
>  
>
