From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Re: Linux TCP in the presence of delays or drops...
Date: Mon, 31 Jul 2006 19:49:28 +0200
Message-ID: <44CE42A8.7090305@kom.aau.dk>
References: <44CD0D58.7050207@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@osdl.org>, davidwei79@gmail.com,
	hsu@leaf.dragonflybsd.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:1939 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S1030292AbWGaRth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 13:49:37 -0400
To: Oumer Teyeb <oumer@kom.aau.dk>
In-Reply-To: <44CD0D58.7050207@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

it would be so great if some of you could spare a few minutes and take a 
look at the traces I provided.....see below for the original postng...I 
just had a couple of things to add which I noticed in linux TCP 
behaviour which I have not seen documented anywhere else (or which I 
might have misread..:-)...and below I have given yet another trace that 
illustrates one of the TCP linux behaviour which I am having trouble 
understanding....

-If multiple timeouts occur for one packet then even if we are using the 
timestamp option or FRTO TCP linux is not able to detect spurious 
retransmissions... and TCP linux is able to detect spurious 
retransmissions only for a single timeout for one packet or fast 
retransmissions that are caused by duplicate ACK reception.....I have 
some traces that show this behaviour, let me know if you are interested.

-In the cases where TCP timestamp or FRTO is not able to detect spurious 
retransmissions, the performance degrades even more than when TCP 
timestamp or FRTO option are not used....

I also have one additional trace that shows the problem with the case of 
an explained pause in the tcp sender during retransmission which I found 
really hard to explain.... it is similar to the case 1) but this time I 
am doing an upgrade instead from a 384kbps connection to 1Mbps 
connection.... the traces and tcptrace time sequence curve can be found 
at...
http://kom.aau.dk/~oumer/drop_0_delay_UPGRADE_SERVER.dat
http://kom.aau.dk/~oumer/drop_0_delay_UPGRADE_CLIENT.dat
and the tcptrace time sequence curve can be found in
http://kom.aau.dk/~oumer/drop_0_delay_UPGRADE.ps

as you can see from the server side trace... (all the packets shown here 
are retransmissions because I flushed the sender's buffer at time 
instant 17:26:24.657)
17:26:26.261972  2267693336:2267694796(1460) ack 3498775069 win 5840 (DF)
17:26:26.319180  . ack 2267694796 win 61320 (DF) [tos 0x8]
17:26:26.321961  2267694796:2267696256(1460) ack 3498775069 win 5840 (DF)
17:26:26.379160  . ack 2267696256 win 61320 (DF) [tos 0x8]
17:26:26.381940 . 2267696256:2267697716(1460) ack 3498775069 win 5840 (DF)
17:26:26.439138  . ack 2267697716 win 61320 (DF) [tos 0x8]
17:26:26.441925  2267697716:2267699176(1460) ack 3498775069 win 5840 (DF)
17:26:26.499144   ack 2267699176 win 61320 (DF) [tos 0x8]
17:26:28.234327  2267699176:2267700636(1460) ack 3498775069 win 5840 (DF)

eventhough the server got an ACK with # ack 2267699176 at timeinstant 
17:26:26.49...it waited till 17:26:28.234 to resend  the packet... which 
is around
1.73 seconds... I have checked with other traces where I introduced 
delay and for the link the first timeout occurs after 1.73 second, which 
seems to be the RTO at that time, and for no apparent reason
TCP is wating for a timeout...  case 1 is quite similar but there the 
retransmissions were triggered by timeout to begin with, here the 
retransmissions are triggered by duplicate ACKs...in the case1 described 
below this abnormal behaviour occured after only a couple of packets 
were retransmitted...here it took quite some retransmissions before the 
same problem happend... any insight into this is greatly appreciated!!

Thanks in advance,
Oumer

Oumer Teyeb wrote:

