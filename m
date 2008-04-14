From: Wenji Wu <wenji@fnal.gov>
Subject: RE: RE: A Linux TCP SACK Question
Date: Mon, 14 Apr 2008 17:47:21 -0500
Message-ID: <000301c89e81$80124570$6b5ee183@D2GT6T71>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov>
 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>
 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: 'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:52323 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761186AbYDNWrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 18:47:33 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZC0021S7B4TB@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Mon, 14 Apr 2008 17:47:33 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041417473225575 for
 <netdev@vger.kernel.org>; Mon, 14 Apr 2008 17:47:32 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZC00I0175HOZ@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Mon, 14 Apr 2008 17:47:33 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Ilpo,

Could the throughput difference with SACK ON/OFF be due to the following
code in tcp_ack()?

3120        if (tcp_ack_is_dubious(sk, flag)) {
3121                /* Advance CWND, if state allows this. */
3122                if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
3123                    tcp_may_raise_cwnd(sk, flag))
3124                        tcp_cong_avoid(sk, ack, prior_in_flight, 0);
3125                tcp_fastretrans_alert(sk, prior_packets -
tp->packets_out, flag);
3126        } else {
3127                if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
3128                        tcp_cong_avoid(sk, ack, prior_in_flight, 1);
3129        }

In my tests, there are actually no packet drops, just severe packet
reordering in both forward and reverse paths. With good tcp_reordering
auto-tuning, there are few retransmissions.

(1) With SACK option off, the reorder ACKs will not cause much harm to the
throughput. As you have pointed out in the email that "The ACK reordering
should just make the number of duplicate acks smaller because part of them
get discarded as old ones as a newer cumulative ACK often arrives a bit
"ahead" of its time making rest smaller sequenced ACKs very close to on-op."

If there are any ACK advancement, tcp_cong_avoid() will be called. 

(2) With the sack option is on. If the ACKs do not advance the left edge of
the window, those ACKs will go to "old_ack" of "tcp_ack()", no much
processing except sack-tagging the corresponding packets in the
retransmission queue. tcp_cong_avoid() will not be called.

However, if the ACKs advance the left edge of the window and these ACKs
include SACK options, tcp_ack_is_dubious(sk, flag)) would be true. Then the
calling of tcp_cong_avoid() needs to satisfy the if-condition at line 3122,
which is stricter than the if-condition at line 3127.

So, the congestion window with SACK on would be smaller than with SACK off. 

If you run tcptrace and xplot on the files I posted, you would see lots ACKs
will advance the left edge of the window, and include SACK blocks.

Not quite sure, just a guess.

wenji


