From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at
	kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 16:25:38 +0200
Message-ID: <20090929142538.GA10180@redhat.com>
References: <200909251123.03482.borntraeger@de.ibm.com> <fbbbe0a028fa.4ac1f1c0@2ka.mipt.ru> <20090929132415.GB4538@redhat.com> <200909291547.21528.borntraeger@de.ibm.com> <20090929140718.GA23858@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Evgeny Polyakov <johnpol@2ka.mipt.ru>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752873AbZI2OaG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090929140718.GA23858@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29, Evgeniy Polyakov wrote:
>
> On Tue, Sep 29, 2009 at 03:47:21PM +0200, Christian Borntraeger (borntraeger@de.ibm.com) wrote:
> > Ok,  can confirm that this patch fixes my problem, but I am not sure if the
> > intended behaviour is still working as expected.
>
> Your patch breaks assumption that task_session(current->group_leader) is
> not equal to new session id,

Afaics, no.

> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1090,6 +1090,7 @@ SYSCALL_DEFINE0(setsid)
>  	struct pid *sid = task_pid(group_leader);
>  	pid_t session = pid_vnr(sid);
>  	int err = -EPERM;
> +	int send_cn = 0;
>
>  	write_lock_irq(&tasklist_lock);
>  	/* Fail if I am already a session leader */
> @@ -1104,12 +1105,18 @@ SYSCALL_DEFINE0(setsid)
>
>  	group_leader->signal->leader = 1;
>  	__set_special_pids(sid);
> +	if (task_session(group_leader) != sid)
> +		send_cn = 1;

This is not right, task_session(group_leader) must be == sid after
__set_special_pids().

And I don't think "int send_cn" is needed. sys_setsid() must not
succeed if the caller lived in session == task_pid(group_leader).

Or I missed your point?

Oleg.
