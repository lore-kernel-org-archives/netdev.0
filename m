From: <Li_Xin2@emc.com>
Subject: RE: TCP keepalive timer problem
Date: Thu, 27 Aug 2009 21:55:35 -0400
Message-ID: <0939B589FC103041945B9F13274963E303BA96BB@CORPUSMX90A.corp.emc.com>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com> <4A93E36C.8070502@gmail.com> <0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com> <4A967FCE.3000807@gmail.com> <87skfdl6qt.fsf@basil.nowhere.org> <4A969566.3070606@gmail.com> <20090827142927.GA17220@basil.fritz.box> <4A969CDC.6060402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>, <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751301AbZH1B4Q@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4A969CDC.6060402@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > Yep, so to recap we have two changes :

> 1) The one I sent (taking into account the time of last ACK we
received) to compute the
> timer delays.

> 2) The one you suggest, avoiding to send a probe if we have packets in
flight, relying
> on normal retransmits timers.

I agree with these two changes, but I think the patch for point 2 given
by Eric is not correct:


elapsed = keepalive_time_when(tp);

 if (tp->packets_out || tcp_send_head(sk))
 	if (tcp_retries2_time < keepalive_time_when(tp))
 		goto resched;
 elapsed = tcp_time_stamp - tp->rcv_tstamp;


The problem is: you should not always compare tcp_retries2_time with
keepalive_time_when. If the first keepalive probe is already sent, you
should compare with keepalive_intvl_when
 ( or keepalive_intvl_when * (
tp->keepalive_probes?:sysctl_tcp_keepalive_probes -
icsk->icsk_probes_out ) if keepalive probe is already sent, and the
elapsed time also needs to take that into account.

elapsed =
icsk->icsk_probes_out?keepalive_intvl_when(tp):keepalive_time_when(tp);

 if (tp->packets_out || tcp_send_head(sk))
 	if (tcp_retries2_time < (icsk->icsk_probes_out?
keepalive_intvl_when(tp)  : keepalive_time_when(tp))
 		goto resched;
 elapsed = tcp_time_stamp - tp->rcv_tstamp;

How do you think?
