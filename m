From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v9 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 15:08:44 +0200
Message-ID: <20170426130844.GG1867@nanopsycho.orion>
References: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
 <1493210538-21716-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36193 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S3000139AbdDZNIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:08:47 -0400
Received: by mail-wm0-f67.google.com with SMTP id u65so925792wmu.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:08:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493210538-21716-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 26, 2017 at 02:42:17PM CEST, jhs@mojatatu.com wrote:
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

[...]

	
>+#define VALID_TCA_ROOT_FLAGS TCA_FLAG_LARGE_DUMP_ON
>+static inline bool tca_flags_valid(u32 act_flags)
>+{
>+	u32 invalid_flags_mask  = ~VALID_TCA_ROOT_FLAGS;
>+
>+	if (act_flags & invalid_flags_mask)
>+		return false;
>+
>+	return true;

This dance should either not be here (flag-per-attr) or should be in
netlink generic place. This is not TC specific at all.

I would still like to see the numbers prooving we need this.
Thanks
