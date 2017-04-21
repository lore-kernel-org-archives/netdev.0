From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 15:12:20 +0200
Message-ID: <20170421131220.GC1874@nanopsycho.orion>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
 <1492772132-16559-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35355 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1039689AbdDUNMX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 09:12:23 -0400
Received: by mail-wm0-f67.google.com with SMTP id d79so4830438wmi.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 06:12:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492772132-16559-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 21, 2017 at 12:55:31PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>When you dump hundreds of thousands of actions, getting only 32 per
>dump batch even when the socket buffer and memory allocations allow
>is inefficient.
>
>With this change, the user will get as many as possibly fitting
>within the given constraints available to the kernel.
>
>The top level action TLV space is extended. An attribute
>TCA_ROOT_FLAGS is used to carry flags; flag TCA_FLAG_LARGE_DUMP_ON
>is set by the user indicating the user is capable of processing
>these large dumps. Older user space which doesnt set this flag
>doesnt get the large (than 32) batches.
>The kernel uses the TCA_ROOT_COUNT attribute to tell the user how many
>actions are put in a single batch. As such user space app knows how long
>to iterate (independent of the type of action being dumped)
>instead of hardcoded maximum of 32.
>
>Some results dumping 1.5M actions, first unpatched tc which the
>kernel doesnt help:
>
>prompt$ time -p tc actions ls action gact | grep index | wc -l
>1500000
>real 1388.43
>user 2.07
>sys 1386.79
>
>Now lets see a patched tc which sets the correct flags when requesting
>a dump:
>
>prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
>1500000
>real 178.13
>user 2.02
>sys 176.96
>
>That is about 8x performance improvement for tc which sets its
>receive buffer to about 32K.
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>---
> include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++--
> net/sched/act_api.c            | 46 +++++++++++++++++++++++++++++++++---------
> 2 files changed, 55 insertions(+), 12 deletions(-)
>
>diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>index cce0613..09e7b22d 100644
>--- a/include/uapi/linux/rtnetlink.h
>+++ b/include/uapi/linux/rtnetlink.h
>@@ -674,10 +674,27 @@ struct tcamsg {
> 	unsigned char	tca__pad1;
> 	unsigned short	tca__pad2;
> };
>+
>+enum {
>+	TCA_ROOT_UNSPEC,
>+	TCA_ROOT_TAB,
>+#define TCA_ACT_TAB TCA_ROOT_TAB
>+	TCA_ROOT_FLAGS,
>+	TCA_ROOT_COUNT,
>+	__TCA_ROOT_MAX,
>+#define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
>+};
>+
> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>-#define TCAA_MAX 1
>+/* tcamsg flags stored in attribute TCA_ROOT_FLAGS
>+ *
>+ * TCA_FLAG_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>+ * actions in a dump. All dump responses will contain the number of actions
>+ * being dumped stored in for user app's consumption in TCA_ROOT_COUNT
>+ *
>+ */
>+#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)

This is u32 "flags" that could not be extended for other use in future.
I'm missing the point. Also, you don't check the rest of the bits for 0
as requested by DaveM.

As far as this is unextendable, please have this as u8 with values 0 and 1
as I originally suggested.

I don't understand why are we running in circles about this...
