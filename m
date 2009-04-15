From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Lguest] [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 06:23:29 -0700
Message-ID: <m18wm2rqy6.fsf@fess.ebiederm.org>
References: <200903271022.38244.rusty@rustcorp.com.au>
	<1238709324.5823.8.camel@odie.local>
	<1239043798.27826.93.camel@zetabook>
	<200904081021.39877.rusty@rustcorp.com.au>
	<1239224319.17844.16.camel@zetabook> <49DDE91A.8060603@trash.net>
	<49DDF614.1060909@trash.net> <m1bpr6hqrm.fsf@fess.ebiederm.org>
	<49E47976.8020005@trash.net>
	<20090415083610.GA8579@gondor.apana.org.au>
	<20090415084717.GA8829@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Matias Zabaljauregui <zabaljauregui@gmail.com>, odie@cs.aau.dk,
	Rusty Russell <rusty@rustcorp.com.au>, lguest@ozlabs.org,
	virtualization@lists.osdl.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56416 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbZDONXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 09:23:43 -0400
In-Reply-To: <20090415084717.GA8829@gondor.apana.org.au> (Herbert Xu's message of "Wed\, 15 Apr 2009 16\:47\:17 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Wed, Apr 15, 2009 at 04:36:10PM +0800, Herbert Xu wrote:
>> 
>> Let me whip up a patch.
>
> tun: Fix sk_sleep races when attaching/detaching
>
> As the sk_sleep wait queue actually lives in tfile, which may be
> detached from the tun device, bad things will happen when we use
> sk_sleep after detaching.
>
> Since the tun device is the persistent data structure here (when
> requested by the user), it makes much more sense to have the wait
> queue live there.  There is no reason to have it in tfile at all
> since the only time we can wait is if we have a tun attached.
> In fact we already have a wait queue in tun_struct, so we might
> as well use it.

There is a GIGANTIC reason to have the wait queue on tfile.

If you open a file, and do ip link del tapN you can still
be blocked waiting in poll.

The problem is specifically free_poll_entry, where we call
remove_wait_queue and fput without calling any file methods.
So all of this happens without struct tun_file's count being
elevated.  Which means tun_net_uninit can detach before we get
off of the stupid poll wait queue.

As documented in:

commit b2430de37ef0bc0799ffba7b5219d38ca417eb76
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Jan 20 11:03:21 2009 +0000

    tun: Move read_wait into tun_file
    
    The poll interface requires that the waitqueue exist while the struct
    file is open.  In the rare case when a tun device disappears before
    the tun file closes we fail to provide this property, so move
    read_wait.
    
    This is safe now that tun_net_xmit is atomic with tun_detach.
    
    Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>



I specifically moved the wait queue out of tun struct to avoid this
race.

I will see about getting the vfs to do something saner in my generic
revoke work.  But for 2.6.30 we have to live with the nasties that
are there.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Eric
