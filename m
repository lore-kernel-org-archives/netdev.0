From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 78161] New: Missing NULL check of the return value of
 nla_nest_start() in function sfb_dump()
Date: Tue, 17 Jun 2014 13:52:11 -0700
Message-ID: <20140617135211.2a768f1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:38601 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965065AbaFQUwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 16:52:14 -0400
Received: by mail-pb0-f44.google.com with SMTP id md12so5241121pbc.17
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 13:52:13 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id qv9sm25468511pbc.71.2014.06.17.13.52.13
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 13:52:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 17 Jun 2014 04:54:08 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 78161] New: Missing NULL check of the return value of nla_nest_start() in function sfb_dump()


https://bugzilla.kernel.org/show_bug.cgi?id=78161

            Bug ID: 78161
           Summary: Missing NULL check of the return value of
                    nla_nest_start() in function sfb_dump()
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.39
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: rucsoftsec@gmail.com
        Regression: No

Function nla_nest_start() may return a NULL pointer, and its return value shall
be checked before used. But in function sfb_dump() after nla_nest_start() is
called(at net/sched/sch_sfb.c:559), the return value is immediately used as a
parameter of nla_nest_end() without NULL check. Besides, there is no check
before the parameter is dereferenced in the callee function nla_nest_end(). So
an invalid memory access may be triggered.
The related code snippets in sfb_dump() are as following.
sfb_dump() @@net/sched/sch_sfb.c:559
559         opts = nla_nest_start(skb, TCA_OPTIONS);
560         NLA_PUT(skb, TCA_SFB_PARMS, sizeof(opt), &opt);
561         return nla_nest_end(skb, opts);

Generally, the return value of nla_nest_start() shall be checked against NULL
before it is used, like the following code snippets in function mk_reply().
mk_reply @ kernel/taskstats.c:364
364 static struct taskstats *mk_reply(struct sk_buff *skb, int type, u32 pid)
365 {
366         struct nlattr *na, *ret;
367         int aggr;
368 
369         aggr = (type == TASKSTATS_TYPE_PID)
370                         ? TASKSTATS_TYPE_AGGR_PID
371                         : TASKSTATS_TYPE_AGGR_TGID;
372 
    ...
392 #ifdef TASKSTATS_NEEDS_PADDING
393         if (nla_put(skb, TASKSTATS_TYPE_NULL, 0, NULL) < 0)
394                 goto err;
395 #endif
396         na = nla_nest_start(skb, aggr);
397         if (!na)
398                 goto err;
399 
400         if (nla_put(skb, type, sizeof(pid), &pid) < 0)
401                 goto err;
    ...
409         return NULL;
410 }

Thak you!

RUC_Soft_Sec, supported by China.X.Orion

-- 
You are receiving this mail because:
You are the assignee for the bug.
