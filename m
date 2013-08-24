From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Sat, 24 Aug 2013 13:28:00 -0700
Message-ID: <1377376080.8828.83.camel@edumazet-glaptop>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	 <CADVnQymvQz67k1_f4rRJxPVUFWL=rM5vnT-ZO1VPSxN-E0uzDA@mail.gmail.com>
	 <1377370594.8828.72.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:53156 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445Ab3HXU2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Aug 2013 16:28:02 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so1956481pbc.32
        for <netdev@vger.kernel.org>; Sat, 24 Aug 2013 13:28:02 -0700 (PDT)
In-Reply-To: <1377370594.8828.72.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-24 at 11:56 -0700, Eric Dumazet wrote:

> Problem is that if the application does a sendmsg( 1 Mbytes) right after
> accept(), we'll cook 14KB TSO packets and are back to initial problem.
> 
> Quite frankly TSO advantage for servers sending replies that are 10MSS
> or less is thin, because we spend most of cpu cycles in socket
> setup/dismantle and ACK processing.
> 
> TSO is a win for sockets sending say more than 100KB, or even 1MB

Another interesting point having small packets at the beginning of the
connection when/if pacing is enabled in the (FQ) packet scheduler,
an incorrect initial rtt would have lower impact :

13:14:45.271930 IP 10.246.17.83.41052 > 10.246.17.84.41129: S 2688061178:2688061178(0) win 29200 <mss 1460,sackOK,timestamp 281602 0,nop,wscale 6>
13:14:45.322055 IP 10.246.17.84.41129 > 10.246.17.83.41052: S 1339982632:1339982632(0) ack 2688061179 win 28960 <mss 1460,sackOK,timestamp 146299869 281602,nop,wscale 7>
13:14:45.322126 IP 10.246.17.83.41052 > 10.246.17.84.41129: . ack 1 win 457 <nop,nop,timestamp 281652 146299869>
13:14:45.322245 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 1:1449(1448) ack 1 win 457 <nop,nop,timestamp 281652 146299869>
13:14:45.324944 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 1449:2897(1448) ack 1 win 457 <nop,nop,timestamp 281652 146299869>
13:14:45.327600 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 2897:4345(1448) ack 1 win 457 <nop,nop,timestamp 281652 146299869>
13:14:45.330301 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 4345:5793(1448) ack 1 win 457 <nop,nop,timestamp 281652 146299869>
13:14:45.333001 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 5793:7241(1448) ack 1 win 457 <nop,nop,timestamp 281653 146299869>
13:14:45.335697 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 7241:8689(1448) ack 1 win 457 <nop,nop,timestamp 281653 146299869>
13:14:45.338392 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 8689:10137(1448) ack 1 win 457 <nop,nop,timestamp 281653 146299869>
13:14:45.341087 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 10137:11585(1448) ack 1 win 457 <nop,nop,timestamp 281653 146299869>
13:14:45.343770 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 11585:13033(1448) ack 1 win 457 <nop,nop,timestamp 281653 146299869>
13:14:45.346471 IP 10.246.17.83.41052 > 10.246.17.84.41129: . 13033:14481(1448) ack 1 win 457 <nop,nop,timestamp 281653 146299869>
13:14:45.372577 IP 10.246.17.84.41129 > 10.246.17.83.41052: . ack 1449 win 249 <nop,nop,timestamp 146299919 281652>

If the "ack 1449" coming back from client was coming sooner than expected,
this could change the srtt estimation and packet scheduler could
send remaining packets sooner.

This makes me think that srtt computation could be more precise.

First RTT sample sets SRTT=RTT

But second sample sets to SRTT = SRTT*7/8 + nRTT,
while it probably should do SRTT = (SRTT + nRTT)/2

Third sample also should do :  SRTT = SRTT*2/3 + nRTT/3
...
