From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at
	kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 17:36:31 +0200
Message-ID: <20090929153631.GA12699@redhat.com>
References: <200909251123.03482.borntraeger@de.ibm.com> <fbbbe0a028fa.4ac1f1c0@2ka.mipt.ru> <20090929132415.GB4538@redhat.com> <200909291547.21528.borntraeger@de.ibm.com> <20090929140718.GA23858@ioremap.net> <20090929142538.GA10180@redhat.com> <20090929145413.GA26327@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Evgeny Polyakov <johnpol@2ka.mipt.ru>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255AbZI2PlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 11:41:00 -0400
Content-Disposition: inline
In-Reply-To: <20090929145413.GA26327@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29, Evgeniy Polyakov wrote:
>
> On Tue, Sep 29, 2009 at 04:25:38PM +0200, Oleg Nesterov (oleg@redhat.com) wrote:
> > > --- a/kernel/sys.c
> > > +++ b/kernel/sys.c
> > > @@ -1090,6 +1090,7 @@ SYSCALL_DEFINE0(setsid)
> > >  	struct pid *sid = task_pid(group_leader);
> > >  	pid_t session = pid_vnr(sid);
> > >  	int err = -EPERM;
> > > +	int send_cn = 0;
> > >
> > >  	write_lock_irq(&tasklist_lock);
> > >  	/* Fail if I am already a session leader */
> > > @@ -1104,12 +1105,18 @@ SYSCALL_DEFINE0(setsid)
> > >
> > >  	group_leader->signal->leader = 1;
> > >  	__set_special_pids(sid);
> > > +	if (task_session(group_leader) != sid)
> > > +		send_cn = 1;
> >
> > This is not right, task_session(group_leader) must be == sid after
> > __set_special_pids().
>
> Yeah, that check should be done before __set_special_pids().
>
> > And I don't think "int send_cn" is needed. sys_setsid() must not
> > succeed if the caller lived in session == task_pid(group_leader).
>
> Doesn't it only check pgid while patch intention was to send
> notification about sid?

If the proposed sid already was the session id, then prgp shouldn't
be empty.

but this doesn't really matter, we also check ->signal->leader
(not sure, but afaics this check is not strictly necessary because
 of PIDTYPE_PGID check)

> I.e. setsid() succeeds, although nothing
> happens.

This shouldn't happen, or sys_setsid() is buggy. Look, the new session
id is task_pid(current). If sys_setsid() succeeds but we don't change
the session, this means we were already the leader. In that case we
should return -EPERM.

Oleg.

