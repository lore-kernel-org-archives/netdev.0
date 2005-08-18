From: Ryan Harper <ryanh@us.ibm.com>
Subject: Re: Possible race with br_del_if()
Date: Thu, 18 Aug 2005 17:56:01 -0500
Message-ID: <20050818225601.GJ10593@us.ibm.com>
References: <20050818214036.GH10593@us.ibm.com> <20050818151202.6fe6ded4@dxpl.pdx.osdl.net> <20050818222323.GI10593@us.ibm.com> <20050818153531.61f62ac0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050818153531.61f62ac0@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Stephen Hemminger <shemminger@osdl.org> [2005-08-18 17:36]:
> On Thu, 18 Aug 2005 17:23:23 -0500
> Ryan Harper <ryanh@us.ibm.com> wrote:
> 
> > * Stephen Hemminger <shemminger@osdl.org> [2005-08-18 17:11]:
> > > On Thu, 18 Aug 2005 16:40:36 -0500
> > > Ryan Harper <ryanh@us.ibm.com> wrote:
> > > 
> > > > Hello,
> > > > 
> > > > I've encountered several oops when adding and removing interfaces from
> > > > bridges while using Xen.  Most of the details are available [1]here.
> > > > The short of it is the following sequence:
> > > 
> > > Doesn't the mutex in RTNL work right?  or are you calling
> > > routines with out asserting it?
> > 
> > unregister_netdevice asserts RTNL, add_del_if() in br_ioctl.c doesn't
> > seem to do so.  I don't see it down dev_get_by_index() path either.  It
> > looks like any caller of add_del_if() isn't asserting RTNL.  The two
> > callers I see are:
> > 
> > br_dev_ioctl() in br_ioctl.c
> > old_dev_ioctl() in br_ioctl.c
> 
> But the pat to br_dev_ioctl() is via the socket ioctl and that
> should already have gotten RTNL.
> 
> 
> dev_ioctl
> 	rtnl_lock()
> 	dev_ifsioc()
> 		dev->do_ioctl --> br_dev_ioctl

Hrm. OK.  It sounds like both paths are doing the right thing w.r.t
asserting RTNL, but br_device_event() still gets called with:

1) dev->br_port != NULL 
2) dev->br_port->state = BR_STATE_DISABLED
3) event = NETDEV_UNREGISTER

which results in br_del_if() being called a second time on the same
port.  

Some of the other cases  (NETDEV_FEAT_CHANGE, NETDEV_CHANGE) do a state
check before calling a subsequent function.  Does it make sense for
br_del_if() to be called on a port whose state is BR_STATE_DISABLED?

-- 
Ryan Harper
Software Engineer; Linux Technology Center
IBM Corp., Austin, Tx
(512) 838-9253   T/L: 678-9253
ryanh@us.ibm.com
