From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: [REGRESSION] r8169: jumbo fixes caused jumbo regressions!
Date: Wed, 14 Nov 2012 13:25:30 +0400
Message-ID: <20121114092530.GA22323@tugrik.mns.mnsspb.ru>
References: <20121113170655.GA20291@tugrik.mns.mnsspb.ru>
 <20121113223512.GA29342@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:42286 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932651Ab2KNJYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 04:24:47 -0500
Content-Disposition: inline
In-Reply-To: <20121113223512.GA29342@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 13, 2012 at 11:35:12PM +0100, Francois Romieu wrote:
> Kirill Smelkov <kirr@mns.spb.ru> :
> [...]
> > My test is to stream raw video from 8 PAL cameras to net - 4 for 720x576@25 and
> > 4 for 360x288@25 which for YUYV format occupies ~ 860 Mbps of bandwidth. The
> > program to transmit/receive video is here: http://repo.or.cz/w/rawv.git
> 
> $ git clone  http://repo.or.cz/w/rawv.git
> Cloning into 'rawv'...
> fatal: http://repo.or.cz/w/rawv.git/info/refs not valid: is this a git repository?

That's a gitweb view. The actual git repo is here:

    git://repo.or.cz/rawv.git

sorry for confusion.

( if you'll want to test with vivi on a slow system, you'll need my
  patches, currently staging in media-tree patchwork, or available here:

  git://repo.or.cz/linux-2.6/kirr.git   vivi-speedup-and-fps.over-net-next )


> [...]
> > (by the way, on atom system, without tx csum offload, half of cpu time
> > is spent only to calculate checksums...)
> 
> :o(

yes, that large. In top, my workload is

                                %sy     %id     %si
    
    default driver load         ~25     ~45     ~27
    (ethtool -k shows
     tx-checksumming: off)

    after                        ~8     ~81     ~11
    `ethtool -K eth0 tx on`
     

that's why the issue is important.


> > Now I wonder, where that 6K limit came from and why they say it is now
> > not possible to use jumbos together with tx csum offload ?
> 
> Here is an excerpt from a mail where Hayes explained the rules of
> engagement back in may 2011 (John Lumby and Chris Friesen were Cced then):

Can't find that mail in gmane netdev archive and on google, to restore
full context. Was that in private?


> ! The Max tx sizes for 8168 series are as following:
> ! 
> ! 8168B is 4K bytes.
> ! 8168C and 8168CP are 6K bytes.
> ! 8168D and later are 9K bytes.
> ! 
> ! Note that these sizes all include head size. That is, the mtu must less than
> ! these values.
> ! You have to enable Jumbo frame feature when the tx size is large, otherwise the
> ! packet would not be sent. Because the hw doesn't provide the threshold, the
> ! checking for MTU > 1500 is just for convenience for sw.

This part is clear.


> ! The TSO couldn't work with some feature which need to disable hw checksum, such
> ! as Jumbo frame. The hw checksum have to be disabled in certain situations, so
> ! the TSO feature should be checked in these situations, too.

I don't enable TSO nor I need it. The text indirectly says that hw
checksum should be disabled when jumbo frames are used.

~~~~

Hayes, Realtek linux nic maintainers,

    could you please confirm that for all 8168C and 8168CP jumbo_max is
    6K and that when jumbos are used, tx checksumming should be off?

    If so, how come my two chips work stable with ~7K jumbos and tx checksum
    offload on (tested this night again for ~16 hours without any problem).

    thanks beforehand.


> > Is my testing enough to justify raising the limits and allowing tx offload ?
> 
> I don't oppose knobs to go off-limits but I'll need some rather good reason
> before changing the manufacturer's suggested defaults.

Thanks. Let's see what Realtek people say.

Kirill
