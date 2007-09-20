From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 20 Sep 2007 13:30:52 +0200
Message-ID: <ygftzppfuab.fsf@janus.isnogud.escape.de>
References: <20070917100321.18347.0@janus.isnogud.escape.de>
	<20070917100438.18347.2@janus.isnogud.escape.de>
	<46EFD33D.8030905@trash.net> <ygffy1bzn4c.fsf@janus.isnogud.escape.de>
	<46F0DD8E.8070808@trash.net> <ygfy7f1g1l0.fsf@janus.isnogud.escape.de>
	<46F24C8D.2020804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:51408 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbXITLfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 07:35:44 -0400
In-Reply-To: <46F24C8D.2020804@trash.net>; from Patrick McHardy on Thu, 20 Sep 2007 12:33:49 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> No, you need to add your own locking to prevent this, something
> list this:
> 
> registration/unregistration:
> 
> take lock
> change proto_tab[]
> release lock
> 
> lookup:
> 
> take lock
> cp = proto_tab[]
> if (cp && !try_module_get(cp->owner))
> 	cp = NULL
> release lock

Ah, ok.  Thanks for that hint.  I will add it that way.

> > 2. If the module gets unloaded after the first check and
> >    request_module() but before the call to try_module_get() the
> >    socket() syscall will return with error, although module auto
> >    loading would normally be successful.  How can I prevent that?
> 
> 
> Why do you want to prevent it? The admin unloaded the module,
> so he apparently doesn't want the operation to succeed.

Well, unloading a module doesn't usually cause to operation to fail
when auto loading is enabled.  It only wouldn't succeed when the
unload happens in the small window between test/request-module and
call to try_module_get().  This looks ugly to me.  But the lock you
described above would also solve this.

> I'm saying you need _rcu for the *read side*. All operations changing
> the list already use the _rcu variants.
> 
> > I'm sorry if I miss something
> > obvious here, but could you try to explain it to me?
> 
> 
> spin_lock_bh only disables BHs locally, other CPUs can still process
> softirqs. And since rcv_lists_lock is only used in process context,
> the BH disabling is actually not even necessary.

Well, I finally (hopefully) got it and I have changed the code
accordingly.  Thanks for your explanation.

I will post our updated code again, probably today.  The issues still
left are

* module parameter for loopback, but we want to keep that.
* configure option for allowing normal users access to raw and bcm CAN
  sockets.  I'll check how easily an (embedded) system can be set up
  to run relevant/all processes with the CAP_NEW_RAW capability.  I
  would like to kill that configure option.
* seq_files for proc fs.  On my TODO list.

urs
