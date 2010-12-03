From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFS configuration questions
Date: Fri, 03 Dec 2010 17:34:15 +0100
Message-ID: <1291394055.2897.483.camel@edumazet-laptop>
References: <20101202211602.GA2775@BohrerMBP.rgmadvisors.com>
	 <1291326041.2854.2.camel@edumazet-laptop>
	 <20101203160035.GA2698@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38066 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab0LCQeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 11:34:20 -0500
Received: by eye27 with SMTP id 27so5118897eye.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 08:34:18 -0800 (PST)
In-Reply-To: <20101203160035.GA2698@BohrerMBP.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 10:00 -0600, Shawn Bohrer a =C3=
=A9crit :
> On Thu, Dec 02, 2010 at 10:40:41PM +0100, Eric Dumazet wrote:
> > Le jeudi 02 d=C3=A9cembre 2010 =C3=A0 15:16 -0600, Shawn Bohrer a =C3=
=A9crit :
> > > I've been playing around with RPS/RFS on my multiqueue 10g Chelsi=
o NIC
> > > and I've got some questions about configuring RFS.
> > >=20
> > > I've enabled RPS with:
> > >=20
> > > for x in $(seq 0 7); do
> > >     echo FFFFFFFF,FFFFFFFF > /sys/class/net/vlan816/queues/rx-${x=
}/rps_cpus
> > > done
> > >=20
> > > This appears to work when I watch 'mpstat -P ALL 1' as I can see =
the
> > > softirq load is now getting distributed across all of the CPUs in=
stead
> > > of just the four (the card is a two port card and assigns four qu=
eues
> > > per port) original hw receive queues which I have bound to CPUs
> > > 0-3.
> > >=20
> > > To enable RFS I've run:
> > >=20
> > > echo 16384 > /proc/sys/net/core/rps_sock_flow_entries
> > >=20
> > > Is there any explanation of what this sysctl actually does?  Is t=
his
> > > the max number of sockets/flows that the kernel can steer?  Is th=
is a
> > > system wide max, a per interface max, or a per receive queue max?
> > >=20
> >=20
> > Yes, some doc is missing...
> >=20
> > Its a system wide and shared limit.
>=20
> So the sum of /sys/class/net/*/queues/rx-*/rps_flow_cnt should be les=
s
> than or equal to rps_sock_flow_entries?
>=20

I always used same count, but you probably can use lower values
for /sys/class/net/*/queues/rx-*/rps_flow_cnt if you dont have much
memory.

> > > Next I ran:
> > >=20
> > > for x in $(seq 0 7); do
> > >     echo 16384 > /sys/class/net/vlan816/queues/rx-${x}/rps_flow_c=
nt
> > > done
> > >=20
> > > Is this correct?  Is these the max number of sockets/flows that c=
an be
> > > steered per receive queue?  Does the sum of these values need to =
add
> > > up to rps_sock_flow_entries (I also tried 2048)? Is this all that=
 is
> > > needed to enable RFS?
> > >=20
> >=20
> > Yes thats all.
>=20
> Same as above... I should be using 2048 if I have 8 queues and have
> set rps_sock_flow_entries to 16384?  Out of curiosity what happens
> when you open more sockets than you have rps_flow_cnt?

Its a hash table, so collisions can happen. Nothing bad happens.

>=20
> > > With these settings I can watch 'mpstat -P ALL 1' and it doesn't
> > > appear RFS has changed the softirq load.  To get a better idea if=
 it
> > > was working I used taskset to bind my receiving processes to a se=
t of
> > > cores, yet mpstat still shows the softirq load getting distribute=
d
> > > across all cores, not just the ones where my receiving processes =
are
> > > bound.  Is there a better way to determine if RFS is actually wor=
king?
> > > Have I configured RFS incorrectly?
> >=20
> > It seems fine to me, but what kind of workload do you have, and wha=
t
> > version of kernel do you run ?
>=20
> I just did some more testing on 2.6.36.1.  Using netperf UDP_STREAM
> and TCP_STREAM I was able to see that the softirq load would run on
> the CPU where netperf was bound so it appears that RFS is working.

Be careful about softirq times, they most of the time are wrong.
You can do "cat /proc/net/softnet_stat" and check last column to see if
packets are really distributed to "other cpus"

>=20
> However if I run one of my applications which is a single process
> listening to ~30 multicast addresses the softirq load does not run on
> the CPU where the application is bound.  Does RFS not support
> receiving multicast?

No because :

net/ipv4/udp.c

static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
{
	int rc;

	if (inet_sk(sk)->inet_daddr)
		sock_rps_save_rxhash(sk, skb->rxhash);


Rationale is : RFS is implemented for _connected_ sockets only (TCP or
connected UDP)

(You can check commit changelog :=20

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commit;h=3Dfec5e652e58fa6017b2c9e06466cb2a6538de5b4


This is because rxhash value is different for each src address.
If we allowed your process to call sock_rps_save_rxhash(sk,
skb->rxhash); with many different rxhash, it would blow the hash table.

You might try to remove the  "if (inet_sk(sk)->inet_daddr)" test for
your benches, or add a new logic (socket flag maybe ?) to really trigge=
r
RFS on your UDP sockets.





