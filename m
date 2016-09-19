From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Mon, 19 Sep 2016 13:57:34 -0700
Message-ID: <20160919135734.04ab5172@xeon-e3>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
        <1474236233-28511-17-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34999 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbcISU5Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 16:57:24 -0400
Received: by mail-pf0-f170.google.com with SMTP id z123so54557896pfz.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 13:57:23 -0700 (PDT)
In-Reply-To: <1474236233-28511-17-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Sep 2016 18:03:53 -0400
Neal Cardwell <ncardwell@google.com> wrote:

> +static int bbr_bw_rtts	= CYCLE_LEN + 2; /* win len of bw filter (in rounds) */
> +static u32 bbr_min_rtt_win_sec = 10;	 /* min RTT filter window (in sec) */
> +static u32 bbr_probe_rtt_mode_ms = 200;	 /* min ms at cwnd=4 in BBR_PROBE_RTT */
> +static int bbr_min_tso_rate	= 1200000;  /* skip TSO below here (bits/sec) */
> +
> +/* We use a high_gain value chosen to allow a smoothly increasing pacing rate
> + * that will double each RTT and send the same number of packets per RTT that
> + * an un-paced, slow-starting Reno or CUBIC flow would.
> + */
> +static int bbr_high_gain  = BBR_UNIT * 2885 / 1000 + 1;	/* 2/ln(2) */
> +static int bbr_drain_gain = BBR_UNIT * 1000 / 2885;	/* 1/high_gain */
> +static int bbr_cwnd_gain  = BBR_UNIT * 2;	/* gain for steady-state cwnd */
> +/* The pacing_gain values for the PROBE_BW gain cycle: */
> +static int bbr_pacing_gain[] = { BBR_UNIT * 5 / 4, BBR_UNIT * 3 / 4,
> +				 BBR_UNIT, BBR_UNIT, BBR_UNIT,
> +				 BBR_UNIT, BBR_UNIT, BBR_UNIT };
> +static u32 bbr_cycle_rand = 7;  /* randomize gain cycling phase over N phases */
> +
> +/* Try to keep at least this many packets in flight, if things go smoothly. For
> + * smooth functioning, a sliding window protocol ACKing every other packet
> + * needs at least 4 packets in flight.
> + */
> +static u32 bbr_cwnd_min_target	= 4;
> +
> +/* To estimate if BBR_STARTUP mode (i.e. high_gain) has filled pipe. */
> +static u32 bbr_full_bw_thresh = BBR_UNIT * 5 / 4;  /* bw up 1.25x per round? */
> +static u32 bbr_full_bw_cnt    = 3;    /* N rounds w/o bw growth -> pipe full */
> +
> +/* "long-term" ("LT") bandwidth estimator parameters: */
> +static bool bbr_lt_bw_estimator = true;	/* use the long-term bw estimate? */
> +static u32 bbr_lt_intvl_min_rtts = 4;	/* min rounds in sampling interval */
> +static u32 bbr_lt_loss_thresh = 50;	/*  lost/delivered > 20% -> "lossy" */
> +static u32 bbr_lt_conv_thresh = BBR_UNIT / 8;  /* bw diff <= 12.5% -> "close" */
> +static u32 bbr_lt_bw_max_rtts	= 48;	/* max # of round trips using lt_bw */
> +

