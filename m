From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Possible race with br_del_if()
Date: Thu, 18 Aug 2005 15:12:02 -0700
Message-ID: <20050818151202.6fe6ded4@dxpl.pdx.osdl.net>
References: <20050818214036.GH10593@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ryan Harper <ryanh@us.ibm.com>
In-Reply-To: <20050818214036.GH10593@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Aug 2005 16:40:36 -0500
Ryan Harper <ryanh@us.ibm.com> wrote:

> Hello,
> 
> I've encountered several oops when adding and removing interfaces from
> bridges while using Xen.  Most of the details are available [1]here.
> The short of it is the following sequence:

Doesn't the mutex in RTNL work right?  or are you calling
routines with out asserting it?

> CPU0                    CPU1
> add_del_if()            unregister_netdevice()  
> br_del_if()             notifier_call_chain(NETDEV_UNREGISTER) 
> del_nbp()               
> br_stp_disable_port()   // port->state == BR_STATE_DISABLED
>                         br_device_event() // dev->br_port != NULL yet
>                                           // event is NETDEV_UNREGISTER
>                         br_del_if()
>                         sysfs_remove_dir(p)
>                         kobject_del()
>                         dget(dentry)
>                         BUG_ON(!atomic_read(&dentry->d_count)
> 
> This sequence doesn't happen all of the time.  In many cases, CPU0 moves
> along right into destroy_nbp() which sets dev->br_port = NULL, and
> be_device_event check (p == NULL) hits and a second br_del_if() isn't
> called.
> 
> The attached patch is a workaround for the double case, but I'm not sure
> if is the right way to deal with this issue, or if it any issue at all.
> 
> 1. http://bugzilla.xensource.com/bugzilla/show_bug.cgi?id=90
> 
