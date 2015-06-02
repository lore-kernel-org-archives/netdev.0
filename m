From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg and
 sendmsg
Date: Tue, 2 Jun 2015 13:44:49 +0900
Message-ID: <20150602044449.GA19083@kroah.com>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
 <20150602012154.GB23370@kroah.com>
 <556D2B8C.9010108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lizefan@huawei.com, viro@zeniv.linux.org.uk, davem@davemloft.net,
	xuhanbing@huawei.com, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Junling Zheng <zhengjunling@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:55157 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbbFBEox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 00:44:53 -0400
Content-Disposition: inline
In-Reply-To: <556D2B8C.9010108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2015 at 12:05:32PM +0800, Junling Zheng wrote:
> On 2015/6/2 9:21, Greg KH wrote:
> > On Mon, Jun 01, 2015 at 09:28:00AM +0000, Junling Zheng wrote:
> >> Hi, Greg:
> >>
> >> We found that after v3.10.73, recvmsg might return -EFAULT while -EINVAL
> >> was expected.
> > 
> > That means I messed up and applied something I shouldn't have, right?
> > 
> > Can you use 'git bisect' to find the problem patch?  That's probably
> > easier here, and then I can either revert it, or fix up a broken
> > backport.
> > 
> 
> The following is the log of 'git bisect' between v3.10.72 and v3.10.73:
> 
> z00238152@Patch-Test:linux-3.10>0$ git bisect log
> git bisect start
> # good: [7f4e64246049cef5ae1eca37eec1701a9477799e] Linux 3.10.72
> git bisect good 7f4e64246049cef5ae1eca37eec1701a9477799e
> # bad: [73895725a9401bd3454757fcfa7d691270ac7498] Linux 3.10.73
> git bisect bad 73895725a9401bd3454757fcfa7d691270ac7498
> # bad: [d8bee0e3abef10e73a003fdc7ec04ba313334007] workqueue: fix hang involving racing cancel[_delayed]_work_sync()'s for PREEMPT_NONE
> git bisect bad d8bee0e3abef10e73a003fdc7ec04ba313334007
> # bad: [281c9c3601b69f1fbc492beb5976e1e2685854de] net: compat: Update get_compat_msghdr() to match copy_msghdr_from_user() behaviour
> git bisect bad 281c9c3601b69f1fbc492beb5976e1e2685854de
> # good: [e2f572a9be3f00bcf470a918d9e53353bea9ef4c] net: sysctl_net_core: check SNDBUF and RCVBUF for min length
> git bisect good e2f572a9be3f00bcf470a918d9e53353bea9ef4c
> # good: [c77b9a724d8597e1151b1fcf013560188088dc8c] caif: fix MSG_OOB test in caif_seqpkt_recvmsg()
> git bisect good c77b9a724d8597e1151b1fcf013560188088dc8c
> # good: [742c1c523e50723c7b7ff0af228c6711f7d747dd] Revert "net: cx82310_eth: use common match macro"
> git bisect good 742c1c523e50723c7b7ff0af228c6711f7d747dd
> # good: [175ff19c37149c352e3b983a8d78add034aef36f] tcp: fix tcp fin memory accounting
> git bisect good 175ff19c37149c352e3b983a8d78add034aef36f
> # first bad commit: [281c9c3601b69f1fbc492beb5976e1e2685854de] net: compat: Update get_compat_msghdr() to match copy_msghdr_from_user() behaviour
> z00238152@Patch-Test:linux-3.10>0$
> 
> So, the problem commit is 281c9c36 (net: compat: Update get_compat_msghdr() to match copy_msghdr_from_user() behaviour), which fixes db31c55a6fb2
> and brings the get_compat_msghdr() in line with copy_msghdr_from_user().

Ok, but that patch itself isn't the issue, as it's "correct".  Something
else must be wrong here, did we backport db31c55a6fb2 incorrectly to
3.10-stable?  What is really causing this to be so different that your
proposed patch needs to be applied to solve it?

thanks,

greg k-h