Looks good, but could I suggest a simple optimization.
All these parameters are immutable in the version of BBR you are submitting.
Why not make the values const? And eliminate the always true long-term bw estimate
variable?

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 76baa8a..9c270a2 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -90,40 +90,41 @@ struct bbr {
 
 #define CYCLE_LEN	8	/* number of phases in a pacing gain cycle */
 
-static int bbr_bw_rtts	= CYCLE_LEN + 2; /* win len of bw filter (in rounds) */
-static u32 bbr_min_rtt_win_sec = 10;	 /* min RTT filter window (in sec) */
-static u32 bbr_probe_rtt_mode_ms = 200;	 /* min ms at cwnd=4 in BBR_PROBE_RTT */
-static int bbr_min_tso_rate	= 1200000;  /* skip TSO below here (bits/sec) */
+static const int bbr_bw_rtts = CYCLE_LEN + 2;  /* win len of bw filter (in rounds) */
+static const u32 bbr_min_rtt_win_sec = 10;     /* min RTT filter window (in sec) */
+static const u32 bbr_probe_rtt_mode_ms = 200;  /* min ms at cwnd=4 in BBR_PROBE_RTT */
+static const int bbr_min_tso_rate  = 1200000;  /* skip TSO below here (bits/sec) */
 
 /* We use a high_gain value chosen to allow a smoothly increasing pacing rate
  * that will double each RTT and send the same number of packets per RTT that
  * an un-paced, slow-starting Reno or CUBIC flow would.
  */
-static int bbr_high_gain  = BBR_UNIT * 2885 / 1000 + 1;	/* 2/ln(2) */
-static int bbr_drain_gain = BBR_UNIT * 1000 / 2885;	/* 1/high_gain */
-static int bbr_cwnd_gain  = BBR_UNIT * 2;	/* gain for steady-state cwnd */
+static const int bbr_high_gain  = BBR_UNIT * 2885 / 1000 + 1;	/* 2/ln(2) */
+static const int bbr_drain_gain = BBR_UNIT * 1000 / 2885;	/* 1/high_gain */
+static const int bbr_cwnd_gain  = BBR_UNIT * 2;	/* gain for steady-state cwnd */
 /* The pacing_gain values for the PROBE_BW gain cycle: */
-static int bbr_pacing_gain[] = { BBR_UNIT * 5 / 4, BBR_UNIT * 3 / 4,
-				 BBR_UNIT, BBR_UNIT, BBR_UNIT,
-				 BBR_UNIT, BBR_UNIT, BBR_UNIT };
-static u32 bbr_cycle_rand = 7;  /* randomize gain cycling phase over N phases */
+static const int bbr_pacing_gain[] = {
+  BBR_UNIT * 5 / 4, BBR_UNIT * 3 / 4,
+  BBR_UNIT, BBR_UNIT, BBR_UNIT,
+  BBR_UNIT, BBR_UNIT, BBR_UNIT
+};
+static const u32 bbr_cycle_rand = 7;  /* randomize gain cycling phase over N phases */
 
 /* Try to keep at least this many packets in flight, if things go smoothly. For
  * smooth functioning, a sliding window protocol ACKing every other packet
  * needs at least 4 packets in flight.
  */
-static u32 bbr_cwnd_min_target	= 4;
+static const u32 bbr_cwnd_min_target	= 4;
 
 /* To estimate if BBR_STARTUP mode (i.e. high_gain) has filled pipe. */
-static u32 bbr_full_bw_thresh = BBR_UNIT * 5 / 4;  /* bw up 1.25x per round? */
-static u32 bbr_full_bw_cnt    = 3;    /* N rounds w/o bw growth -> pipe full */
+static const u32 bbr_full_bw_thresh = BBR_UNIT * 5 / 4;  /* bw up 1.25x per round? */
+static const u32 bbr_full_bw_cnt    = 3;    /* N rounds w/o bw growth -> pipe full */
 
 /* "long-term" ("LT") bandwidth estimator parameters: */
-static bool bbr_lt_bw_estimator = true;	/* use the long-term bw estimate? */
-static u32 bbr_lt_intvl_min_rtts = 4;	/* min rounds in sampling interval */
-static u32 bbr_lt_loss_thresh = 50;	/*  lost/delivered > 20% -> "lossy" */
-static u32 bbr_lt_conv_thresh = BBR_UNIT / 8;  /* bw diff <= 12.5% -> "close" */
-static u32 bbr_lt_bw_max_rtts	= 48;	/* max # of round trips using lt_bw */
+static const u32 bbr_lt_intvl_min_rtts = 4;	/* min rounds in sampling interval */
+static const u32 bbr_lt_loss_thresh = 50;	/*  lost/delivered > 20% -> "lossy" */
+static const u32 bbr_lt_conv_thresh = BBR_UNIT / 8;  /* bw diff <= 12.5% -> "close" */
+static const u32 bbr_lt_bw_max_rtts	= 48;	/* max # of round trips using lt_bw */
 
 /* Do we estimate that STARTUP filled the pipe? */
 static bool bbr_full_bw_reached(const struct sock *sk)
@@ -470,8 +471,7 @@ static void bbr_lt_bw_interval_done(struct sock *sk, u32 bw)
 	struct bbr *bbr = inet_csk_ca(sk);
 	u32 diff;
 
-	if (bbr->lt_bw &&  /* do we have bw from a previous interval? */
-	    bbr_lt_bw_estimator) {  /* using long-term bw estimator enabled? */
+	if (bbr->lt_bw) { /* do we have bw from a previous interval? */
 		/* Is new bw close to the lt_bw from the previous interval? */
 		diff = abs(bw - bbr->lt_bw);
 		if ((diff * BBR_UNIT <= bbr_lt_conv_thresh * bbr->lt_bw) ||
