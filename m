From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: way of figuring out total number of retransmitted packets on a TCP socket?
Date: Thu, 21 Oct 2004 00:35:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020223547.GJ29583@xi.wantstofly.org>
References: <20041020130134.GC24757@xi.wantstofly.org> <20041020151448.51209278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020151448.51209278.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 03:14:48PM -0700, David S. Miller wrote:

> > I'm looking for a way of counting the total number of retransmitted packets
> > sent on a TCP connection.  I tried querying TCP_INFO:tcpi_retransmits, but
> > that seems to be not the metric I'm looking for.
> > 
> > Anyone got any ideas?  (Apart from using tcpdump+tcptrace.)
> 
> tcpi_retransmits only accounts for timeout based retransmits.

Some places in the TCP stack reset tp->retransmits to zero, or to
one.  Is it supposed to reflect the current number of retransmitted
packets in the network?


> Retransmits which occur dynamically due to fast-retransmit
> and other non-timeout based decisions are accounted for
> in "tcpi_retrans", so that is probably the value you are
> looking for.

tcpi_retrans is taken from tp->retrans_out (looking at 2.6.8 here.)
But that value gets set to zero in a lot of places in the networking
as well, so it's probably not what I'm looking for either.

This is what TCP_INFO looks like after a sample run where 1GB is
pumped into the socket buffer, sleep(1) is done to let the dust settle
and then stats are dumped (2.6.8 SMP sender and 2.6.8 UP receiver,
gigabit ethernet over a cross cable):

tcpi_state              1, ESTABLISHED
tcpi_ca_state           0, CA_Open
tcpi_retransmits        0
tcpi_probes             0
tcpi_backoff            0
tcpi_options            7 [TIMESTAMPS SACK WSCALE ]
tcpi_snd_wscale         7
tcpi_rcv_wscale         7

tcpi_rto                208000
tcpi_ato                0
tcpi_snd_mss            1448
tcpi_rcv_mss            536

tcpi_unacked            0
tcpi_sacked             0
tcpi_lost               0
tcpi_retrans            0
tcpi_fackets            0

tcpi_last_data_sent     999
tcpi_last_ack_sent      0
tcpi_last_data_recv     3040239
tcpi_last_ack_recv      994

tcpi_pmtu               1500
tcpi_rcv_sstresh        5840
tcpi_rtt                8000
tcpi_rttvar             750
tcpi_snd_sstresh        64
tcpi_snd_cwnd           73
tcpi_advmss             1448
tcpi_reordering         3

But I'm sure that packets were retransmitted during this run, because
I had a DROP rule in there for a few seconds:

00:27:09.904020 IP 10.10.10.3.60983 > 10.10.10.4.9999: . 18905849:18907297(1448) ack 1 win 46 <nop,nop,timestamp 449613028 6553106>
00:27:10.327942 IP 10.10.10.3.60983 > 10.10.10.4.9999: . 18905849:18907297(1448) ack 1 win 46 <nop,nop,timestamp 449613452 6553106>
00:27:11.175790 IP 10.10.10.3.60983 > 10.10.10.4.9999: . 18905849:18907297(1448) ack 1 win 46 <nop,nop,timestamp 449614300 6553106>
00:27:12.871486 IP 10.10.10.3.60983 > 10.10.10.4.9999: . 18905849:18907297(1448) ack 1 win 46 <nop,nop,timestamp 449615996 6553106>
00:27:16.262863 IP 10.10.10.3.60983 > 10.10.10.4.9999: . 18905849:18907297(1448) ack 1 win 46 <nop,nop,timestamp 449619388 6553106>


cheers,
Lennert
