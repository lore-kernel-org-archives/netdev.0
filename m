From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v10 0/4] net sched actions: improve dump performance
Date: Sun, 11 Jun 2017 07:53:42 -0400
Message-ID: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32949 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdFKLx5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 07:53:57 -0400
Received: by mail-io0-f194.google.com with SMTP id j200so3945116ioe.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 04:53:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes since v9:
-----------------

1) General consensus:
- remove again the use of BIT() to maintain uapi consistency ;->

1) Jiri:
- Add a new netlink type NLA_FLAG_BITS to check for valid bits 
  and use it instead of inline vetting.
  
Changes since v8:
-----------------

1) Jiri:
- Add back the use of BIT(). Eventually fix iproute2 instead
- Rename VALID_TCA_FLAGS to VALID_TCA_ROOT_FLAGS

Changes since v7:
-----------------

Jamal:
No changes.
Patch 1 went out twice. Resend without two copies of patch 1

changes since v6:
-----------------

1) DaveM:
New rules for netlink messages. From now on we are going to start
checking for bits that are not used and rejecting anything we dont
understand. In the future this is going to require major changes
to user space code (tc etc). This is just a start.

To quote, David:
"
 Again, bits you aren't using now, make sure userspace doesn't
   set them.  And if it does, reject.
"
Added checks for ensuring things work as above.

2) Jiri:
a)Fix the commit message to properly use "Fixes" description
b)Align assignments for nla_policy

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

Earlier Changes
----------------
- Jiri mostly on names of things.

Jamal Hadi Salim (4):
  net netlink: Add new type NLA_FLAG_BITS
  net sched actions: Use proper root attribute table for actions
  net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
  net sched actions: add time filter for action dumping

 include/net/netlink.h          | 11 +++++++
 include/uapi/linux/rtnetlink.h | 40 ++++++++++++++++++++++--
 lib/nlattr.c                   | 25 +++++++++++++++
 net/sched/act_api.c            | 70 +++++++++++++++++++++++++++++++++++-------
 4 files changed, 133 insertions(+), 13 deletions(-)

-- 
1.9.1
