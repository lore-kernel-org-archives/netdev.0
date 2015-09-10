From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 15:35:20 -0300
Message-ID: <20150910183520.GD4496@localhost.localdomain>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <55F096EB.7000204@gmail.com>
 <55F09F57.6080602@gmail.com>
 <55F1847A.9010801@gmail.com>
 <55F19243.3010006@gmail.com>
 <55F1A6AE.2010804@gmail.com>
 <20150910162454.GB4496@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbbIJSf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 14:35:27 -0400
Content-Disposition: inline
In-Reply-To: <20150910162454.GB4496@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 01:24:54PM -0300, Marcelo Ricardo Leitner wrote:
> On Thu, Sep 10, 2015 at 11:50:06AM -0400, Vlad Yasevich wrote:
> > On 09/10/2015 10:22 AM, Marcelo Ricardo Leitner wrote:
> > > Em 10-09-2015 10:24, Vlad Yasevich escreveu:
> ...
> > >> Then you can order sctp_net_init() such that it happens first, then protosw registration
> > >> happens, then control socket initialization happens, then inet protocol registration
> > >> happens.
> > >>
> > >> This way, we are always guaranteed that by the time user calls socket(), protocol
> > >> defaults are fully initialized.
> > > 
> > > Okay, that works for module loading stage, but then how would we handle new netns's? We
> > > have to create the control socket per netns and AFAICT sctp_net_init() is the only hook
> > > called when a new netns is being created.
> > > 
> > > Then if we move it a workqueue that is scheduled by sctp_net_init(), we loose the ability
> > > to handle its errors by propagating through sctp_net_init() return value, not good.
> > 
> > Here is kind of what I had in mind.  It's incomplete and completely untested (not even
> > compiled), but good enough to describe the idea:
> ...
> 
> Ohh, ok now I get it, thanks. If having two pernet_subsys for a given
> module is fine, that works for me. It's clearer and has no moment of
> temporary failure.
> 
> I can finish this patch if everybody agrees with it.
> 
> > >>> I used the list pointer because that's null as that memory is entirely zeroed when alloced
> > >>> and, after initialization, it's never null again. Works like a lock/condition without
> > >>> using an extra field.
> > >>>
> > >>
> > >> I understand this a well.  What I don't particularly like is that we are re-using
> > >> a list without really stating why it's now done this way.  Additionally, it's not really
> > >> the last that happens so it's seems kind of hacky...  If we need to add new
> > >> per-net initializers, we now need to make sure that the code is put in the right
> > >> place.  I'd just really like to have a cleaner solution...
> > > 
> > > Ok, got you. We could add a dedicated flag/bit for that then, if reusing the list is not
> > > clear enough. Or, as we are discussing on the other part of thread, we could make it block
> > > and wait for the initialization, probably using some wait_queue. I'm still thinking on
> > > something this way, likely something more below than sctp then.
> > > 
> > 
> > I think if we don the above, the second process calling socket() will either find the
> > the protosw or will try to load the module also.  I think either is ok after
> > request_module returns we'll look at the protosw and will find find things.
> 
> Seems so, yes. Nice.

I was testing with it, something is not good. I finished your patch and
testing with a flooder like:
 # for j in {1..5}; do for i in {1234..1280}; do \
       sctp_darn -H 192.168.122.147 -P $j$i -l & done & done

The system didn't crash, but I got:
[1] 13507
[2] 13508
[3] 13510
[4] 13513
[5] 13517
[mrl@localhost ~]$ sctp_darn: failed to create socket:  Socket type not
supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn listening...
sctp_darn listening...
sctp_darn listening...
sctp_darn listening...
...
sctp_darn listening...
sctp_darn listening...
sctp_darn listening...
sctp_darn listening...
sctp_darn: failed to create socket:  Socket type not supported.
sctp_darn listening...
sctp_darn listening...

