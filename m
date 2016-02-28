From: Alaa Hleihel <alaa@dev.mellanox.co.il>
Subject: Re: [net-next PATCH v2 2/8] net: rework setup_tc ndo op to consume
 general tc operand
Date: Sun, 28 Feb 2016 16:11:36 +0200
Message-ID: <56D30018.5090208@dev.mellanox.co.il>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
 <20160216060057.32452.75845.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, amir@vadai.me,
	jhs@mojatatu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35684 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565AbcB1OLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 09:11:41 -0500
Received: by mail-wm0-f66.google.com with SMTP id 1so854448wmg.2
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 06:11:40 -0800 (PST)
In-Reply-To: <20160216060057.32452.75845.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On 2/16/2016 08:00, John Fastabend wrote:
> @@ -140,9 +141,11 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
>  	 * supplied and verified mapping
>  	 */
>  	if (qopt->hw) {
> +		struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
> +					  .tc = qopt->num_tc};
> +
>

Using gcc 4.4.7, the compilation failed on these lines (since that compiler does not support anonymous unions):

  CC [M]  net/sched/sch_mqprio.o
net/sched/sch_mqprio.c: In function ?mqprio_init?:
net/sched/sch_mqprio.c:145: error: unknown field ?tc? specified in initializer
net/sched/sch_mqprio.c:145: warning: missing braces around initializer
net/sched/sch_mqprio.c:145: warning: (near initialization for ?tc.<anonymous>?)
make[2]: *** [net/sched/sch_mqprio.o] Error 1
make[1]: *** [net/sched] Error 2
make: *** [net] Error 2


It can be fixed by surrounding it with braces; something like:

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index f9947d1..9b844f7 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -142,7 +142,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
         */
        if (qopt->hw) {
                struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
-                                         .tc = qopt->num_tc};
+                                        {.tc = qopt->num_tc}};

                priv->hw_owned = 1;
                err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);


Would you please fix it ?

Regards,
Alaa
