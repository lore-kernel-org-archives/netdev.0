From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [flame^Wreview] net: netprio_cgroup: rework update socket logic
Date: Mon, 13 Aug 2012 07:22:53 -0400
Message-ID: <20120813112253.GA7300@hmsreliant.think-freely.org>
References: <20120813015348.GZ23464@ZenIV.linux.org.uk>
 <502896C5.7080303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <502896C5.7080303@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2012 at 10:55:17PM -0700, John Fastabend wrote:
> On 8/12/2012 6:53 PM, Al Viro wrote:
> >	Ladies and gentlemen, who the devil had reviewed that little gem?
> >
> >commit 406a3c638ce8b17d9704052c07955490f732c2b8
> >Author: John Fastabend <john.r.fastabend@intel.com>
> >Date:   Fri Jul 20 10:39:25 2012 +0000
> >
> >is a bleeding bogosity that doesn't pass even the most cursory
> >inspection.  It iterates through descriptor tables of a bunch
> >of processes, doing this:
> >                         file = fcheck_files(files, fd);
> >                         if (!file)
> >                                 continue;
> >
> >                         path = d_path(&file->f_path, tmp, PAGE_SIZE);
> >                         rv = sscanf(path, "socket:[%lu]", &s);
> >                         if (rv <= 0)
> >                                 continue;
> >
> >                         sock = sock_from_file(file, &err);
> >                         if (!err)
> >                                 sock_update_netprioidx(sock->sk, p);
> >Note the charming use of sscanf() for pattern-matching.  's' (inode
> >number of socket) is completely unused afterwards; what happens here
> >is a very badly written attempt to skip non-sockets.  Why, will
> >sock_from_file() blow up on non-sockets?  And isn't there some less
> >obnoxious way to check that the file is a sockfs one?  Let's see:
> >struct socket *sock_from_file(struct file *file, int *err)
> >{
> >         if (file->f_op == &socket_file_ops)
> >                 return file->private_data;      /* set in sock_map_fd */
> >
> >         *err = -ENOTSOCK;
> >         return NULL;
> >}
> >... and the first line is exactly that - a check that we are on sockfs.
> >_Far_ less expensive one, at that, so it's not even that we are avoiding
> >a costly test.  In other words, all masturbation with d_path() is absolutely
> >pointless.
> >
> >Furthermore, it's racy; had been even more so before the delayed fput series
> >went in, but even now it's not safe.  fcheck_files() does *NOT* guarantee
> >that file is not getting closed right now.  rcu_read_lock() prevents only
> >freeing and potential reuse of struct file we'd got; it might go all the
> >way through final fput() just as we look at it.  So file->f_path is not
> >protected by anything.  Worse yet, neither is struct socket itself - we
> >might be going through sock_release() at the same time, so sock->sk might
> >very well be NULL, leaving us a oops even after we dump d_path() idiocy.
> >
> >To make it even funnier, there's such thing as SCM_RIGHTS datagrams and
> >descriptor passing.  In other words, it's *not* going to catch all sockets
> >that would be caught by the earlier variant.
> >
> 
Yes, thank you Al, I should have reviewed this more throughly.  

> OK clearly I screwed it up thanks for reviewing Al. How about this.
> 
>                 fdt = files_fdtable(files);
>                 for (fd = 0; fd < fdt->max_fds; fd++) {
>                         struct socket *sock;
>                         int err = 0;
> 
>                         sock = sockfd_lookup(fd, &err);
>                         if (!sock) {
>                                 lock_sock(sock->sk);
What are you protecting with lock_sock here?  The other call sites don't make
use of the socket lock.  Arguagbly they could, but I don't think they need to.
As long as the fd doesn't go away we should be able to update the
sk_cgrp_prioidx safely.

Regards
Neil
