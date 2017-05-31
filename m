From: Harald Welte <laforge@gnumonks.org>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Wed, 31 May 2017 20:11:08 +0200
Message-ID: <20170531181108.3kv5xqszwv5ub7cy@nataraja>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
 <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
 <20170531122752.siaou43verg4epep@nataraja>
 <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:34440 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdEaSPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:15:05 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Wed, May 31, 2017 at 10:44:53AM -0700, Cong Wang wrote:
> >> Net namespace simply unregisters all netdevices inside when it is
> >> gone, no matter where they are from.
> >
> > ah, ok. I missed that part.  Is there a good piece of documentation on
> > netwokr namespaces that I should read?
> 
> I don't know any doc mentioning this.

That's of course a pity.  I'll see what can be done about amending the
netns related manpage or the like.

> >> > Of course I know I could simply do something like "ip link set eth0
> >> > netns 1" from within the namespace before leaving.  But what if the
> >> > process is not bash and the process exits abnormally?   I'd consider
> >> > that explicit reassignment more like a hack than a proper solution...
> >>
> >> It doesn't make sense to move it back to where it is from, for example,
> >> what if you move a veth0 from netns1 to netns2 and netns1 is gone
> >> before netns2?
> >
> > for virtual devices, I would agree.  For physical devices, I think the
> > default behavior to unregister them is - from my of course very
> > subjective point of view - quite questionable.
> 
> Network namespace does not special-case the physical devices,
> it treats them all equally as abstract net devices.

I hear you, and I understand that of course from a developer point of
view it makes sense to treat all devices the same.  I just wonder if
from an usability point of view this is the best choice.  Virtual
devices can be (re)created at any time, physical not.

I mean, what is the *use case* for loosing any refrence to a physical
network device and unregistering it from the stack?  Is there any API by
which a new netdevice structure can be instantiated on the actual
hardware?  Registering the netdev is what the driver does during
discovering the system hardware.  If there's a method to "automagically"
loose devices, at the very least I wold expect some reasonable method to
resurrect them.  Unloading the kernel module and reloading it is for
sure not elegant, particularly not if you have multiple Ethernet
devices/ports sharing the same driver.

One could e.g. also think of something like a special namespace that
collects all the "orphan" netdevices.  Something analogous to the old
Unix tradition of "pid 1" collecting all the orphan tasks whose parents
died.  Transferring them into that "netdev orphanage" could
automatically set the link down so that no accidential
routing/forwarding of traffic between the devices is possible.

This is just my two cents.  Given my past involvement in Linux
networking I allow myself having an opinion on such matters.  But if the
kernel networking community thinks it is ok to loose all references to a
physical network device due to processes terminating irregularly (which
will happen, as indicated in OOM or software bug cases), then I will of
course have to accept that.

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
