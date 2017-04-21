From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v6 0/3] net sched actions: improve dump performance
Date: Fri, 21 Apr 2017 06:55:29 -0400
Message-ID: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
Cc: jiri@resnulli.us, xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35372 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1038143AbdDUKzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 06:55:41 -0400
Received: by mail-io0-f193.google.com with SMTP id d203so29079990iof.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 03:55:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes since v5:
----------------

0)
Remove use of BIT() because it is kernel specific. Requires a separate
patch (Jiri can submit that in his cleanups)

1)To paraphrase Eric D.

"memcpy(nla_data(count_attr), &cb->args[1], sizeof(u32));
wont work on 64bit BE machines because cb->args[1]
(which is 64 bit is larger in size than sizeof(u32))"

Fixed

2) Jiri Pirko

i) Spotted a bug fix mixed in the patch for wrong TLV
fix. Add patch 1/3 to address this. Make part of this
series because of dependencies.

ii) Rename ACT_LARGE_DUMP_ON -> TCA_FLAG_LARGE_DUMP_ON

iii) Satisfy Jiri's obsession against the noun "tcaa"
a)Rename struct nlattr *tcaa --> struct nlattr *tb
b)Rename TCAA_ACT_XXX -> TCA_ROOT_XXX

Changes since v4:
-----------------

1) Eric D.

pointed out that when all skb space is used up by the dump
there will be no space to insert the TCAA_ACT_COUNT attribute.

2) Jiri:

i) Change:

enum {
        TCAA_UNSPEC,
        TCAA_ACT_TAB,
        TCAA_ACT_FLAGS,
        TCAA_ACT_COUNT,
        TCAA_ACT_TIME_FILTER,
        __TCAA_MAX
};

#define TCAA_MAX (__TCAA_MAX - 1)
#define ACT_LARGE_DUMP_ON               (1 << 0)

to:
enum {
       TCAA_UNSPEC,
       TCAA_ACT_TAB,
#define TCA_ACT_TAB TCAA_ACT_TAB
       TCAA_ACT_FLAGS,
       TCAA_ACT_COUNT,
       __TCAA_MAX,
#define        TCAA_MAX (__TCAA_MAX - 1)
};

#define ACT_LARGE_DUMP_ON              BIT(0)

Jiri plans to followup with the rest of the code to make the
style consistent.

ii) Rename attribute TCAA_ACT_TIME_FILTER --> TCAA_ACT_TIME_DELTA

iii) Rename variable jiffy_filter --> jiffy_since
iv) Rename msecs_filter --> msecs_since
v) get rid of unused cb->args[0] and rename cb->args[4] to cb->args[0]

Jamal Hadi Salim (3):
  net sched actions: User proper root attribute table for actions
  net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
  net sched actions: add time filter for action dumping

 include/uapi/linux/rtnetlink.h | 22 ++++++++++++--
 net/sched/act_api.c            | 66 +++++++++++++++++++++++++++++++++++-------
 2 files changed, 75 insertions(+), 13 deletions(-)

-- 
1.9.1
