From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Sat, 24 Nov 2007 11:14:50 +0900
Message-ID: <200711241114.FCJ30702.JSMOFQtVHFFOOL@I-love.SAKURA.ne.jp>
References: <200711212130.EJJ43745.LFOFHOSMJOtFVQ@I-love.SAKURA.ne.jp>
	<200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp>
	<Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	davem@davemloft.net, linux-security-module@vger.kernel.org,
	kaber@trash.net, netfilter-devel@lists.netfilter.org,
	sds@tycho.nsa.gov
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:56534 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbXKXCO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 21:14:56 -0500
In-Reply-To: <Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

James Morris wrote:
> From memory, one approach under discussion was to add netfilter hooks to 
> the transport layer, which could be invoked correctly by each type of 
> protocol when the target process is selected.
> 
> If this is done for netfilter, then an LSM hook is probably not needed at 
> all, as security modules can utilize netfilter hooks directly.

Patrick McHardy says (at http://marc.info/?l=linux-netdev&m=118495005800410&w=2 )
"Even with socket filters netfilter doesn't know the final receipient
 process, that is not known until it calls recvmsg and the data is read,
 which is too late for netfilter."



> > Precautions: This approach has a side effect which unlikely occurs.
> > 
> > If a socket is shared by multiple processes with different policy,
> > the process who should be able to accept this connection
> > will not be able to accept this connection
> > because socket_post_accept() aborts this connection.
> > But if socket_post_accept() doesn't abort this connection,
> > the process who must not be able to accept this connection
> > will repeat accept() forever, which is a worse side effect.
I think this change is needed regardless of whether to use connection filtering or not.
Currently, SELinux doesn't use socket_post_accept().

|  * @socket_post_accept:
|  *	This hook allows a security module to copy security
|  *	information into the newly created socket's inode.

But if one wants to *copy* security information to accept()ed socket,
the location after fd_install() is too late to copy
because the userland process can access accept()ed socket's fd
whose security information is not copied yet.

Also, if one wants to *assign* security information to accept()ed socket,
it might attend memory allocation which can fail.
So, use of void for socket_post_accept() deprives a security module of a chance to
abort this connection if the security module failed to *assign* security information.

Regards.

