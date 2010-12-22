From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Wed, 22 Dec 2010 12:38:42 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012221231450.16569@pobox.suse.cz>
References: <alpine.LNX.2.00.1012172310400.16569@pobox.suse.cz>  <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz> <1293017383.3027.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293017383.3027.75.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Dec 2010, Eric Dumazet wrote:

> > > For outgoing connections, the initial value of cwnd is always set to 2 (in 
> > > tcp_v4_init_sock()) regardless of setting of RTAX_CWND. For incoming 
> > > connections, this is handled properly in tcp_init_metrics().
> > > 
> > > As a result of this, Linux TCP stack always uses cwnd == 2 at the beginning of
> > > outgoing TCP session (i.e. waits for ACK after 2 packets once the connection
> > > has been established) and grows it in accordance with slow-start algorithm
> > > only after it receives ACK for first two packets.
> > > 
> > > When slow-start triggers later during the connection (e.g. after idle), 
> > > cwnd is properly re-initialized to RTAX_CWND value (if specified) through 
> > > tcp_cwnd_restart() -> tcp_init_cwnd().
> > > 
> > > Initialize tp->snd_cwnd properly so that RTAX_CWND value is being used 
> > > also in the slow-start phase for the first packets in the connection.
> > 
> > This should of course read RTAX_INITCWND instead of RTAX_CWND in the whole 
> > changelog, sorry.
> > 
> > Besides that, any comments on this, please?
> > 
> 
> Its a bit strange, here is what I have with two net-next-2.6 machines
> (without your patch)
> 
> 192.168.20.0/24 dev eth1  scope link  initcwnd 10
> 
> 12:13:46.855786 IP 192.168.20.110.39146 > 192.168.20.108.59636: S 1615862982:1615862982(0) win 14600 <mss 1460,sackOK,timestamp 277530 0,nop,wscale 8>
> 12:13:46.855807 IP 192.168.20.108.59636 > 192.168.20.110.39146: S 1603053412:1603053412(0) ack 1615862983 win 14480 <mss 1460,sackOK,timestamp 744840 277530,nop,wscale 7>
> 12:13:46.855878 IP 192.168.20.110.39146 > 192.168.20.108.59636: . ack 1 win 58 <nop,nop,timestamp 277530 744840>
> 12:13:46.856779 IP 192.168.20.110.39146 > 192.168.20.108.59636: P 1:14481(14480) ack 1 win 58 <nop,nop,timestamp 277530 744840>
> 12:13:46.856794 IP 192.168.20.108.59636 > 192.168.20.110.39146: . ack 14481 win 136 <nop,nop,timestamp 744841 277530>
> 12:13:46.856901 IP 192.168.20.110.39146 > 192.168.20.108.59636: . 14481:15929(1448) ack 1 win 58 <nop,nop,timestamp 277531 744841>
> 12:13:46.856912 IP 192.168.20.108.59636 > 192.168.20.110.39146: . ack 15929 win 159 <nop,nop,timestamp 744841 277531>
> 12:13:46.856930 IP 192.168.20.110.39146 > 192.168.20.108.59636: . 15929:18825(2896) ack 1 win 58 <nop,nop,timestamp 277531 744841>
>
> We can see 192.168.20.110 sends 14480 bytes in its first frame.

So is this with 356f039822b8d802138f applied?

I have had a testing environment in which I had forced the 'receiver' to 
advertise large receive window, but still the sender started with a very 
small initial congestion window, waiting for ack after 1 or 2 MSS-sized 
packets.

I must admit that I was reproducing it with slightly older kernel, but 
haven't seen any changes in the code which would influence this behavior. 
Will look how most up-to-date kernel (plus 356f039822b8d802138f) behaves 
in that environment.

Where in the code is the congestion window enlarged to accomodate 14480 
bytes in your case? I don't see where the value of '2' coming from 
tcp_v4_init_sock() is being overriden for "outgoing" connections ...

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
