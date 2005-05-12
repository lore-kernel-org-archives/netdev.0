From: Jim Minter <jim@ferrypath.org.uk>
Subject: More 'Badness in dst_release' messages
Date: Thu, 12 May 2005 17:11:26 +0100 (BST)
Message-ID: <Pine.LNX.4.58.0505121604220.1674@ferrypath.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I'm getting 'Badness in dst_release' messages and associated occasional
panics (dereferencing invalidated dst pointers), and am having some
problems tracking down the cause.  Could anyone spare a moment to advise
me what I can do next to debug and resolve the issue?

I'm running vanilla kernel-2.6.11, x86_64 SMP, on a single-CPU (but
hyperthreaded) EM64T Xeon.  I'm using IPv4, and that's where all the
problems seem to be.  IPv6 isn't compiled in; XFRM and bridging are, but
I'm not using either.  I've had similar problems with an equivalent 2.6.10
setup.

These are all the types of backtraces that I'm getting (bear in mind that
because it's x86_64, there's no CONFIG_FRAME_POINTER, so the backtraces
are noisy).  I have verified by hand that the top address in each
corresponds to a dst_release call in the code, though.

Call Trace:<ffffffff803370fc>{tcp_v4_connect+1932}
<ffffffff802fe408>{lock_sock+200}
<ffffffff803464b2>{inet_stream_connect+226}
<ffffffff802395e8>{sprintf+136}
<ffffffff802fe408>{lock_sock+200}
<ffffffff80179a1b>{fget+91}
<ffffffff802fc92a>{sys_connect+122}
<ffffffff802fb380>{sockfd_lookup+32}
<ffffffff802fcef4>{sys_getsockopt+132}
<ffffffff8010e4ca>{system_call+126}

[corresponds to the __sk_dst_set(sk, &rt->u.dst); in tcp_v4_connect():
this seems to be curious to me]


Call Trace:<ffffffff80345cbb>{inet_sock_destruct+555}
<ffffffff802fd93e>{sk_free+30}
<ffffffff803460d8>{inet_release+88}
<ffffffff802fb4a1>{sock_release+33}
<ffffffff802fc175>{sock_close+53}
<ffffffff801798c2>{__fput+98}
<ffffffff801781ee>{filp_close+126}
<ffffffff801782a3>{sys_close+147}
<ffffffff8010e4ca>{system_call+126}


Call Trace:<IRQ> <ffffffff802ffc76>{__kfree_skb+102}
<ffffffff88028675>{:e1000:e1000_clean+389}
<ffffffff80331e13>{tcp_transmit_skb+1651}
<ffffffff802fea2f>{sk_reset_timer+15}
<ffffffff80305e94>{net_rx_action+132}
<ffffffff8013af51>{__do_softirq+113}
<ffffffff8013b005>{do_softirq+53}
<ffffffff801113c7>{do_IRQ+71}
<ffffffff8010ea71>{ret_from_intr+0} <EOI>
<ffffffff8010c8c6>{mwait_idle+86}
<ffffffff8010c84f>{cpu_idle+63}


Any suggestions would be much appreciated as I haven't been able yet to
replicate the bug elsewhere.  Although I don't have physical access to the
machine in question, I am able to arrange for debugging kernels to be put
on it, if I know what to look for!

Many thanks,

Jim Minter <jim@ferrypath.org.uk>
