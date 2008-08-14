From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
	iptables nat routing
Date: Wed, 13 Aug 2008 20:08:20 -0600
Message-ID: <1218679700.23510.8.camel@2710p.home>
References: <bug-11316-10286@http.bugzilla.kernel.org/>
	 <20080812221204.46afb4a6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	bugme-daemon <bugme-daemon@bugzilla.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>, buytenh@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:16940 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbYHNCOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 22:14:21 -0400
In-Reply-To: <20080812221204.46afb4a6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


git bisect traced the problem back to this changeset:

        commit e5a4a72d4f88f4389e9340d383ca67031d1b8536
        Author: Lennert Buytenhek <buytenh@marvell.com>
        Date:   Sun Aug 3 01:23:10 2008 -0700
        
            net: use software GSO for SG+CSUM capable netdevices

I've verified that I can toggle the slowness by reverting this patch on
top of 8d0968ab (current head).  The problem is readily reproducible
using Ubuntu Hardy in a KVM VM with upstream, defconfig kernel.


On Tue, 2008-08-12 at 22:12 -0700, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 12 Aug 2008 22:04:41 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11316
> > 
> >            Summary: severe performance regression for iptables nat routing
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.27-rc3
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Netfilter/Iptables
> >         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
> >         ReportedBy: alex.williamson@hp.com
> > 
> > 
> > Latest working kernel version: 2.6.26.2
> > Earliest failing kernel version: 2.6.27-rc2 (maybe earlier)
> > Distribution: Ubuntu
> > Hardware Environment: x86_64
> > Software Environment: 32bit userspace/64bit kernel
> > Problem Description: When using iptables to intercept addr:port and reroute
> > through an ssh tunnel, I see a huge performance hit on the 2.6.27-rc series
> > relative to 2.6.26 (34KB/s vs 1+MB/s).
> > 
> > Steps to reproduce:
> > 
> > Setup and ssh tunnel to one of the kernel.org servers using a system on your
> > local network:
> > 
> > ssh -L 8888:204.152.191.37:80 <local system>
> > 
> > Leave the ssh session running.  In a new terminal (on your local system),
> > verify performance of direct access versus the tunnel:
> > 
> > wget -O /dev/null
> > http://204.152.191.37/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> > wget -O /dev/null
> > http://127.0.0.1:8888/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> > 
> > These should be roughly the same.  Now setup iptables so that when you try to
> > access 204.152.191.37:80 you'll automatically be redirected to the ssh tunnel:
> > 
> > sudo iptables -t nat -N bug
> > sudo iptables -t nat -I OUTPUT 1 -j bug
> > sudo iptables -t nat -A bug -d 204.152.191.37 -p tcp --dport 80 -j DNAT
> > --to-destination 127.0.0.1:8888
> > 
> > Repeat the performance test:
> > 
> > wget -O /dev/null
> > http://204.152.191.37/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> > wget -O /dev/null
> > http://127.0.0.1:8888/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> > 
> > On 2.6.27-rc2+ My rate quickly drops down to ~34KB/s using the iptables nat'd
> > wget (204.152.191.37) while the ssh tunnel still runs 1+MB/s.  On 2.6.26 I get
> > similar performance for both paths.
> > 
> 
-- 
Alex Williamson                             HP Open Source & Linux Org.

