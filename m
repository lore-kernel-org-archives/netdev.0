From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 14:54:27 -0800
Message-ID: <420D37A3.6020209@hp.com>
References: <0525M9211@server5.heliogroup.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
        romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Hubert Tonneau <hubert.tonneau@fullpliant.org>
In-Reply-To: <0525M9211@server5.heliogroup.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hubert Tonneau wrote:
> Sorry, it still does not work, unless I made a mistake:
> Linux 2.6.9 takes 15 seconds to copy 105 MB to Mac OSX
> Linux 2.6.10 with the TCP patch below still takes 325 seconds to do the same.
> 
> You can pick the new tcpdump report, created through:
> tcpdump -i eth1 ip host 10.107.96.230 -w /tmp/dump-2.6.10-tcp2
> at http://fullpliant.org/pliant/browse/file/archive/dump-2.6.10-tcp2.gz
> 
> Here is the connection summary:
> 
> Dell PowerEdge 2600 (dual Xeon with hyper threading) running libsmbclient
> on Linux 2.6.x, IP for eth1 (Intel pro 1000) is 10.107.96.7 (full
> duplex, flow control is enabled)
>      |
>      |
> gigabit switch
>      |
>      |
> 100 Mbps switch
>      |
>      |
> Mac running Samba server on OSX,
> IP is 10.107.96.230

"Cooking" the trace with tcpdump -ttt to give the relative timestamdps makes 
things look like Mac OSX has an ACK avoidance heuristic in it?  I figured there 
was one in their OX <= 9 stack that came from a third-party, wasn't sure if they 
put that into their OSX stack - IIRC that one is not from the third-party.

FWIW, there are two or three other stacks that have ACK avoidance heuristics as 
well, it isn't an OSX only thing.

000780 10.107.96.230.139 > 10.107.96.7.32801: P 753:822(69) ack 1556 win 65535 
<nop,nop,timestamp 1709240657 534173> NBT Packet (DF)
000579 10.107.96.7.32801 > 10.107.96.230.139: . 1556:3004(1448) ack 822 win 1460 
<nop,nop,timestamp 534175 1709240657> NBT Packet (DF)
000027 10.107.96.7.32801 > 10.107.96.230.139: . 3004:4452(1448) ack 822 win 1460 
<nop,nop,timestamp 534175 1709240657> NBT Packet (DF)
000005 10.107.96.7.32801 > 10.107.96.230.139: . 4452:5900(1448) ack 822 win 1460 
<nop,nop,timestamp 534175 1709240657> NBT Packet (DF)
074685 10.107.96.230.139 > 10.107.96.7.32801: . ack 5900 win 62268 
<nop,nop,timestamp 1709240657 534175> (DF)

delack above

000012 10.107.96.7.32801 > 10.107.96.230.139: . 5900:7348(1448) ack 822 win 1460 
<nop,nop,timestamp 534249 1709240657> NBT Packet (DF)
000003 10.107.96.7.32801 > 10.107.96.230.139: . 7348:8796(1448) ack 822 win 1460 
<nop,nop,timestamp 534249 1709240657> NBT Packet (DF)
000002 10.107.96.7.32801 > 10.107.96.230.139: . 8796:10244(1448) ack 822 win 
1460 <nop,nop,timestamp 534249 1709240657> NBT Packet (DF)
000002 10.107.96.7.32801 > 10.107.96.230.139: . 10244:11692(1448) ack 822 win 
1460 <nop,nop,timestamp 534249 1709240657> NBT Packet (DF)
200024 10.107.96.230.139 > 10.107.96.7.32801: . ack 11692 win 56476 
<nop,nop,timestamp 1709240658 534249> (DF)

and again above.

000010 10.107.96.7.32801 > 10.107.96.230.139: . 11692:13140(1448) ack 822 win 
1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
000004 10.107.96.7.32801 > 10.107.96.230.139: . 13140:14588(1448) ack 822 win 
1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
000002 10.107.96.7.32801 > 10.107.96.230.139: P 14588:16036(1448) ack 822 win 
1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
000022 10.107.96.7.32801 > 10.107.96.230.139: . 16036:17484(1448) ack 822 win 
1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
000004 10.107.96.7.32801 > 10.107.96.230.139: P 17484:18192(708) ack 822 win 
1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
000994 10.107.96.230.139 > 10.107.96.7.32801: . ack 18192 win 65535 
<nop,nop,timestamp 1709240658 534449> (DF)
0

And then other cases where the ACK seems to take a rather long time to arrive, 
seems to correlate a bit with slowly increasing numbers of segments before the 
ACK is sent, and something along the lines of a 200 millisecond delayed ACK timer.

In some cases at least if the sender does not completely fill cwnd the ACKs will 
be delayed.  And IIRC under 2.6.10 with TSO enabled, the sender does not always 
fill cwnd.

hth,

rick jones
