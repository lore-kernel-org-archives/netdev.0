From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: RFS configuration questions
Date: Fri, 3 Dec 2010 10:00:36 -0600
Message-ID: <20101203160035.GA2698@BohrerMBP.rgmadvisors.com>
References: <20101202211602.GA2775@BohrerMBP.rgmadvisors.com>
 <1291326041.2854.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:46491 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751408Ab0LCQAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 11:00:44 -0500
Received: by mail-vw0-f44.google.com with SMTP id 7so3931568vws.17
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 08:00:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1291326041.2854.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 02, 2010 at 10:40:41PM +0100, Eric Dumazet wrote:
> Le jeudi 02 d=E9cembre 2010 =E0 15:16 -0600, Shawn Bohrer a =E9crit :
> > I've been playing around with RPS/RFS on my multiqueue 10g Chelsio =
NIC
> > and I've got some questions about configuring RFS.
> >=20
> > I've enabled RPS with:
> >=20
> > for x in $(seq 0 7); do
> >     echo FFFFFFFF,FFFFFFFF > /sys/class/net/vlan816/queues/rx-${x}/=
rps_cpus
> > done
> >=20
> > This appears to work when I watch 'mpstat -P ALL 1' as I can see th=
e
> > softirq load is now getting distributed across all of the CPUs inst=
ead
> > of just the four (the card is a two port card and assigns four queu=
es
> > per port) original hw receive queues which I have bound to CPUs
> > 0-3.
> >=20
> > To enable RFS I've run:
> >=20
> > echo 16384 > /proc/sys/net/core/rps_sock_flow_entries
> >=20
> > Is there any explanation of what this sysctl actually does?  Is thi=
s
> > the max number of sockets/flows that the kernel can steer?  Is this=
 a
> > system wide max, a per interface max, or a per receive queue max?
> >=20
>=20
> Yes, some doc is missing...
>=20
> Its a system wide and shared limit.

So the sum of /sys/class/net/*/queues/rx-*/rps_flow_cnt should be less
than or equal to rps_sock_flow_entries?

> > Next I ran:
> >=20
> > for x in $(seq 0 7); do
> >     echo 16384 > /sys/class/net/vlan816/queues/rx-${x}/rps_flow_cnt
> > done
> >=20
> > Is this correct?  Is these the max number of sockets/flows that can=
 be
> > steered per receive queue?  Does the sum of these values need to ad=
d
> > up to rps_sock_flow_entries (I also tried 2048)? Is this all that i=
s
> > needed to enable RFS?
> >=20
>=20
> Yes thats all.

Same as above... I should be using 2048 if I have 8 queues and have
set rps_sock_flow_entries to 16384?  Out of curiosity what happens
when you open more sockets than you have rps_flow_cnt?

> > With these settings I can watch 'mpstat -P ALL 1' and it doesn't
> > appear RFS has changed the softirq load.  To get a better idea if i=
t
> > was working I used taskset to bind my receiving processes to a set =
of
> > cores, yet mpstat still shows the softirq load getting distributed
> > across all cores, not just the ones where my receiving processes ar=
e
> > bound.  Is there a better way to determine if RFS is actually worki=
ng?
> > Have I configured RFS incorrectly?
>=20
> It seems fine to me, but what kind of workload do you have, and what
> version of kernel do you run ?

I just did some more testing on 2.6.36.1.  Using netperf UDP_STREAM
and TCP_STREAM I was able to see that the softirq load would run on
the CPU where netperf was bound so it appears that RFS is working.

However if I run one of my applications which is a single process
listening to ~30 multicast addresses the softirq load does not run on
the CPU where the application is bound.  Does RFS not support
receiving multicast?

--
Shawn
