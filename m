From: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Fri, 12 Jun 2015 10:57:24 -0400
Message-ID: <CAHQdGtROSzCUWaFobiEPPb2TZwduoARaHQ7viQC=XhjzyXGtrQ@mail.gmail.com>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux Network Devel Mailing List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 12, 2015 at 10:40 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Fri, 2015-06-12 at 10:10 -0400, Trond Myklebust wrote:
>> On Thu, Jun 11, 2015 at 11:49 PM, Steven Rostedt <rostedt@goodmis.or=
g> wrote:
>> >
>> > I recently upgraded my main server to 4.0.4 from 3.19.5 and rkhunt=
er
>> > started reporting a hidden port on my box.
>> >
>> > Running unhide-tcp I see this:
>> >
>> > # unhide-tcp
>> > Unhide-tcp 20121229
>> > Copyright =C2=A9 2012 Yago Jesus & Patrick Gouin
>> > License GPLv3+ : GNU GPL version 3 or later
>> > http://www.unhide-forensics.info
>> > Used options:
>> > [*]Starting TCP checking
>> >
>> > Found Hidden port that not appears in ss: 946
>> > [*]Starting UDP checking
>> >
>> > This scared the hell out of me as I'm thinking that I have got som=
e kind
>> > of NSA backdoor hooked into my server and it is monitoring my plan=
s to
>> > smuggle Kinder =C3=9Cberraschung into the USA from Germany. I pani=
cked!
>> >
>> > Well, I wasted the day writing modules to first look at all the so=
ckets
>> > opened by all processes (via their file descriptors) and posted th=
eir
>> > port numbers.
>> >
>> >   http://rostedt.homelinux.com/private/tasklist.c
>> >
>> > But this port wasn't there either.
>> >
>> > Then I decided to look at the ports in tcp_hashinfo.
>> >
>> >   http://rostedt.homelinux.com/private/portlist.c
>> >
>> > This found the port but no file was connected to it, and worse yet=
,
>> > when I first ran it without using probe_kernel_read(), it crashed =
my
>> > kernel, because sk->sk_socket pointed to a freed socket!
>> >
>> > Note, each boot, the hidden port is different.
>> >
>> > Finally, I decided to bring in the big guns, and inserted a
>> > trace_printk() into the bind logic, to see if I could find the cul=
prit.
>> > After fiddling with it a few times, I found a suspect:
>> >
>> >    kworker/3:1H-123   [003] ..s.    96.696213: inet_bind_hash: add=
 946
>> >
>> > Bah, it's a kernel thread doing it, via a work queue. I then added=
 a
>> > trace_dump_stack() to find what was calling this, and here it is:
>> >
>> >     kworker/3:1H-123   [003] ..s.    96.696222: <stack trace>
>> >  =3D> inet_csk_get_port
>> >  =3D> inet_addr_type
>> >  =3D> inet_bind
>> >  =3D> xs_bind
>> >  =3D> sock_setsockopt
>> >  =3D> __sock_create
>> >  =3D> xs_create_sock.isra.18
>> >  =3D> xs_tcp_setup_socket
>> >  =3D> process_one_work
>> >  =3D> worker_thread
>> >  =3D> worker_thread
>> >  =3D> kthread
>> >  =3D> kthread
>> >  =3D> ret_from_fork
>> >  =3D> kthread
>> >
>> > I rebooted, and examined what happens. I see the kworker binding t=
hat
>> > port, and all seems well:
>> >
>> > # netstat -tapn |grep 946
>> > tcp        0      0 192.168.23.9:946        192.168.23.22:55201   =
  ESTABLISHED -
>> >
>> > But waiting for a bit, the connection goes into a TIME_WAIT, and t=
hen
>> > it just disappears. But the bind to the port does not get released=
, and
>> > that port is from then on, taken.
>> >
>> > This never happened with my 3.19 kernels. I would bisect it but th=
is is
>> > happening on my main server box which I usually only reboot every =
other
>> > month doing upgrades. It causes too much disturbance for myself (a=
nd my
>> > family) as when this box is offline, basically the rest of my mach=
ines
>> > are too.
>> >
>> > I figured this may be enough information to see if you can fix it.
>> > Otherwise I can try to do the bisect, but that's not going to happ=
en
>> > any time soon. I may just go back to 3.19 for now, such that rkhun=
ter
>> > stops complaining about the hidden port.
>> >
>>
>> The only new thing that we're doing with 4.0 is to set SO_REUSEPORT =
on
>> the socket before binding the port (commit 4dda9c8a5e34: "SUNRPC: Se=
t
>> SO_REUSEPORT socket option for TCP connections"). Perhaps there is a=
n
>> issue with that?
>
> Strange, because the usual way to not have time-wait is to use SO_LIN=
GER
> with linger=3D0
>
> And apparently xs_tcp_finish_connecting() has this :
>
>                 sock_reset_flag(sk, SOCK_LINGER);
>                 tcp_sk(sk)->linger2 =3D 0;

Are you sure? I thought that SO_LINGER is more about controlling how
the socket behaves w.r.t. waiting for the TCP_CLOSE state to be
achieved (i.e. about aborting the FIN state negotiation early). I've
never observed an effect on the TCP time-wait states.

> Are you sure SO_REUSEADDR was not the thing you wanted ?

Yes. SO_REUSEADDR has the problem that it requires you bind to
something other than 0.0.0.0, so it is less appropriate for outgoing
connections; the RPC code really should not have to worry about
routing and routability of a particular source address.

Cheers
  Trond
