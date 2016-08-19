From: Andrew Yourtchenko <ayourtch@gmail.com>
Subject: [PATCH v2 0/2] ipv6: fix stuck RA-derived route in container after migration with criu
Date: Fri, 19 Aug 2016 18:41:21 +0200
Message-ID: <cover.1471622715.git.ayourtch@gmail.com>
References: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Cc: Andrew Yourtchenko <ayourtch@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35497 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755052AbcHSQlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:41:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so4085172wmg.2
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 09:41:53 -0700 (PDT)
In-Reply-To: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes the connectivity problem for containers
with RA-derived default route, after they were migrated using criu:
the default routes would lose their "expires" value and become
stuck forever. The corresponding criu issue with the discussion
is at https://github.com/xemul/criu/issues/177

The latter uses "ip -6 route save" to save the routes during
the migration, and "ip -6 route restore" during restore, so the problem
is easily reproducible even without criu.

There are two problems, hence two patches in this patchset:

1) the expiry time for the route is saved in
RTA_CACHEINFO via rtnl_put_cacheinfo, but the code in rtm_to_fib6_config
expects the RTA_EXPIRES. Rather than cherrypicking in the restore code path
from RTA_CACHEINFO, adding RTA_EXPIRES upon save seemed like
a better option.

2) the restored route, even with the properly restored expires,
does not have the correct RTF_* flags set (RTF_ADDRCONF|RTF_DEFAULT),
preventing the incoming router advertisements from updating it.
During the code review I noticed RTF_ROUTEINFO would be also lost
during save/restore. This can be viewed as an operation symmetric
to that done in f0396f60d7c165018c9b203fb9b89fb224835578.

Tested both net and net-next with the patches.

Changes since v1 [1]:
 * Fixed the indentation in both patches as per David Miller's review comments:
    - basic block indented always by a TAB
    - multiline function call second line to start at the first column
      after the opening parenthesis of the function call, using
      appropriate number of TABs (and SPC only at the end, if needed).

[1] v1: http://marc.info/?l=linux-netdev&m=147135599322286&w=2

Andrew Yourtchenko (2):
  ipv6: save route expiry in RTA_EXPIRES if RTF_EXPIRES set
  ipv6: fixup RTF_* flags when restoring RTPROT_RA route from rtnetlink

 net/ipv6/route.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

-- 
2.7.4
