From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 03 Mar 2010 19:50:56 +0300
Message-ID: <4B8E9370.3050300@parallels.com>
References: <4B88E431.6040609@parallels.com>	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com> <m1ocj6qljj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Serge Hallyn <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29857 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578Ab0CCQwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 11:52:38 -0500
In-Reply-To: <m1ocj6qljj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I just played with this and if you make the semantics of unshare(CLONE_NEWPID)
> to be that you become the idle task aka pid 0, and not the init task pid 1 the
> implementation is trivial.

This is not ... handy - if after enter you have pid 0 you obviously
can't perform 2 parallel enters. The way I see it:

As far as the numbers reported to the userspace are concerned:
1. task, that enters is still visible by its old parent by old pid
2. task, that enters gets some pid within the entering namespace
   and reports its parent pid to have pid 1 (init obviously doesn't
   care)
3. we _can_ try to allocate new pid equal to the old one so that
   glibc stays happy


As far as the pointers are concerned:
1. parent pointer doesn't change
2. task_pid(tsk) one (i.e. struct pid * one) _can_ change if
   a) we don't allow threads enter (de_thread problem is handeled)
   b) we don't allow leave the group/session, i.e. check, that there
      is the only one task that enters lives in its pgid/sid
   c) we wait for the quiescent state to pass by before destroying
      the old pid to handle race with sys_kill()

Thoughts/questions? ("This is a nasty problem" answer is not acceptable,
the real code problems/races please)
