From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Thu, 12 Jul 2007 15:45:42 +0900 (JST)
Message-ID: <20070712.154542.01364133.noboru.obata.ar@hitachi.com>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
    <20070625090748.72d59a9f@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:34361 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbXGLGqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 02:46:20 -0400
Received: from mlsv18.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 417E237ACA
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 15:46:19 +0900 (JST)
In-Reply-To: <20070625090748.72d59a9f@freepuppy.localdomain.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Stephen.

Thank you for your comments.  I will fix them and re-send the
patch for 2.6.22.

From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 09:07:48 -0700

> > diff -uprN -X a/Documentation/dontdiff linux-2.6.22-rc5-orig/include/linux/sysctl.h b/include/linux/sysctl.h
> > --- a/include/linux/sysctl.h	2007-06-22 21:34:33.000000000 +0900
> > +++ b/include/linux/sysctl.h	2007-06-25 16:27:29.000000000 +0900
> > @@ -441,6 +441,7 @@ enum
> >  	NET_TCP_ALLOWED_CONG_CONTROL=123,
> >  	NET_TCP_MAX_SSTHRESH=124,
> >  	NET_TCP_FRTO_RESPONSE=125,
> > +	NET_TCP_RTO_MAX=126,
> >  };
> >  
> 
> Rather than assigning another numeric sysctl value, you can use
> CTL_UNNUMBERED.  The use of numeric sysctl's is being phased down, at one
> point they were even going to be deprecated.

Understood.


> > diff -uprN -X a/Documentation/dontdiff linux-2.6.22-rc5-orig/include/net/tcp.h b/include/net/tcp.h
> > --- a/include/net/tcp.h	2007-06-22 21:34:33.000000000 +0900
> > +++ b/include/net/tcp.h	2007-06-22 21:40:05.000000000 +0900
> > @@ -121,7 +121,9 @@ extern void tcp_time_wait(struct sock *s
> >  #define TCP_DELACK_MIN	4U
> >  #define TCP_ATO_MIN	4U
> >  #endif
> > -#define TCP_RTO_MAX	((unsigned)(120*HZ))
> > +extern int sysctl_tcp_rto_max;
> > +#define TCP_RTO_MAX	((unsigned)(sysctl_tcp_rto_max))
> > +#define TCP_RTO_MAX_DEFAULT	((unsigned)(120*HZ))
> >  #define TCP_RTO_MIN	((unsigned)(HZ/5))
> >  #define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/
> 
> Rather than causing macro TCP_RTO_MAX to reference sysctl_rto_max directly.

Okay.  I will replace all occurrence of TCP_RTO_MAX to
sysctl_tcp_rto_max.


> > @@ -203,6 +205,7 @@ extern int sysctl_tcp_synack_retries;
> >  extern int sysctl_tcp_retries1;
> >  extern int sysctl_tcp_retries2;
> >  extern int sysctl_tcp_orphan_retries;
> > +extern int sysctl_tcp_rto_max;
> >  extern int sysctl_tcp_syncookies;
> >  extern int sysctl_tcp_retrans_collapse;
> >  extern int sysctl_tcp_stdurg;

> Could sysctl_rto_max be unsigned instead of int to avoid possible sign wrap issues and
> having to cast it on each use?

Yes.  As sysctl_tcp_rto_max is going to replace TCP_RTO_MAX,
which is unsigned, making sysctl_tcp_rto_max unsigned seems
reasonable.


> >  ctl_table ipv4_table[] = {
> >  	{
> >  		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
> > @@ -363,6 +431,15 @@ ctl_table ipv4_table[] = {
> >  		.proc_handler	= &proc_dointvec
> >  	},
> >  	{
> > +		.ctl_name	= NET_TCP_RTO_MAX,
> > +		.procname	= "tcp_rto_max",
> > +		.data		= &sysctl_tcp_rto_max,
> > +		.maxlen		= sizeof(int),
> > +		.mode		= 0644,
> > +		.proc_handler	= &proc_tcp_rto_max,
> > +		.strategy	= &strategy_tcp_rto_max
> > +	},
> > +	{

I will remove .strategy and strategy_tcp_rto_max from my patch
because I'm not going to support the numeric sysctl.

Regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
