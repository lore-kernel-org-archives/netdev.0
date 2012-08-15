From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [net PATCH v3 1/3] net: netprio: fix files lock and remove
 useless d_path bits
Date: Wed, 15 Aug 2012 21:03:18 +0100
Message-ID: <20120815200318.GM23464@ZenIV.linux.org.uk>
References: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
 <20120815105206.GA23811@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, joe@perches.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60350 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932109Ab2HOUDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 16:03:31 -0400
Content-Disposition: inline
In-Reply-To: <20120815105206.GA23811@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 15, 2012 at 06:52:06AM -0400, Neil Horman wrote:
> On Tue, Aug 14, 2012 at 03:34:24PM -0700, John Fastabend wrote:
> > Add lock to prevent a race with a file closing and also remove
> > useless and ugly sscanf code. The extra code was never needed
> > and the case it supposedly protected against is in fact handled
> > correctly by sock_from_file as pointed out by Al Viro.
> > 
> > CC: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > ---
> > 
> >  net/core/netprio_cgroup.c |   22 ++++------------------
> >  1 files changed, 4 insertions(+), 18 deletions(-)
> > 
> > diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> > index ed0c043..f65dba3 100644
> > --- a/net/core/netprio_cgroup.c
> > +++ b/net/core/netprio_cgroup.c
> > @@ -277,12 +277,6 @@ out_free_devname:
> >  void net_prio_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
> >  {
> >  	struct task_struct *p;
> > -	char *tmp = kzalloc(sizeof(char) * PATH_MAX, GFP_KERNEL);
> > -
> > -	if (!tmp) {
> > -		pr_warn("Unable to attach cgrp due to alloc failure!\n");
> > -		return;
> > -	}
> >  
> >  	cgroup_taskset_for_each(p, cgrp, tset) {
> >  		unsigned int fd;
> > @@ -296,32 +290,24 @@ void net_prio_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
> >  			continue;
> >  		}
> >  
> > -		rcu_read_lock();
> > +		spin_lock(&files->file_lock);
> >  		fdt = files_fdtable(files);
> >  		for (fd = 0; fd < fdt->max_fds; fd++) {
> > -			char *path;
> >  			struct file *file;
> >  			struct socket *sock;
> > -			unsigned long s;
> > -			int rv, err = 0;
> > +			int err;
> >  
> >  			file = fcheck_files(files, fd);
> >  			if (!file)
> >  				continue;
> >  
> > -			path = d_path(&file->f_path, tmp, PAGE_SIZE);
> > -			rv = sscanf(path, "socket:[%lu]", &s);
> > -			if (rv <= 0)
> > -				continue;
> > -
> >  			sock = sock_from_file(file, &err);
> > -			if (!err)
> > +			if (sock)
> >  				sock_update_netprioidx(sock->sk, p);
> >  		}
> > -		rcu_read_unlock();
> > +		spin_unlock(&files->file_lock);
> >  		task_unlock(p);
> >  	}
> > -	kfree(tmp);
> >  }
> >  
> >  static struct cftype ss_files[] = {
> > 
> > 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
> It looks good to me.  Al, could you please lend your review here too?

Tolerable...  I still don't like the idea of iterating through the
descriptor tables, but at least that variant is safe wrt locking and
lifetime rules.
