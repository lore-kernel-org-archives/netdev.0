From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 14:00:30 -0800
Message-ID: <41F17B7E.2020002@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com>	<41F163AD.5070400@hp.com> <20050121124441.76cbbfb9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050121124441.76cbbfb9.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Don't set tcp_tso_win_divisor to such a low value, that's why
> TCP is being so bursty in your case.  The default value
> of "8" keeps TCP reasonable well ACK clocked, thus avoiding
> the throughput lossage you are seeing with it set to "1".

If my only interest were bulk throughput then that would be fine, but I'm also concerned about shorter lived, request/response sorts 
of workloads.  The netperf TCP_STREAM test was simply a convenient vehicle.  If it would be better, I could switch to a different 
netperf test.

> With a value of "1", TCP will wait for the entire congestion
> window to be ACK'd before it will spit out a huge TSO frame.

It looks though like it then is not spitting-out a full congestion window.  Here is the openeing from the TSO on case:

000031 IP 192.168.13.223.33287 > 192.168.13.1.64632: S 2243249440:2243249440(0) win 5840 <mss 1460,sackOK,timestamp 168858934 
0,nop,wscale 2>
000095 IP 192.168.13.1.64632 > 192.168.13.223.33287: S 3684332982:3684332982(0) ack 2243249441 win 65535 <mss 
1460,nop,nop,sackOK,wscale 2,nop,nop,nop,timestamp 960528547 168858934>
000014 IP 192.168.13.223.33287 > 192.168.13.1.64632: . ack 1 win 1460 <nop,nop,timestamp 168858934 960528547>
000118 IP 192.168.13.223.33287 > 192.168.13.1.64632: . 1:4345(4344) ack 1 win 1460 <nop,nop,timestamp 168858934 960528547>
000117 IP 192.168.13.1.64632 > 192.168.13.223.33287: . ack 1449 win 32768 <nop,nop,timestamp 960528547 168858934>
000002 IP 192.168.13.1.64632 > 192.168.13.223.33287: . ack 4345 win 32768 <nop,nop,timestamp 960528547 168858934>
000248 IP 192.168.13.223.33287 > 192.168.13.1.64632: . 4345:8689(4344) ack 1 win 1460 <nop,nop,timestamp 168858935 960528547>

Indeed, it waited for the ACK 4335, but then shouldn't it have emitted 4344+1448 or 5792 bytes or perhaps 7240 (since there were two 
ACKs?

(this is a hacked tcpdump to treat an IP length field of zero as a TSO segment and use the other reported length - a patch went to 
tcpdump-workers, not sure if they will like it or not...)

In the TSO off case it does send a full cwnd:

000031 IP 192.168.13.223.33289 > 192.168.13.1.64633: S 2252401705:2252401705(0) win 5840 <mss 1460,sackOK,timestamp 168870470 
0,nop,wscale 2>
000099 IP 192.168.13.1.64633 > 192.168.13.223.33289: S 3685848941:3685848941(0) ack 2252401706 win 65535 <mss 
1460,nop,nop,sackOK,wscale 2,nop,nop,nop,timestamp 960529700 168870470>
000014 IP 192.168.13.223.33289 > 192.168.13.1.64633: . ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000080 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 1:1449(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000009 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 1449:2897(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000010 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 2897:4345(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000145 IP 192.168.13.1.64633 > 192.168.13.223.33289: . ack 1449 win 32768 <nop,nop,timestamp 960529700 168870470>
000001 IP 192.168.13.1.64633 > 192.168.13.223.33289: . ack 4345 win 32768 <nop,nop,timestamp 960529700 168870470>
000190 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 4345:5793(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000006 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 5793:7241(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000013 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 7241:8689(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000005 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 8689:10137(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>
000004 IP 192.168.13.223.33289 > 192.168.13.1.64633: . 10137:11585(1448) ack 1 win 1460 <nop,nop,timestamp 168870470 960529700>

Given the relative timestamps (tcpdump -ttt... taken on the sender) it _seems_ that even in the TSO-off case it was waiting for the 
full cwnd to be ACKed, buth then once ACKed, it send the full 5 segment cwnd. (Although that seeming to wait would really need to be 
confirmed by an intra-stack trace I suppose...)

rick jones
