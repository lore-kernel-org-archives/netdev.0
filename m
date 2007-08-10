From: David Miller <davem@davemloft.net>
Subject: Re: [patch 26/28] netconsole: Support dynamic reconfiguration
 using configfs
Date: Fri, 10 Aug 2007 15:35:23 -0700 (PDT)
Message-ID: <20070810.153523.57443099.davem@davemloft.net>
References: <200708102112.l7ALC9oD009457@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org,
	Joel.Becker@oracle.com, k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753424AbXHJWfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:35:23 -0400
In-Reply-To: <200708102112.l7ALC9oD009457@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:09 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.
> 
> This patch introduces support for dynamic reconfiguration (adding, removing
> and/or modifying parameters of netconsole targets at runtime) using a
> userspace interface exported via configfs.  Documentation is also updated
> accordingly.
> 
> Issues and brief design overview:
> 
> (1) Kernel-initiated creation / destruction of kernel objects is not
>     possible with configfs -- the lifetimes of the "config items" is managed
>     exclusively from userspace.  But netconsole must support boot/module
>     params too, and these are parsed in kernel and hence netpolls must be
>     setup from the kernel.  Joel Becker suggested to separately manage the
>     lifetimes of the two kinds of netconsole_target objects -- those created
>     via configfs mkdir(2) from userspace and those specified from the
>     boot/module option string.  This adds complexity and some redundancy here
>     and also means that boot/module param-created targets are not exposed
>     through the configfs namespace (and hence cannot be updated / destroyed
>     dynamically).  However, this saves us from locking / refcounting
>     complexities that would need to be introduced in configfs to support
>     kernel-initiated item creation / destroy there.
> 
> (2) In configfs, item creation takes place in the call chain of the
>     mkdir(2) syscall in the driver subsystem.  If we used an ioctl(2) to
>     create / destroy objects from userspace, the special userspace program is
>     able to fill out the structure to be passed into the ioctl and hence
>     specify attributes such as local interface that are required at the time
>     we set up the netpoll.  For configfs, this information is not available at
>     the time of mkdir(2).  So, we keep all newly-created targets (via
>     configfs) disabled by default.  The user is expected to set various
>     attributes appropriately (including the local network interface if
>     required) and then write(2) "1" to the "enabled" attribute.  Thus,
>     netpoll_setup() is then called on the set parameters in the context of
>     _this_ write(2) on the "enabled" attribute itself.  This design enables
>     the user to reconfigure existing netconsole targets at runtime to be
>     attached to newly-come-up interfaces that may not have existed when
>     netconsole was loaded or when the targets were actually created.  All this
>     effectively enables us to get rid of custom ioctls.
> 
> (3) Ultra-paranoid configfs attribute show() and store() operations, with
>     sanity and input range checking, using only safe string primitives, and
>     compliant with the recommendations in Documentation/filesystems/sysfs.txt.
> 
> (4) A new function netpoll_print_options() is created in the netpoll API,
>     that just prints out the configured parameters for a netpoll structure. 
>     netpoll_parse_options() is modified to use that and it is also exported to
>     be used from netconsole.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Joel Becker <Joel.Becker@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This looks good to me, applied to net-2.6.24, thanks!
