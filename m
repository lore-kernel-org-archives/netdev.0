From: Horms <horms@verge.net.au>
Subject: Re: [ipvs] BUG: soft lockup detected on CPU#3!
Date: Tue, 29 May 2007 10:08:25 +0900
Message-ID: <20070529010824.GB3873@verge.net.au>
References: <446f47c20705221019j34de745fj9aad8633a6edfd54@mail.gmail.com> <20070525084645.GA14817@verge.net.au> <446f47c20705250230n6d43b6eu4b163a170fdc6007@mail.gmail.com> <20070526022239.GD4169@verge.net.au> <20070528093645.GA30207@verge.net.au> <446f47c20705280720t3719a484iccbe6ae52f9d0aff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, ja@ssi.bg, nedev <netdev@vger.kernel.org>
To: Sebastien Estienne <sebastien.estienne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:59305 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122AbXE2BI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 21:08:29 -0400
Content-Disposition: inline
In-Reply-To: <446f47c20705280720t3719a484iccbe6ae52f9d0aff@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 28, 2007 at 04:20:32PM +0200, Sebastien Estienne wrote:
> On 5/28/07, Horms <horms@verge.net.au> wrote:
> >On Sat, May 26, 2007 at 11:22:40AM +0900, Horms wrote:
> >> On Fri, May 25, 2007 at 09:30:52AM +0000, Sebastien Estienne wrote:
> >> >
> >> > I didn't try 2.6.21 yet, but using ubuntu dapper kernel (2.6.15) i
> >> > can't reproduce the bug.
> >> > When i was using feisty kernel (2.6.20), i can reproduce in less than 5
> >> > minutes.
> >> >
> >> > I'm using lvs to loadbalance some mysql servers, i wrote a deamon that
> >> > check the synchro of the mysql replication on each slave and adjust
> >> > the wieght on the lvs every 500ms
> >>
> >> It does look a lot like there is some sort of locking problem in there.
> >> Would it be possible to send your kernel config, as the locking
> >> deatails to change a little with different configs.
> >
> 
> About the kernel .config, i'm using the vanilla kernel "-server" from
> ubuntu feisty
> 
> >If you also have some details of you ipvs configuration,
> >that might help narrow down which code-paths to investigate.
> >
> 
> i attached the output of ipvsadm-save
> 
> i'm adjusting the weight every 500ms by generating lines like this:
> -e -t 10.33.1.231:3306 -r 10.33.1.1 -w 100

Thanks.

> and piping all the needed changes in ipvadm -R
> 
> it can represent something like 20 to 40 updates in one time.
> 
> i also noticed that sometimes when i execute "ipvsadm" the display get
> locked in the middle for a second and then finish.

That is probably related. Though the fact that it eventually
exits seems to indicate that you're not hitting II.

> >II.
> >
> >ip_vs_set_ctl() does seem to leak svc->usecnt in one corner case,
> >but I doubt that is what you are seeing - if it was your ipvsadm
> >command(s) would hang. The problem is a bit wordy to describe,
> >but this fix should illustrate the problem.
> >
> >--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c
> >+++ linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
> >@@ -2000,7 +2000,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cm
> >        if (cmd != IP_VS_SO_SET_ADD
> >            && (svc == NULL || svc->protocol != usvc->protocol)) {
> >                ret = -ESRCH;
> >-               goto out_unlock;
> >+               goto out_svc;
> >        }
> >
> >        switch (cmd) {
> >@@ -2034,9 +2034,9 @@ do_ip_vs_set_ctl(struct sock *sk, int cm
> >                ret = -EINVAL;
> >        }
> >
> >+  out_svc:
> >        if (svc)
> >                ip_vs_service_put(svc);
> >-
> >   out_unlock:
> >        mutex_unlock(&__ip_vs_mutex);
> >   out_dec:

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

