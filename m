From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 06 Aug 2009 07:27:13 -0700
Message-ID: <m1ljlxj9vi.fsf@fess.ebiederm.org>
References: <20090803161242.12947.14620.stgit@flek.lan>
	<m1ljlyvn9a.fsf@fess.ebiederm.org>
	<200908051738.43134.paul.moore@hp.com>
	<20090806101044.GA26589@gondor.apana.org.au>
	<m1hbwlkzt6.fsf@fess.ebiederm.org>
	<20090806133746.GA28557@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46554 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbZHFO1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 10:27:17 -0400
In-Reply-To: <20090806133746.GA28557@gondor.apana.org.au> (Herbert Xu's message of "Thu\, 6 Aug 2009 23\:37\:46 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Thu, Aug 06, 2009 at 03:21:41AM -0700, Eric W. Biederman wrote:
>>
>> Two threads one file descriptor.  Both simultaneously attempt to 
>> attach to a tun device.  One will fail, the other succeed.
>> 
>> At least that is how I read the locking.
>
> Yes but the "race" fixed by this patch is centred on the tun_attach
> call for a newly created network device.  As tun_set_iff occurs
> under RTNL, the second thread cannot start attaching until the
> creation thread has completed.  IOW the thread that creates the
> net device should always succeed in attaching.

>
> If two threads try to attach to the same device that was already
> created then yes one will fail and the other succeed.  However,
> AFAICS that case has nothing to do with this patch.

Summarizing:

tun = __tun_get(tfile);
if (!tun) { // No tun we are not attached.
	 < -------------------- race opportunity
	rtnl_lock();
        tun_set_iff();
        rtnl_unlock();
}
...

We don't test if we are attached under the rtnl
until we get to tun_attach();

So two threads can both do:

tun = __tun_get(tfile);
if (!tun) {
	rtnl_lock();
        tun_set_iff();
            dev = __dev_get_by_name(net, "not_an_interface_name");
            if (!dev) {
               dev = alloc_netdev(....);
               ...;
               register_netdev(dev);
               ...;
               err = tun_attach(..);
            }


Only one thread is in tun_set_iff() at a time, but the other thread
could have attached the file to a device before the one in tun_attach().

Eric
