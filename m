From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC] sched: split classification and enqueue
Date: Wed, 22 Jun 2016 10:29:44 -0700
Message-ID: <CAADnVQJzcbjiB3FPMcuHOftreL3reu+AZyLWeX_et=3_X8_bcw@mail.gmail.com>
References: <1466589835-18521-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>,
	john fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36665 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcFVRaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:30:07 -0400
Received: by mail-lf0-f65.google.com with SMTP id a2so14849006lfe.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 10:30:05 -0700 (PDT)
In-Reply-To: <1466589835-18521-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 3:03 AM, Florian Westphal <fw@strlen.de> wrote:
> Currently classification and enqueue is done in a single step.
>
> core acquires the qdisc lock, then calls the ->enqueue() function
> of the qdisc.
>
> Its the job of the qdisc and its attached classifiers to figure out what
> to do next.
>
> Typically the enqueue function will call tc_classify() to lookup a
> child class, then call ->enqueue of the child qdisc.
>
> This can repeat a number of times until a leaf qdisc is reached; this leaf
> will do the real enqueue operation (pfifo for example).
>
> While this approach gives qdiscs and the classifier/action subsystem
> a lot of control, it has one major drawback:  The root qdisc lock
> is held for a prolonged period of time while we recurse through
> the qdisc hierarchy from root to leaf.
>
> This (unfinished!) hack splits classification and enqueue into
> two steps.
>
> Before enqueueing the packet and *before* acquiring the root qdisc lock,
> the new qdisc ->classify() function is invoked.

I believe John is finalizing his lockless qdisc patches...
would this split still be needed after qdiscs become lockless?
