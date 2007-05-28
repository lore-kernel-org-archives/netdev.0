From: Horms <horms@verge.net.au>
Subject: Re: [ipvs] BUG: soft lockup detected on CPU#3!
Date: Mon, 28 May 2007 18:36:47 +0900
Message-ID: <20070528093645.GA30207@verge.net.au>
References: <446f47c20705221019j34de745fj9aad8633a6edfd54@mail.gmail.com> <20070525084645.GA14817@verge.net.au> <446f47c20705250230n6d43b6eu4b163a170fdc6007@mail.gmail.com> <20070526022239.GD4169@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, ja@ssi.bg, nedev <netdev@vger.kernel.org>
To: Sebastien Estienne <sebastien.estienne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:38669 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752769AbXE1Jgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 05:36:51 -0400
Content-Disposition: inline
In-Reply-To: <20070526022239.GD4169@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 26, 2007 at 11:22:40AM +0900, Horms wrote:
> On Fri, May 25, 2007 at 09:30:52AM +0000, Sebastien Estienne wrote:
> > 
> > I didn't try 2.6.21 yet, but using ubuntu dapper kernel (2.6.15) i
> > can't reproduce the bug.
> > When i was using feisty kernel (2.6.20), i can reproduce in less than 5 
> > minutes.
> > 
> > I'm using lvs to loadbalance some mysql servers, i wrote a deamon that
> > check the synchro of the mysql replication on each slave and adjust
> > the wieght on the lvs every 500ms
> 
> It does look a lot like there is some sort of locking problem in there.
> Would it be possible to send your kernel config, as the locking
> deatails to change a little with different configs.

If you also have some details of you ipvs configuration,
that might help narrow down which code-paths to investigate.

I spent some time this afternoon looking into this probem,
and what I think is happening is:

  1. Due to your weight-update operations, one processor
     is sitting in ip_vs_edit_dest() called by do_ip_vs_set_ctl(),
     holding write_lock_bh(&__ip_vs_svc_lock) and waiting
     for svc->usecnt to go down to 1.

  2. Another process is trying to grab
     read_lock(&__ip_vs_svc_lock) in ip_vs_service_get(),
     called from tcp_conn_schedule() and in turn ip_vs_in().

  I guess that for some reason svc->usecnt isn't going down to 0.
  Though I haven't been able to isolate anything particularly
  interesting.

That said, the locking isn't that simple, IMHO, so there seems
to be quite a lot of scope for errors.


Some things that are of minor insterst are:

I.
ip_vs_edit_dest() loops with the following construct:

  while (atomic_read(&svc->usecnt) > 1) {};

whereas similar code in the same file uses

  IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);

which expands to

  while (atomic_read(&svc->usecnt) > 1) { cpu_relax(); }

But I dount this is a problem, except for burning the cpu a bit harder
than it needs to.

II.

ip_vs_set_ctl() does seem to leak svc->usecnt in one corner case,
but I doubt that is what you are seeing - if it was your ipvsadm
command(s) would hang. The problem is a bit wordy to describe,
but this fix should illustrate the problem.

--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
@@ -2000,7 +2000,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cm
 	if (cmd != IP_VS_SO_SET_ADD
 	    && (svc == NULL || svc->protocol != usvc->protocol)) {
 		ret = -ESRCH;
-		goto out_unlock;
+		goto out_svc;
 	}
 
 	switch (cmd) {
@@ -2034,9 +2034,9 @@ do_ip_vs_set_ctl(struct sock *sk, int cm
 		ret = -EINVAL;
 	}
 
+  out_svc:
 	if (svc)
 		ip_vs_service_put(svc);
-
   out_unlock:
 	mutex_unlock(&__ip_vs_mutex);
   out_dec:

III.

Perhaps if you are calling ipvsadm a lot then there is a remote
possibility that write_lock_bh() could starve read_lock(). This
seems ludicrous, but I'm just mentioning it as it crossed my mind.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

