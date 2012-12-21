From: Rick Jones <rick.jones2@hp.com>
Subject: Is keepalive behaving as expected in 3.7.0+/net-next?
Date: Fri, 21 Dec 2012 14:05:28 -0800
Message-ID: <50D4DD28.30903@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:12411 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab2LUWF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 17:05:29 -0500
Received: from g1t0039.austin.hp.com (g1t0039.austin.hp.com [16.236.32.45])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id 29D6438131
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 22:05:29 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g1t0039.austin.hp.com (Postfix) with ESMTP id E48E0341A4
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 22:05:28 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking to do a bit more documentation clean-up and thought I 
would work on the descriptions of the "keepalive" sysctls, but first I 
wanted to see if they behaved as the existing descriptions suggested:

> tcp_keepalive_time - INTEGER
>         How often TCP sends out keepalive messages when keepalive is enabled.
>         Default: 2hours.
>
> tcp_keepalive_probes - INTEGER
>         How many keepalive probes TCP sends out, until it decides that the
>         connection is broken. Default value: 9.
>
> tcp_keepalive_intvl - INTEGER
>         How frequently the probes are send out. Multiplied by
>         tcp_keepalive_probes it is time to kill not responding connection,
>         after probes started. Default value: 75sec i.e. connection
>         will be aborted after ~11 minutes of retries.

I interpreted all that that as:  When a connection is idle, TCP will 
send a keepalive probe every tcp_keepalive_time seconds.  If a response 
to a keepalive probe is not received, TCP will resend (retransmit) it 
every tcp_keepalive_intvl seconds.

However, what I see is that on a connection where the remote is indeed 
still there, only the first keepalive probe is sent after 
tcp_keepalive_time, and thereafter it is sent every tcp_keepalive_intvl 
seconds.

Now, some of this may relate to my being impatient - rather than wait 
two hours for the first probe, I set tcp_keepalive_time to 3 seconds, 
and tcp_keepalive_intvl to 7 seconds.  I then kicked-off a ./configure 
--intervals-enable netperf TCP_RR test with a burst of one and a wait 
time of 90 seconds and got the following (trimmed) trace:

13:43:46.879133 IP netnextraj.43054 > netnextraj2.srvr: Flags [S], seq 
807869796, win 14600, options [mss 1460,sackOK,TS val 133470 ecr 
0,nop,wscale 7], length 0
13:43:46.880091 IP netnextraj2.srvr > netnextraj.43054: Flags [S.], seq 
1522345902, ack 807869797, win 14480, options [mss 1460,sackOK,TS val 
136186 ecr 133470,nop,wscale 4], length 0
13:43:46.880114 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
1, win 115, options [nop,nop,TS val 133470 ecr 136186], length 0
13:43:46.880306 IP netnextraj.43054 > netnextraj2.srvr: Flags [P.], seq 
1:11, ack 1, win 115, options [nop,nop,TS val 133470 ecr 136186], length 10
13:43:46.880948 IP netnextraj2.srvr > netnextraj.43054: Flags [.], ack 
11, win 905, options [nop,nop,TS val 136187 ecr 133470], length 0
13:43:46.880964 IP netnextraj2.srvr > netnextraj.43054: Flags [P.], seq 
1:11, ack 11, win 905, options [nop,nop,TS val 136187 ecr 133470], length 10
13:43:46.881161 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
11, win 115, options [nop,nop,TS val 133470 ecr 136187], length 0

The first probe above comes after 3 seconds - tcp_keepalive_time - at 
13:43:49

13:43:49.886752 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
11, win 115, options [nop,nop,TS val 134222 ecr 136187], length 0

And it does seem to elicit a response:

13:43:49.887530 IP netnextraj2.srvr > netnextraj.43054: Flags [.], ack 
11, win 905, options [nop,nop,TS val 136938 ecr 133470], length 0

Now it starts sending probes every 7 seconds (tcp_keepalive_intvl):

13:43:56.903576 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
11, win 115, options [nop,nop,TS val 135976 ecr 136938], length 0
13:43:56.904480 IP netnextraj2.srvr > netnextraj.43054: Flags [.], ack 
11, win 905, options [nop,nop,TS val 138693 ecr 133470], length 0
13:44:03.910744 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
11, win 115, options [nop,nop,TS val 137728 ecr 138693], length 0
13:44:03.911623 IP netnextraj2.srvr > netnextraj.43054: Flags [.], ack 
11, win 905, options [nop,nop,TS val 140444 ecr 133470], length 0

I;ve deleted the next 9 or so probes...  It continues, and doesn't 
terminate the connection, so I assume it was happy with the responses to 
the probes.

13:45:13.990746 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
11, win 115, options [nop,nop,TS val 155248 ecr 156213], length 0
13:45:13.991578 IP netnextraj2.srvr > netnextraj.43054: Flags [.], ack 
11, win 905, options [nop,nop,TS val 157965 ecr 133470], length 0

Now the next netperf transaction happens:

13:45:16.879222 IP netnextraj.43054 > netnextraj2.srvr: Flags [P.], seq 
11:21, ack 11, win 115, options [nop,nop,TS val 155970 ecr 157965], 
length 10
13:45:16.880033 IP netnextraj2.srvr > netnextraj.43054: Flags [P.], seq 
11:21, ack 21, win 905, options [nop,nop,TS val 158687 ecr 155970], 
length 10
13:45:16.880220 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
21, win 115, options [nop,nop,TS val 155970 ecr 158687], length 0

But the next keepalive probe is tcp_keepalive_intvl seconds after the 
last one, rather than that many, or tcp_keepalive_time seconds after the 
connection was last "active."

13:45:20.998739 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
21, win 115, options [nop,nop,TS val 157000 ecr 158687], length 0
13:45:20.999754 IP netnextraj2.srvr > netnextraj.43054: Flags [.], ack 
21, win 905, options [nop,nop,TS val 159717 ecr 155970], length 0
13:45:28.006747 IP netnextraj.43054 > netnextraj2.srvr: Flags [.], ack 
21, win 115, options [nop,nop,TS val 158752 ecr 159717], length 0
13:45:28.007624 IP netnextraj2.srvr > netnextraj.43054: Flags [.], ack 
21, win 905, options [nop,nop,TS val 161469 ecr 155970], length 0

Is this the expected behaviour?  If I reverse the values - make 
tcp_keepalive_time 7 and tcp_keepalive_intvl 3, it seems that all the 
probes are after 7 seconds.

rick jones
