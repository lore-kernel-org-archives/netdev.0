From: Jun Chen <jun.d.chen@intel.com>
Subject: Re: [PATCH] tcp: Modify the condition for the first skb to collapse
Date: Tue, 18 Jun 2013 05:52:59 -0400
Message-ID: <1371549179.28418.28.camel@chenjun-workstation>
References: <1371478739.10495.5.camel@chenjun-workstation>
	 <1371456935.3252.177.camel@edumazet-glaptop>
	 <1371490190.28418.6.camel@chenjun-workstation>
	 <1371464962.3252.181.camel@edumazet-glaptop>
	 <1371495133.28418.19.camel@chenjun-workstation>
	 <1371475281.3252.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371475281.3252.198.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-17 at 06:21 -0700, Eric Dumazet wrote:
> On Mon, 2013-06-17 at 14:52 -0400, Jun Chen wrote:
> > On Mon, 2013-06-17 at 03:29 -0700, Eric Dumazet wrote:
> > > On Mon, 2013-06-17 at 13:29 -0400, Jun Chen wrote:
> > > > > 
> > > > hi,
> > > > When the condition of tcp_win_from_space(skb->truesize) > skb->len is
> > > > true but the before(start, TCP_SKB_CB(skb)->seq) is also true, the final
> > > > condition will be true. The follow line:
> > > > int offset = start - TCP_SKB_CB(skb)->seq;
> > > > BUG_ON(offset < 0);
> > > > this BUG_ON will be triggered.
> > > > 
> > > 
> > > Really this should never happen, we must track what's happening here.
> > It's very very rare, but the logic of codes have such a little hole.
> > > 
> > > Are you using a pristine kernel, without any patches ?
> > The based kernel version is 3.4.  
> > > 
> > > Are you able to reproduce this bug in a short amount of time ?
> > I can't reproduce it in short time, this log had just been found once
> > for long long time tests on many devices . 
> > > 
> > > What kind of driver is in use ? (your stack trace was truncated)
> > 
> > I attach the whole stack traces for you.
> > 

> Any other suspect messages before this, a memory allocation error for
> example ?
> 
> I believe we have a bug in tcp_collapse() if one alloc_skb() returns
> NULL while we were in the middle of collapsing a big GRO packet.
> 
> gro_skb needed 3 skb to be rebuilt, and only two skbs could be allocated
> 
> skb1: seq=X  end_seq=X+4000
> skb2: seq=X+4000 end_seq=X+8000
> <missing>
> grp_skb: seq=X end_seq=X+16000
> 
> Next time we call tcp_collapse(), we might split again the GRO packet
> and get following incorrect queue :
> 
> skb1: seq=X  end_seq=X+4000
> skb2: seq=X+4000 end_seq=X+8000
> skb3: seq=X  end_seq=X+4000
> skb4: seq=X+4000 end_seq=X+8000
> skb5: seq=X+8000 end_seq=X+12000
> skb6: seq=X+12000 end_seq=X+16000
> 
> 
> I would use the following patch instead, to narrow the problem
> 
> If we really find in the ofo queue a skb with a lower seq than the
> previous one, we should complain instead of lowering @start, since
> this is going to crash later.
> 
> receive_queue / ofo_queue should contain monotonically increasing
> skb->seq.
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 46271cdc..5507a09 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4513,8 +4513,10 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
>  			start = TCP_SKB_CB(skb)->seq;
>  			end = TCP_SKB_CB(skb)->end_seq;
>  		} else {
> -			if (before(TCP_SKB_CB(skb)->seq, start))
> -				start = TCP_SKB_CB(skb)->seq;
> +			if (before(TCP_SKB_CB(skb)->seq, start)) {
> +				pr_err_once("tcp_collapse_ofo_queue() : seq %08x before start %08X\n",
> +					    TCP_SKB_CB(skb)->seq, start);
> +			}
>  			if (after(TCP_SKB_CB(skb)->end_seq, end))
>  				end = TCP_SKB_CB(skb)->end_seq;
>  		}
> 
> 
There are many warning for tcp_recvmsg before this crash. I can't find
other memory warning in the logs, but I'm not sure whether there are
memory issues because of the length limitation of saved logs. I think
this logs will give you more information.

<4>[ 7736.343742] ------------[ cut here ]------------

<4>[ 7736.343759] WARNING:
at /data/buildbot/workdir/jb/kernel/net/ipv4/tcp.c:1496 tcp_recvmsg
+0x3bf/0x910()

<4>[ 7736.343775] recvmsg bug: copied AB57C870 seq AB57CD95 rcvnxt
AB57F19F fl 0

<4>[ 7736.343845] Call Trace:

<4>[ 7736.343865]  [<c1237032>] warn_slowpath_common+0x72/0xa0

<4>[ 7736.343888]  [<c18a955f>] ? tcp_recvmsg+0x3bf/0x910

<4>[ 7736.343902]  [<c18a955f>] ? tcp_recvmsg+0x3bf/0x910

<4>[ 7736.343922]  [<c1237103>] warn_slowpath_fmt+0x33/0x40

<4>[ 7736.343944]  [<c18a955f>] tcp_recvmsg+0x3bf/0x910

<4>[ 7736.343968]  [<c18c9bb5>] inet_recvmsg+0x85/0xa0

<4>[ 7736.343992]  [<c1852030>] sock_aio_read+0x140/0x160

<4>[ 7736.344016]  [<c126b221>] ? set_next_entity+0xc1/0xf0

<4>[ 7736.344039]  [<c130d627>] do_sync_read+0xb7/0xf0

<4>[ 7736.344064]  [<c130dc6c>] ? rw_verify_area+0x6c/0x120

<4>[ 7736.344077]  [<c1349aa8>] ? sys_epoll_wait+0x68/0x360

<4>[ 7736.344098]  [<c130e1e9>] vfs_read+0x149/0x160

<4>[ 7736.344120]  [<c130f518>] ? fget_light+0x58/0xd0

<4>[ 7736.344142]  [<c130e23d>] sys_read+0x3d/0x70

<4>[ 7736.344164]  [<c198c361>] syscall_call+0x7/0xb

<4>[ 7736.344187]  [<c1980000>] ? perf_cpu_notify+0x45/0x89

<4>[ 7736.344205] ---[ end trace b3c5b245ce7ff5b5 ]---
