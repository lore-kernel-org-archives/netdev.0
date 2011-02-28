From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 15:53:03 +0100
Message-ID: <1298904783.2941.412.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <1298899971.2941.281.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33593 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320Ab1B1OzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 09:55:15 -0500
Received: by fxm17 with SMTP id 17so3799453fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 06:55:13 -0800 (PST)
In-Reply-To: <1298899971.2941.281.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 14:32 +0100, Eric Dumazet a =C3=A9=
crit :
> Le lundi 28 f=C3=A9vrier 2011 =C3=A0 19:36 +0800, Herbert Xu a =C3=A9=
crit :
> > On Sun, Feb 27, 2011 at 07:06:14PM +0800, Herbert Xu wrote:
> > > I'm working on this right now.
> >=20
> > OK I think I was definitely on the right track.  With the send
> > patch made lockless I now get numbers which are even better than
> > those obtained with running named with multiple sockets.  That's
> > right, a single socket is now faster than what multiple sockets
> > were without the patch (of course, multiple sockets may still
> > faster with the patch vs. a single socket for obvious reasons,
> > but I couldn't measure any significant difference).
> >=20
> > Also worthy of note is that prior to the patch all CPUs showed
> > idleness (lazy bastards!), with the patch they're all maxed out.
> >=20
> > In retrospect, the idleness was simply the result of the socket
> > lock scheduling away and was an indication of lock contention.
> >=20
>=20
> Now, input path can run without finding socket locked by xmit path, s=
o
> skb are queued into receive queue, not backlog one.
>=20
> > Here are the patches I used.  Please don't them yet as I intend
> > to clean them up quite a bit.
> >=20
> > But please do test them heavily, especially if you have an AMD
> > NUMA machine as that's where scalability problems really show
> > up.  Intel tends to be a lot more forgiving.  My last AMD machine
> > blew up years ago :)
>=20
> I am going to test them, thanks !
>=20

=46irst "sending only" tests on my 2x4x2 machine (two E5540@2.53GHz, qu=
ad
core, hyper threaded, NUMA kernel)

16 threads, each one sending 100.000 UDP frames using a _shared_ socket

I use the same destination IP, so suffer a bit of dst refcount
contention.

(to dummy0 device to avoid contention on qdisc and device)
# ip ro get 10.2.2.21
10.2.2.21 dev dummy0  src 10.2.2.2=20
    cache=20

LOCKDEP enabled kernel

Before :

time ./udpflood -f -t 16 -l 100000 10.2.2.21

real	0m42.749s
user	0m1.010s
sys	1m38.039s

After :

time ./udpflood -f -t 16 -l 100000 10.2.2.21

real	0m1.167s
user	0m0.488s
sys	0m17.373s


With one thread only and 16*100000 frames :
# time ./udpflood -f -l 1600000 10.2.2.21

real	0m9.318s
user	0m0.238s
sys	0m9.052s

(We have some false sharing on atomic fields in struct file and socket,
but nothing to worry about.)

With LOCKDEP OFF :

16 threads :

# time ./udpflood -f -t 16 -l 100000 10.2.2.21

real	0m0.718s
user	0m0.376s
sys	0m10.963s

1 thread :

# time ./udpflood -f -l 1600000 10.2.2.21

real	0m1.514s
user	0m0.153s
sys	0m1.357s


"perf record/report" results for the 16 threads case (no lockdep)

# Events: 389K cpu-clock-msecs
#
# Overhead      Command        Shared Object                           =
    Symbol
# ........  ...........  ...................  .........................=
=2E.........
#
     9.03%     udpflood  [kernel.kallsyms]    [k] sock_wfree
     8.58%     udpflood  [kernel.kallsyms]    [k] __ip_route_output_key
     8.52%     udpflood  [kernel.kallsyms]    [k] sock_alloc_send_pskb
     7.46%     udpflood  [kernel.kallsyms]    [k] sock_def_write_space
     6.76%     udpflood  [kernel.kallsyms]    [k] __xfrm_lookup
     6.18%      swapper  [kernel.kallsyms]    [k] acpi_idle_enter_bm
     5.66%     udpflood  [kernel.kallsyms]    [k] dst_release
     4.96%     udpflood  [kernel.kallsyms]    [k] udp_sendmsg
     3.48%     udpflood  [kernel.kallsyms]    [k] fget_light
     2.75%     udpflood  [kernel.kallsyms]    [k] sock_tx_timestamp
     2.40%     udpflood  [kernel.kallsyms]    [k] __ip_make_skb
     2.36%     udpflood  [kernel.kallsyms]    [k] fput
     1.87%      swapper  [kernel.kallsyms]    [k] _raw_spin_unlock_irqr=
estore
     1.81%     udpflood  [kernel.kallsyms]    [k] inet_sendmsg
     1.53%     udpflood  [kernel.kallsyms]    [k] sys_sendto
     1.50%     udpflood  [kernel.kallsyms]    [k] ip_finish_output
     1.31%     udpflood  [kernel.kallsyms]    [k] csum_partial_copy_gen=
eric
     1.30%     udpflood  udpflood             [.] do_thread
     1.28%     udpflood  [kernel.kallsyms]    [k] __ip_append_data
     1.08%     udpflood  [kernel.kallsyms]    [k] __memset
     1.05%     udpflood  [kernel.kallsyms]    [k] ip_route_output_flow
     0.91%     udpflood  [kernel.kallsyms]    [k] kfree
     0.88%     udpflood  [vdso]               [.] 0xffffe430
     0.83%     udpflood  [kernel.kallsyms]    [k] copy_user_generic_str=
ing
     0.78%     udpflood  libc-2.3.4.so        [.] __GI_memcpy
     0.77%     udpflood  [kernel.kallsyms]    [k] ia32_sysenter_target


What do you suggest to perform a bind based test ?



