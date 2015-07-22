From: Florian Westphal <fw@strlen.de>
Subject: Re: reproducable panic eviction work queue
Date: Wed, 22 Jul 2015 15:58:55 +0200
Message-ID: <20150722135855.GB8441@breakpoint.cc>
References: <55AA243D.5020306@cumulusnetworks.com>
 <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
 <55AA717D.8080800@cumulusnetworks.com>
 <55ACEDE9.3090205@transip.nl>
 <20150720143023.GC11985@breakpoint.cc>
 <55AE3208.8090403@transip.nl>
 <20150721183453.GL11985@breakpoint.cc>
 <55AF4FD7.2010009@transip.nl>
 <55AF5193.9090900@transip.nl>
 <55AF5E2E.5030203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Schreuder <fschreuder@transip.nl>,
	Florian Westphal <fw@strlen.de>,
	Johan Schuijt <johan@transip.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39622 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754722AbbGVN7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:59:05 -0400
Content-Disposition: inline
In-Reply-To: <55AF5E2E.5030203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> On 07/22/2015 10:17 AM, Frank Schreuder wrote:
> > I got some additional information from syslog:
> > 
> > Jul 22 09:49:33 dommy0 kernel: [  675.987890] NMI watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [kworker/3:1:42]
> > Jul 22 09:49:42 dommy0 kernel: [  685.114033] INFO: rcu_sched self-detected stall on CPU { 3}  (t=39918 jiffies g=988 c=987 q=23168)
> > 
> > Thanks,
> > Frank
> > 
> > 
> 
> Hi,
> It looks like it's happening because of the evict_again logic, I think we should also
> add Florian's first suggestion about simplifying it to the patch and just skip the
> entry if we can't delete its timer otherwise we can restart the eviction and see
> entries that already had their timer stopped by us and can keep restarting for
> a long time.
> Here's an updated patch that removes the evict_again logic.

Thanks Nik.  I'm afraid this adds bug when netns is exiting.

Currently, we wait until timer has finished, but after the change
we might destroy percpu counter while a timer is still executing on
another cpu.

I pushed a patch series to
https://git.breakpoint.cc/cgit/fw/net.git/log/?h=inetfrag_fixes_02

It includes this patch with a small change -- deferral of the percpu
counter subtraction until after queue has been free'd.

Frank -- it would be great if you could test with the four patches in
that series applied.

I'll then add your tested-by Tag to all of them before submitting this.

Thanks again for all your help in getting this fixed!
