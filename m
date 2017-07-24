From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v11 0/4]  net sched actions: improve dump performance
Date: Sun, 23 Jul 2017 21:35:42 -0400
Message-ID: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        dsahern@gmail.com, eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35664 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751782AbdGXBgG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 21:36:06 -0400
Received: by mail-it0-f68.google.com with SMTP id v127so6813918itd.2
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 18:36:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>


Changes since v10:
-----------------
1) Jiri: move type->validate_content() to its own patch
Jamal: decided to remove it altogether so we can get this patch set in.

2) Change name of NLA_FLAG_BITS to NLA_BITFIELD_32 based on discussions
with D. Ahern and Jiri. D. Ahern suggests to make this a variable bitmap size.
My analysis at this point is it too complex and i only need a few bit
flags. If we run out of bits someone else can create a new NLA_BITFIELD_XXX
and start using that. So please let this go.

3) Jamal - Add Suggested-by: Jiri for type NLA_BITFIELD_32

4) Jiri: Change name allowed_flags to tcaa_root_flags_allowed

5) Jiri: Introduce nla_get_flag_bits_values() helper instead of using
memcpy for retrieving nla_bitfield_32 fields.

Changes since v9:
-----------------

1) General consensus:
- remove again the use of BIT() to maintain uapi consistency ;->

1) Jiri:
- Add a new netlink type NLA_FLAG_BITS to check for valid bits 
  and use it instead of inline vetting (patch 4/4 now)
  
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
  net netlink: Add new type NLA_BITFIELD_32
  net sched actions: Use proper root attribute table for actions
  net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
  net sched actions: add time filter for action dumping

 include/net/netlink.h          | 16 ++++++++++
 include/uapi/linux/netlink.h   | 17 +++++++++++
 include/uapi/linux/rtnetlink.h | 23 ++++++++++++--
 lib/nlattr.c                   | 21 +++++++++++++
 net/sched/act_api.c            | 68 +++++++++++++++++++++++++++++++++++-------
 5 files changed, 132 insertions(+), 13 deletions(-)

-- 
1.9.1
