From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [RFC PATCH net-next 3/5] tcp: Add a few more tracepoints for tcp
 tracer
Date: Wed, 17 Dec 2014 14:02:34 -0300
Message-ID: <20141217170234.GA3150@kernel.org>
References: <1418608606-1569264-1-git-send-email-kafai@fb.com>
 <1418608606-1569264-4-git-send-email-kafai@fb.com>
 <20141217153349.GG11607@kernel.org>
 <5491A86C.5030207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:43752 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbaLQRCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 12:02:47 -0500
Content-Disposition: inline
In-Reply-To: <5491A86C.5030207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 17, 2014 at 08:59:40AM -0700, David Ahern escreveu:
> On 12/17/14 8:33 AM, Arnaldo Carvalho de Melo wrote:

> >On a random RHEL7 kernel I had laying around on a test machine:

> >[root@ssdandy ~]# perf probe -L tcp_sacktag_write_queue | head -20
> ><tcp_sacktag_write_queue@/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp_input.c:0>
> >       0  tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
> >          			u32 prior_snd_una)
> >       2  {
> >          	struct tcp_sock *tp = tcp_sk(sk);
> >       4  	const unsigned char *ptr = (skb_transport_header(ack_skb) +
> >          				    TCP_SKB_CB(ack_skb)->sacked);
> >          	struct tcp_sack_block_wire *sp_wire = (struct tcp_sack_block_wire *)(ptr+2);
> >          	struct tcp_sack_block sp[TCP_NUM_SACKS];
> >          	struct tcp_sack_block *cache;
> >          	struct tcp_sacktag_state state;
> >          	struct sk_buff *skb;
> >      11  	int num_sacks = min(TCP_NUM_SACKS, (ptr[1] - TCPOLEN_SACK_BASE) >> 3);
> >          	int used_sacks;
> >          	bool found_dup_sack = false;
> >          	int i, j;
> >          	int first_sack_index;
> >
> >      17  	state.flag = 0;
> >      18  	state.reord = tp->packets_out;
 
> But there are limitations/hassles with this approach. For starters I believe
> it requires vmlinux on box. The products I work on do not have vmlinux
> available in the runtime environment. I recall someone (Masami?) suggesting

Not necessarily, one can do all this on a development machine that has
that info and then end up with kprobe_trace expressions as described on:

Documentation/trace/kprobetrace.txt

> the ability to write the probe data to a file (ie., create the probe
> definition off box) and load the file to create the probe, so yes a solvable
> problem.

Exactly.
 
> But with this approach it could very be that the function name and variable
> names differ with kernel version and that makes it hard to impossible to
> create a set of analysis commands.

Well, if this is in a very much in flux code, then, there is no place
for a tracepoint there :-)

For instance: I've been using this definition:

commit c522739d72a341a3e74a369ce6298b9412813d3f
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Fri Sep 27 18:06:19 2013 -0300

    perf trace: Use vfs_getname hook if available
    
    Initially it tries to find a probe:vfs_getname that should be setup
    with:
    
     perf probe 'vfs_getname=getname_flags:65 pathname=result->name:string'

-----------------

For quite a while in tools/perf/builtin-trace.c

I.e. if this thing is in place, then I get mappings from a pointer to a
pathname that I use in a tool, 'perf trace', if not, it tries reading
/proc/, etc, which is suboptimal but then the only way to map a fd to a
pathname.

On RHEL7:

[root@ssdandy ~]# perf probe 'vfs_getname=getname_flags:65 pathname=result->name:string'
Added new event:
  probe:vfs_getname    (on getname_flags:65 with pathname=result->name:string)

You can now use it in all perf tools, such as:

	perf record -e probe:vfs_getname -aR sleep 1

[root@ssdandy ~]#
[root@ssdandy ~]# perf record -e probe:vfs_getname cat /etc/passwd > /dev/null
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.019 MB perf.data (~812 samples) ]
[root@ssdandy ~]# perf script
 cat 24805 [005] 188716.046396: probe:vfs_getname: (ffffffff811bb7e3) pathname="/etc/ld.so.preload"
 cat 24805 [005] 188716.046408: probe:vfs_getname: (ffffffff811bb7e3) pathname="/etc/ld.so.cache"
 cat 24805 [005] 188716.046428: probe:vfs_getname: (ffffffff811bb7e3) pathname="/lib64/libc.so.6"
 cat 24805 [005] 188716.046675: probe:vfs_getname: (ffffffff811bb7e3) pathname="/usr/lib/locale/locale-archive"
 cat 24805 [005] 188716.046718: probe:vfs_getname: (ffffffff811bb7e3) pathname="/etc/passwd"
[root@ssdandy ~]# uname -r
3.10.0-123.el7.x86_64

And in fedora there was a change in how we must set up the probe:

[root@zoo ~]# perf probe 'vfs_getname=getname_flags:65 pathname=filename:string'
Added new event:
  probe:vfs_getname    (on getname_flags:65 with pathname=filename:string)

You can now use it in all perf tools, such as:

	perf record -e probe:vfs_getname -aR sleep 1

[root@zoo ~]# perf record -e probe:vfs_getname cat /etc/passwd > /dev/null
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.016 MB perf.data (~687 samples) ]
[root@zoo ~]# perf script
 cat 27485 [000] 931.973139: probe:vfs_getname: (ffffffff8120ad13) pathname="/etc/ld.so.preload"
 cat 27485 [000] 931.973148: probe:vfs_getname: (ffffffff8120ad13) pathname="/etc/ld.so.cache"
 cat 27485 [000] 931.973169: probe:vfs_getname: (ffffffff8120ad13) pathname="/lib64/libc.so.6"
 cat 27485 [000] 931.973417: probe:vfs_getname: (ffffffff8120ad13) pathname="/usr/lib/locale/locale-archive"
 cat 27485 [000] 931.973488: probe:vfs_getname: (ffffffff8120ad13) pathname="/etc/passwd"
[root@zoo ~]# uname -r
3.17.4-200.fc20.x86_64
[root@zoo ~]#

What I could find in 'result->name'  changed to 'filename', but since I gave it
a standard name ("pathname"), its just when setting up the probes, something we
do at system start, i.e. just once, before the first 'perf record', we can deal
with that with some scripting that will do probe setup fallbacks.

All this while we're prototyping a tool, when we're 100% sure that a tracepoint
would provide any performance gains and that that area is so set in stone that
we can guarantee an ABI, go ahead and add the tracepoint.

- Arnaldo
