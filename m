From: Shmulik Ladkani <shmulik@nsof.io>
Subject: Re: [PATCH net] net: fib_rules: Fix fib_rules_ops->compare
 implementations to support exact match
Date: Wed, 4 Oct 2017 08:34:34 +0300
Message-ID: <20171004083434.36ca9272@pixies>
References: <20170930085909.1103-1-shmulik@nsof.io>
        <20171003.145418.677435703318514230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mateusz.bajorski@nokia.com, tgraf@suug.ch,
        shmulik.ladkani@gmail.com, eyal.birger@gmail.com
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:56867 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdJDFei (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 01:34:38 -0400
Received: by mail-wm0-f41.google.com with SMTP id l68so6901240wmd.5
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 22:34:37 -0700 (PDT)
In-Reply-To: <20171003.145418.677435703318514230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, 03 Oct 2017 14:54:18 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> I don't see any inconsistency.  When you insert using NLM_F_EXCL the
> insertion fails if any existing rule matches or overlaps in any way
> with the keys in the new rule.

Please note that current situation is as follows:

A: Generic (non /0), followed by specific that overlaps, ALLOWED

# ip ru add from 0.0.0.0/1 iif eth2 pref 33 table 33
# ip ru add from 10.0.0.0/8 iif eth2 pref 33 table 33

A Reversed: Specific, followed by generic (non /0) that overlaps, ALLOWED

# ip ru add from 10.0.0.0/8 iif eth2 pref 33 table 33
# ip ru add from 0.0.0.0/1 iif eth2 pref 33 table 33

B: 0.0.0.0/0, followed by specific that overlaps, ALLOWED

# ip ru add from 0.0.0.0/0 iif eth2 pref 33 table 33
# ip ru add from 10.0.0.0/8 iif eth2 pref 33 table 33

B Reversed: Specific, followed by 0.0.0.0/0, FAILS

# ip ru add from 10.0.0.0/8 iif eth2 pref 33 table 33
# ip ru add from 0.0.0.0/0 iif eth2 pref 33 table 33
(File exists)

Is there any reason why 0.0.0.0/0 should be treated differently, meaning,
insertion of 0.0.0.0/0 is order dependant (where other overlapping
rules are allowed REGARDLESS order of insertion)?

Please do note there is absolutely NO "overlapping" detection logic in
'fib4_rule_compare' whatsoever; just strict comparison of the FRA_SRC
addresses.

The only exception is if the new FRA_SRC address is 0.0.0.0/0 - which is
considered "colliding" with ANY existing rule.

The "treat /0 as a collision" existed way prior NLM_F_EXCL enforcement
was introduced, as the single usecase of ->compare() was for DELRULE
which had wildcard semantics.
Alas for NEWRULE+NLM_F_EXCL it exposes the above anomaly.

Best,
Shmulik
