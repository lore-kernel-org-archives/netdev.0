From: Shmulik Ladkani <shmulik@nsof.io>
Subject: Re: [PATCH net] net: fib_rules: Fix fib_rules_ops->compare
 implementations to support exact match
Date: Sat, 7 Oct 2017 09:04:35 +0300
Message-ID: <20171007090435.0a793acc@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mateusz.bajorski@nokia.com,
        dsa@cumulusnetworks.com, tgraf@suug.ch, shmulik.ladkani@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:55009 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdJGGEk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 02:04:40 -0400
Received: by mail-wm0-f41.google.com with SMTP id i124so11758624wmf.3
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 23:04:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, 03 Oct 2017 14:54:18 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Shmulik Ladkani <shmulik@nsof.io>
> Date: Sat, 30 Sep 2017 11:59:09 +0300
> 
> > This leads to inconsistencies, depending on order of operations, e.g.:  
> 
> I don't see any inconsistency.  When you insert using NLM_F_EXCL the
> insertion fails if any existing rule matches or overlaps in any way
> with the keys in the new rule.

(Haven't seen any response to https://patchwork.ozlabs.org/patch/820186/
 for a while.
 The original description of the problem was vague.
 Summarizing the arguments here)

The "matches or overlaps in any way" statement is incorrect for fib
rules; strict exact comparison of the addresses is performed,
see snip of fib4_rule_compare:

	if (frh->src_len && (rule4->src_len != frh->src_len))
		return 0;
  ...
	if (frh->src_len && (rule4->src != nla_get_in_addr(tb[FRA_SRC])))
		return 0;

(with the ONLY exception of src_len being zero, i.e. FRA_SRC not being
 specified, where comparison is skipped, and compare result defaults to
 true)

Therefore, one can successfully add various overlapping rules in any
arbitrary order:

  ip ru a from 10.20.0.0/16 iif eth2 pref 22 table 22
  ip ru a from 10.0.0.0/8 iif eth2 pref 22 table 22
  ip ru a from 10.20.30.0/24 iif eth2 pref 22 table 22
  ip ru a from 0.0.0.0/4 iif eth2 pref 22 table 22
  ip ru a from 0.0.0.0/1 iif eth2 pref 22 table 22
  ip ru a from 0.0.0.0/2 iif eth2 pref 22 table 22

One can also add various overlapping rules, after the 0.0.0.0/0 rule has
been initially inserted:

  ip ru a from 0.0.0.0/0 iif eth2 pref 33 table 33
  ip ru a from 10.0.0.0/8 iif eth2 pref 33 table 33
  ip ru a from 0.0.0.0/4 iif eth2 pref 33 table 33

But one cannot add the 0.0.0.0/0 rule after other rules have been
inserted:

  ip ru a from 10.20.30.0/24 iif eth2 pref 44 table 44
  ip ru a from 10.0.0.0/8 iif eth2 pref 44 table 44
  ip ru a from 0.0.0.0/0 iif eth2 pref 44 table 44
  RTNETLINK answers: File exists

This behaviour is unexpected for the user program, as it needs to
"sort" its insertions if it has a 0.0.0.0/0 rule among the rules
it wishes to add.

The purpose of NLM_F_EXCL is for ensuring rule exclusiveness, as
explained in commit 153380ec4b9b; there's no overlap semantics in none
of the fib_rules_ops->compare implementations.
