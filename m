From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [Bugme-new] [Bug 11058] New: DEADLOOP in kernel network module
Date: Wed, 9 Jul 2008 15:27:06 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807091519380.11391@blackhole.kfki.hu>
References: <bug-11058-10286@http.bugzilla.kernel.org/>
 <20080708210014.a1d3baf8.akpm@linux-foundation.org> <4874B2DC.2070305@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, hemao77@gmail.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4874B2DC.2070305@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Jul 2008, Patrick McHardy wrote:

> Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Tue,  8 Jul 2008 20:13:20 -0700 (PDT) bugme-daemon@bugzilla.kernel.org
> > wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=11058
> > > 
> > >            Summary: DEADLOOP in kernel network module
[...]
> > > How the DEADLOOP happened?
> > > 
> > >     (1)in ctnetlink_del_conntrack()(runs in system call context): the
> > > del_timer
> > > is called and then goes to timeout.function.
> > >     (2)before timeout.function finish excution(means the conntrack not
> > > removed),an interrupt happens and a SYN packet of  the same conntrack
> > > comes.CPU goes to irq handle and enventually runs tcp_packet().
> > >     (3)in tcp_packet() ,del_timer() will fail because the timer was
> > > already deleted. the timeout.function in tcp_packet will not run,
> > > -NF_REPEAT is returned, the SYN packet will be passed back again.
> > >     (4)Neither side has the chance to run timeout.function,the
> > > conntrack remains there,deadloop happen,the SYN packet will be passed back
> > > again and again.
> > > 
> > > The fix maybe,add lock the softirq when doing conntrack removing:
> > > +++    local_bh_disable();
> > >       if (del_timer(&ct->timeout))                /*deactive the timer*/
> > >          ct->timeout.function((unsigned long) ct);/*remove conntrack from
> > > conntrack table*/
> > > +++    local_bh_enable();
> > > 
> > > Thanks, may this be helpful.
> > > My email: hemao77@gmail.com
> > > 
> > > It is hard to reproduce , but it really happen on our linux box.
> > > 
> > 
> > Thanks.
> > 
> > Please submit patches via email as described in
> > Documentation/SubmittingPatches.  The file ./MAINTAINERS can be used to
> > determine which individuals and mailing lists the patch should be sent to.
> > 
> > But that's for next time - this patch is small enough for the netfilter
> > developers to be able to type in again ;)
> 
> Good catch, thanks. Basically all del_timer()/timeout.function calls
> in conntrack can happen in process context, so we'd have to disable
> BHs every time we do this. I think this fix should also work. The
> only spot where we return NF_REPEAT is in TCP conntrack, so we can
> simply make sure we only do this if we actually managed to kill the
> connection.
> 
> Jozsef, what do you think?

I agree with you completely - and nice catch, indeed! Your proposed patch 
looks just fine.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