> Hi all,
>
> I have some questions regarding Linux TCP in the presence of delays or 
> packet drops. It is somehow long mail, but the questions are two or 
> three, just wanted to provide a detailed information so that the 
> problem is clear. thanx for the patience!!
>
> Best regards,
> Oumer
>
> Note that for the traces referred here, SACK,timestamps, and FRTO are 
> all disabled...
>
> 1) packet drops
> ================
> I have a trace where the tcp sender window is flushed and  then the 
> connection speed is  changed from 1Mbps to 384kbps...
> The trace files from both the client and the server side can be found at
> http://kom.aau.dk/~oumer/drop_0_delay_SERVER.dat
> http://kom.aau.dk/~oumer/drop_0_delay_CLIENT.dat
> and the tcptrace time sequence curve can be found in
> http://kom.aau.dk/~oumer/drop_0_delay.ps
>
> as can be seen from the plot and the trace files at around 
> 17:19:35.705733, the window was flushed (both the sender's and 
> receivers), and hence packets with seq  numbers from
> 1840001135 upto 1840058075  were dropped (39 packets)...and also the 
> ACK for 1840001135 was also dropped (from the traces this can be seen 
> as it appears
> in the client trace but not on the server trace)...
> and since there were still packets to be sent the sender keeps sending 
> a few more packets
> and when  few of them are received (from the client side trace..)
>
> 17:19:35.938017 1840059535:1840060995(1460) ack 3059152863 win 5840 
> (DF)...
> 17:19:35.938028  ack 1840001135 win 62780 (DF) [tos 0x8]...first ACK 
> that is going to be received by the sender
> 17:19:35.969316  1840060995:1840062455(1460) ack 3059152863 win 5840 (DF)
> 17:19:35.969325  1840001135 win 62780 (DF) [tos 0x8]....first 
> duplicate ACK
> 17:19:36.000519  1840062455:1840063915(1460) ack 3059152863 win 5840 (DF)
> 17:19:36.000528  ack 1840001135 win 62780 (DF) [tos 0x8]... second 
> duplicate ACK
>
> when the server gets this 2nd duplicate ACK, it retransmits the 
> packets (this is clearly visible from the tcptrace curve.)..eventhough 
> a 3rd duplicate ACK soon follows.
> so my first question  "why is the second duplicate ACK triggering a 
> retransmission?"...
>
> also after that, there are a couple of retransmissions triggerd by the 
> reception of the ACK for the new ACKs and at time instant  (server 
> side trace)
> 17:19:36.057149 . 1840001135:1840002595(1460) ack 3059152863 win 5840 
> (DF)..first packet retransmitted
> 17:19:36.085569   ack 1840001135 win 62780 (DF) [tos 0x8] ...this is 
> the third duplicate ACK which should have caused the retrans, but lets 
> ignore it for now
> 17:19:36.248599  ack 1840002595 ...retransmitted packet acked
> 17:19:36.251382  1840002595:1840004055(1460) ack 3059152863 win 5840 
> (DF) ... next packet retransmitted
> 17:19:36.442831  ack 1840004055 win 61320 (DF) [tos 0x8]...2nd packet 
> acked also
> 17:19:36.445625  1840004055:1840005515(1460) ack 3059152863 win 5840 
> (DF) .. third packet retransmitted
> 17:19:36.637224  ack 1840005515 win 61320 (DF) [tos 0x8] ... third 
> packet acked
> 17:19:37.417022  1840005515:1840006975(1460) ack 3059152863 win 5840 
> (DF) ... fourth packet retransmitted
>
> As you can see  there is 0.8 second gap between the ack for the 
> reception of the ACK for the third packet and the sending of the 
> fourth packet...so my second question  "why didnt the sender immediatly
> send the fourth packet after the reception of the ack for the third?"
> I generated the same scenario 20 times, and the same thing happens in 
> all of them...
>
> 2)packet delays
> ===============
> in the second scenario, I have a 2 second delay, but no packet 
> drops...the downgrade in bandwidth also happens, but the packets in 
> the window are buffered for 2 seconds and released...
>
> The trace files from both the client and the server side can be found 
> at....
> http://kom.aau.dk/~oumer/delay_0_drop_SERVER.dat
> http://kom.aau.dk/~oumer/delay_0_drop_CLIENT.dat
> and the tcptrace time sequence curve can be found in
> http://kom.aau.dk/~oumer/delay_0_drop.ps
>
> The delay is applied from 17:20:01.066725 to 17:20:03.067022
> as can be seen from the traces and plot packets with seq number 
> 1858561966 to 1858618906 ( a total of 40 packets) were queued at the 
> server and one packet from the receiver, which is an ACK for
> pkt # 1858560506  ....
> at around 17:20:03.15 this ack is received and sender thinks this is 
> the result of its retransmission (which actually was dropped, so at 
> this point the receiver hasnot got any retransmissions).. and the 
> normal retransmission is resumed (as well as sending of some new data, 
> as the window allows it) as can be seen from the server side trace 
> upto time instant 17:20:04.539682
> ...at which point we can see that on the client trace the 
> retransmissions actually start arriving at the receiver (so far the 
> ACKs that were triggering the retransmissions were acks to the 
> reception of the original
> but delayed packets)...and this duplicate arrivals lead to multiple 
> duplicate ACKs... what I dont understand is why this duplicate ACKs 
> (there are 40 duplicate ACKs.), no fast retransmission was triggered..
> so my third question "Why is it that the duplicate ACKs are not 
> tiggerring fast retransmissions?" this creates a 1.3 second gap 
> transmission gap...actually this is better than fast retransmission 
> because it is not leading to further retransmissions...so is the linux 
> TCP so clever that it can figure out the problem without using SACK, 
> timestamps or FRTO ? ...or is this a special "feature" :-)....
>
> I have repeated this also twenty times and the traces are similar...
>
>
>
>
>
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


