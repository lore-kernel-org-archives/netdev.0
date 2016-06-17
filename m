From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: act_mirred: remove spinlock in fast path
Date: Fri, 17 Jun 2016 14:03:41 -0700
Message-ID: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34838 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995AbcFQVEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 17:04:02 -0400
Received: by mail-yw0-f193.google.com with SMTP id g20so782567ywb.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 14:04:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric

During code review, I notice we might have some problem after we go
lockless for the fast path in act_mirred.

That is, what prevents us from the following possible race condition?

change a standalone action with tcf_mirred_init():
  // search for an existing action in hash
  // found it and got struct tcf_common
  m = to_mirred(a);
  m->tcf_action = parm->action;
  // Interrupted by BH

tcf_mirred() jumps in:
  rcu_read_lock()
  retval = READ_ONCE(m->tcf_action);
  if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
  ....
  rcu_unread_lock()

now go back to tcf_mirred_init():
  m->tcfm_eaction = parm->eaction;
  ....

IOW, the fast path could read a partially written change which could
be a problem? We need to allocate a new copy and then replace the old
one with it via RCU, don't we?

I can work on some patches, I want to make sure I don't miss anything here.

Thanks!
