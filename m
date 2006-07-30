From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Linux TCP in the presence of delays or drops...
Date: Sun, 30 Jul 2006 21:49:44 +0200
Message-ID: <44CD0D58.7050207@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:60891 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S932449AbWG3Ttr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 15:49:47 -0400
Received: from oumer-dt.kom.auc.dk ([192.168.111.236])
	by zaz.kom.auc.dk with esmtp (Exim 2.05 #3)
	id 1G7HIH-0002lI-00
	for netdev@vger.kernel.org; Sun, 30 Jul 2006 21:49:45 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I have some questions regarding Linux TCP in the presence of delays or 
packet drops. It is somehow long mail, but the questions are two or 
three, just wanted to provide a detailed information so that the problem 
is clear. thanx for the patience!!

Best regards,
Oumer

Note that for the traces referred here, SACK,timestamps, and FRTO are 
all disabled...

1) packet drops
================
I have a trace where the tcp sender window is flushed and  then the 
connection speed is  changed from 1Mbps to 384kbps...
The trace files from both the client and the server side can be found at
http://kom.aau.dk/~oumer/drop_0_delay_SERVER.dat
http://kom.aau.dk/~oumer/drop_0_delay_CLIENT.dat
and the tcptrace time sequence curve can be found in
http://kom.aau.dk/~oumer/drop_0_delay.ps

as can be seen from the plot and the trace files at around 
17:19:35.705733, the window was flushed (both the sender's and 
receivers), and hence packets with seq  numbers from
1840001135 upto 1840058075  were dropped (39 packets)...and also the ACK 
for 1840001135 was also dropped (from the traces this can be seen as it 
appears
in the client trace but not on the server trace)...
and since there were still packets to be sent the sender keeps sending a 
few more packets
and when  few of them are received (from the client side trace..)

17:19:35.938017 1840059535:1840060995(1460) ack 3059152863 win 5840 (DF)...
17:19:35.938028  ack 1840001135 win 62780 (DF) [tos 0x8]...first ACK 
that is going to be received by the sender
17:19:35.969316  1840060995:1840062455(1460) ack 3059152863 win 5840 (DF)
17:19:35.969325  1840001135 win 62780 (DF) [tos 0x8]....first duplicate ACK
17:19:36.000519  1840062455:1840063915(1460) ack 3059152863 win 5840 (DF)
17:19:36.000528  ack 1840001135 win 62780 (DF) [tos 0x8]... second 
duplicate ACK

when the server gets this 2nd duplicate ACK, it retransmits the packets 
(this is clearly visible from the tcptrace curve.)..eventhough a 3rd 
duplicate ACK soon follows.
so my first question  "why is the second duplicate ACK triggering a 
retransmission?"...

also after that, there are a couple of retransmissions triggerd by the 
reception of the ACK for the new ACKs and at time instant  (server side 
trace)
17:19:36.057149 . 1840001135:1840002595(1460) ack 3059152863 win 5840 
(DF)..first packet retransmitted
17:19:36.085569   ack 1840001135 win 62780 (DF) [tos 0x8] ...this is the 
third duplicate ACK which should have caused the retrans, but lets 
ignore it for now
17:19:36.248599  ack 1840002595 ...retransmitted packet acked
17:19:36.251382  1840002595:1840004055(1460) ack 3059152863 win 5840 
(DF) ... next packet retransmitted
17:19:36.442831  ack 1840004055 win 61320 (DF) [tos 0x8]...2nd packet 
acked also
17:19:36.445625  1840004055:1840005515(1460) ack 3059152863 win 5840 
(DF) .. third packet retransmitted
17:19:36.637224  ack 1840005515 win 61320 (DF) [tos 0x8] ... third 
packet acked
17:19:37.417022  1840005515:1840006975(1460) ack 3059152863 win 5840 
(DF) ... fourth packet retransmitted

As you can see  there is 0.8 second gap between the ack for the 
reception of the ACK for the third packet and the sending of the fourth 
packet...so my second question  "why didnt the sender immediatly
send the fourth packet after the reception of the ack for the third?"
I generated the same scenario 20 times, and the same thing happens in 
all of them...

2)packet delays
===============
in the second scenario, I have a 2 second delay, but no packet 
drops...the downgrade in bandwidth also happens, but the packets in the 
window are buffered for 2 seconds and released...

The trace files from both the client and the server side can be found at....
http://kom.aau.dk/~oumer/delay_0_drop_SERVER.dat
http://kom.aau.dk/~oumer/delay_0_drop_CLIENT.dat
and the tcptrace time sequence curve can be found in
http://kom.aau.dk/~oumer/delay_0_drop.ps

The delay is applied from 17:20:01.066725 to 17:20:03.067022
as can be seen from the traces and plot packets with seq number 
1858561966 to 1858618906 ( a total of 40 packets) were queued at the 
server and one packet from the receiver, which is an ACK for
pkt # 1858560506  ....
at around 17:20:03.15 this ack is received and sender thinks this is the 
result of its retransmission (which actually was dropped, so at this 
point the receiver hasnot got any retransmissions).. and the normal 
retransmission is resumed (as well as sending of some new data, as the 
window allows it) as can be seen from the server side trace upto time 
instant 17:20:04.539682
...at which point we can see that on the client trace the 
retransmissions actually start arriving at the receiver (so far the ACKs 
that were triggering the retransmissions were acks to the reception of 
the original
but delayed packets)...and this duplicate arrivals lead to multiple 
duplicate ACKs... what I dont understand is why this duplicate ACKs 
(there are 40 duplicate ACKs.), no fast retransmission was triggered..
so my third question "Why is it that the duplicate ACKs are not 
tiggerring fast retransmissions?" this creates a 1.3 second gap 
transmission gap...actually this is better than fast retransmission 
because it is not leading to further retransmissions...so is the linux 
TCP so clever that it can figure out the problem without using SACK, 
timestamps or FRTO ? ...or is this a special "feature" :-)....

I have repeated this also twenty times and the traces are similar...




 