And with this applied:
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -289,6 +289,7 @@ lookup_protocol:
        if (unlikely(err)) {
                if (try_loading_module < 2) {
                        rcu_read_unlock();
+                       printk("%p loading proto module\n", sock);
                        /*
                         * Be more specific, e.g. net-pf-2-proto-132-type-1
                         * (net-pf-PF_INET-proto-IPPROTO_SCTP-type-SOCK_STREAM)
@@ -303,6 +304,8 @@ lookup_protocol:
                        else
                                request_module("net-pf-%d-proto-%d",
                                               PF_INET, protocol);
+
+                       printk("%p done loading proto module\n", sock);
                        goto lookup_protocol;
                } else
                        goto out_rcu_unlock;


During that test, it showed:
[  732.261730] ffff8800da2ce300 loading proto module
               ^^^^^^^^^^^^^^^^ (1)    (first printed line)
[  732.262077] ffff8800da2ca680 loading proto module
[  732.262285] ffff8800da2c8b00 loading proto module
[  732.262421] ffff8800da2ccd00 loading proto module
[  732.263763] ffff8800da2c8580 loading proto module
[  732.265872] ffff8800da2cd280 loading proto module
[  732.270517] ffff8800da2cf900 loading proto module
[  732.270626] ffff8800da2c9080 loading proto module
[  732.272170] ffff8800da2c8580 done loading proto module
[  732.273042] ffff8800da2c8580 loading proto module
[  732.277248] ffff8800da2cf380 loading proto module
[  732.278495] ffff8800da2ca680 done loading proto module
[  732.278916] ffff8800da2cd280 done loading proto module
[  732.278918] ffff8800da2cd280 loading proto module
...
[  732.281171] ffff8800da2ce300 done loading proto module
               ^^^^^^^^^^^^^^^^ (1)
[  732.281173] ffff8800da2ce300 loading proto module
               ^^^^^^^^^^^^^^^^ (1)
...
[  732.321299] ffff880034995800 loading proto module
[  732.461481] ffff880034995800 done loading proto module
[  732.461482] ffff880034995800 loading proto module
[  732.461483] ffff880034995800 done loading proto module
               ^^^^^^^^^^^^^^^^   an attempt that tried both aliases
	                          quickly and returned before sctp was
				  initialized
...
[  732.489413] sctp: Hash tables configured (established 1638 bind 1638)
...
[  732.634034] ffff8800da2ce300 done loading proto module
               ^^^^^^^^^^^^^^^^ (1)  nearly 400ms later

Also got:
$ dmesg | grep runaw
[  732.439598] request_module: runaway loop modprobe
net-pf-2-proto-132-type-5
[  732.442017] request_module: runaway loop modprobe net-pf-2-proto-132
[  732.449195] request_module: runaway loop modprobe
net-pf-2-proto-132-type-5
[  732.451946] request_module: runaway loop modprobe net-pf-2-proto-132
[  732.458970] request_module: runaway loop modprobe
net-pf-2-proto-132-type-5
[  732.460380] request_module: runaway loop modprobe
net-pf-2-proto-132-type-5

Such socket() calls failed (and some other too), as per (kernel/kmod.c):
__request_module()
{
...
        max_modprobes = min(max_threads/2, MAX_KMOD_CONCURRENT);
        atomic_inc(&kmod_concurrent);
        if (atomic_read(&kmod_concurrent) > max_modprobes) {
                /* We may be blaming an innocent here, but unlikely */
                if (kmod_loop_msg < 5) {
                        printk(KERN_ERR
                               "request_module: runaway loop modprobe %s\n",
                               module_name);
                        kmod_loop_msg++;
                }
                atomic_dec(&kmod_concurrent);
                return -ENOMEM;
        }
...
}

FWIW, my test system has 8 threads.

It seems that request_module will not serialize it as we wanted and we
would be putting unexpected pressure on it, yet it fixes the original
issue. Maybe we can place a semaphore at inet_create(), protecting the
request_module()s so only one socket can do it at a time and, after it
is released, whoever was blocked on it re-checks if the module isn't
already loaded before attempting again. It makes the loading of
different modules slower, though, but I'm not sure if that's really a
problem. Not many modules are loaded at the same time like that. What do
you think? 

  Marcelo
