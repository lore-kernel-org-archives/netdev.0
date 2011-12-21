From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/4] net: use cgroup_attach method to migrate socket
 priotiy and classid
Date: Wed, 21 Dec 2011 15:40:57 +0000
Message-ID: <20111221154057.GI23916@ZenIV.linux.org.uk>
References: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
 <1324478390-22036-4-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38307 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab1LUPlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 10:41:00 -0500
Content-Disposition: inline
In-Reply-To: <1324478390-22036-4-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2011 at 09:39:49AM -0500, Neil Horman wrote:
> +static void cgrp_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> +			struct cgroup *old_cgrp, struct task_struct *tsk)
> +{
> +	int fd, err;
> +	struct files_struct *files;
> +	struct file *file;
> +	struct socket *sock;
> +	struct cgroup_netprio_state *old, *new;
> +	pid_t task_pid;
> + 
> +	files = get_files_struct(tsk);
> +	task_pid = task_pid_nr(tsk);
> + 
> +	old = cgrp_netprio_state(old_cgrp);
> +	new = cgrp_netprio_state(cgrp);
> + 
> +	spin_lock(&files->file_lock);
> +	for (fd=0; fd < files_fdtable(files)->max_fds; fd++) {
> +		file = fcheck_files(files, fd);
> +		if (!file)
> +			continue;
> +		sock = sock_from_file(file, &err);
> +		if (!sock)
> +			continue;
> +		if (!sock->sk)
> +			continue;
> +		if (sock->sk->sk_cgrp_owner == task_pid)
> +			sock->sk->sk_cgrp_prioidx = new->prioidx;

This looks bogus *and* racy; what about e.g. files currently in SCM_RIGHTS
datagrams?
