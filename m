From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: RE: A Linux TCP SACK Question
Date: Mon, 14 Apr 2008 17:48:51 -0700
Message-ID: <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov> <fb8e9e4f102e.47f8ebfd@fnal.gov>
	 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
	 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
	 <fbbce0572843.47fb038c@fnal.gov>
	 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
	 <fba201de4228.47fb3b26@fnal.gov>
	 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
	 <000301c89e81$80124570$6b5ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: wenji@fnal.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:2518 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757645AbYDOAs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 20:48:56 -0400
Received: by wa-out-1112.google.com with SMTP id m16so2754057waf.23
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 17:48:55 -0700 (PDT)
In-Reply-To: <000301c89e81$80124570$6b5ee183@D2GT6T71>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2008 at 3:47 PM, Wenji Wu <wenji@fnal.gov> wrote:
> Hi, Ilpo,
>
>  Could the throughput difference with SACK ON/OFF be due to the following
>  code in tcp_ack()?
>
>  3120        if (tcp_ack_is_dubious(sk, flag)) {
>  3121                /* Advance CWND, if state allows this. */
>  3122                if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
>  3123                    tcp_may_raise_cwnd(sk, flag))
>  3124                        tcp_cong_avoid(sk, ack, prior_in_flight, 0);
>  3125                tcp_fastretrans_alert(sk, prior_packets -
>  tp->packets_out, flag);
>  3126        } else {
>  3127                if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
>  3128                        tcp_cong_avoid(sk, ack, prior_in_flight, 1);
>  3129        }
>
>  In my tests, there are actually no packet drops, just severe packet
>  reordering in both forward and reverse paths. With good tcp_reordering
>  auto-tuning, there are few retransmissions.
>
>  (1) With SACK option off, the reorder ACKs will not cause much harm to the
>  throughput. As you have pointed out in the email that "The ACK reordering
>
> should just make the number of duplicate acks smaller because part of them
>  get discarded as old ones as a newer cumulative ACK often arrives a bit
>  "ahead" of its time making rest smaller sequenced ACKs very close to on-op."
>
>  If there are any ACK advancement, tcp_cong_avoid() will be called.
>
>  (2) With the sack option is on. If the ACKs do not advance the left edge of
>  the window, those ACKs will go to "old_ack" of "tcp_ack()", no much
>  processing except sack-tagging the corresponding packets in the
>  retransmission queue. tcp_cong_avoid() will not be called.
>
>  However, if the ACKs advance the left edge of the window and these ACKs
>  include SACK options, tcp_ack_is_dubious(sk, flag)) would be true. Then the
>  calling of tcp_cong_avoid() needs to satisfy the if-condition at line 3122,
>  which is stricter than the if-condition at line 3127.
>
>  So, the congestion window with SACK on would be smaller than with SACK off.
>
>  If you run tcptrace and xplot on the files I posted, you would see lots ACKs
>  will advance the left edge of the window, and include SACK blocks.
>
>  Not quite sure, just a guess.

I had considered this, but it would seem that tcp_may_raise_cwnd() in
this case *should* return true, right?

Sill the mystery remains as to why *both* are going so slowly.  You
mentioned you're using a web100 kernel.  What are the final values of
all the variables for the connections (grab with readall)?

Thanks,
  -John
