From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 15/17] switch kernel_sendmsg() and kernel_recvmsg() to
 iov_iter_kvec()
Date: Wed, 15 Apr 2015 09:08:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1E86A@AcuExch.aculab.com>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-15-git-send-email-viro@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CB1DD9D@AcuExch.aculab.com>
 <20150414163403.GY889@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CB1DE00@AcuExch.aculab.com>
 <20150414165920.GB889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:56005 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbbDOJK1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 05:10:27 -0400
In-Reply-To: <20150414165920.GB889@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro
> Sent: 14 April 2015 17:59
> On Tue, Apr 14, 2015 at 04:36:36PM +0000, David Laight wrote:
> > From: Al Viro
> > > Sent: 14 April 2015 17:34
> > > On Tue, Apr 14, 2015 at 04:21:02PM +0000, David Laight wrote:
> > >
> > > > Massive NAK.
> > > > This breaks any code that is using msg_control to set SCTP parameters
> > > > when sending data.
> > >
> > > 	Huh?  ->sendmsg() expects ->msg_control already in kernel space;
> > > it's ->recvmsg() that plays silly buggers with userland pointers there.
> >
> > I read your commit message as implying that you hadn't found any
> > users of kernel_sendmsg() that used msg_control.
> > Not that the data was always read from kernel space.
> 
> Sigh...  The situation is:
> 	* ->sendmsg() expects ->msg_control copied to userland.  sendmsg(2),
> sendto(2), etc. do that copying.  See ___sys_sendmsg() - there we have
>                 /*
>                  * Careful! Before this, msg_sys->msg_control contains a user pointer.
>                  * Afterwards, it will be a kernel pointer. Thus the compiler-assisted
>                  * checking falls down on this.
>                  */
>                 if (copy_from_user(ctl_buf,
>                                    (void __user __force *)msg_sys->msg_control,
>                                    ctl_len))
>                         goto out_freectl;
>                 msg_sys->msg_control = ctl_buf;
> As the result, ->sendmsg() instances access ->msg_control contents as normal
> kernel data.
> 	* ->recvmsg() expects ->msg_control to point to userland.  See
> net/core/scm.c for the helpers used to store into it.  recvmsg(2) et.al.
> simply leave the userland pointer there; worse, that pointer might be
> to native or to compat variants, and layouts _are_ different.  Thus those
> if (MSG_CMSG_COMPAT & msg->msg_flags) in net/core/scm.c...
> 	* kernel-side users of ->sendmsg() do not depend on setfs() for
> access to their ->msg_control, simply because ->sendmsg() won't be using
> copy_from_user()/get_user() to access it anyway.
> 	* kernel-side users of ->recvmsg() are less lucky - most of them
> don't give a damn either (they have NULL ->msg_control), but there's an
> exception (somewhere in sunrpc, IIRC).  So there we need to keep
> playing with setfs(), even though the data side would be just fine without
> that.

Apart from any other code that is using the interface.
I know you guys don't do anything to help out of tree code, but removing the setfs()
stuff from the kernel_recvmsg() code would break anything using sctp.
It shouldn't need some code lurking in sunrpc for you to leave the setfs().

In any case, how much does the setfs() cost?
I suspect it is just modifying a flag in 'current'.

A comment in kernel_recvmsg() saying that the setfs() is for msg_control
might be useful.
Then one in kelnel_sendmsg() saying that setfs() isn't needed because
msg_control is always kernel - just to avoid any confusion.

	David
