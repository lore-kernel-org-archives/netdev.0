From: Lawrence Stewart <lstewart@room52.net>
Subject: Re: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Mon, 10 Nov 2008 14:56:25 +1100
Message-ID: <4917B0E9.2030304@room52.net>
References: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000805060604090206070902"
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Lachlan Andrew <lachlan.andrew@gmail.com>,
	grenville armitage <garmitage@swin.edu.au>
To: Douglas Leith <Doug.Leith@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lauren.room52.net ([210.50.193.198]:62062 "EHLO
	lauren.room52.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbYKJEJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 23:09:40 -0500
In-Reply-To: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000805060604090206070902
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

Hi Doug,

Thanks very much for looking at this.

My familiarity with the Linux TCP stack is not up to scratch as you 
know. I'm curious about the "if (ca->undo_last_cong)" condition you 
added to htcp_cwnd_undo(). Is there a possibility of the stack calling 
into this function multiple times without at least one congestion 
control related state change in between?

I will test your patch and confirm it resolves the issue we reported.

Also, while we're at it, any chance you might consider adding the 
functionality in the attached patch so that we can control adaptive 
backoff via a module tunable?

Cheers,
Lawrence



Douglas Leith wrote:
> This patch fixes a minor bug in tcp_htcp.c which has been highlighted by 
> Lachlan Andrew and Lawrence Stewart.   Currently, the time since the 
> last congestion event, which is stored in variable last_cong, is reset 
> whenever there is a state change into TCP_CA_Open.  This includes 
> transitions of the type TCP_CA_Open->TCP_CA_Disorder->TCP_CA_Open which 
> are not associated with backoff of cwnd.  The patch changes last_cong to 
> be updated only on transitions into TCP_CA_Open that occur after 
> experiencing the congestion-related states TCP_CA_Loss, TCP_CA_Recovery, 
> TCP_CA_CWR.
> 
> Doug
> 
> --- tcp_htcp.c   2008-11-05 15:50:18.000000000 +0000
> +++ tcp_htcp.c.new       2008-11-08 07:11:18.000000000 +0000
> @@ -69,9 +69,12 @@
>         const struct tcp_sock *tp = tcp_sk(sk);
>         struct htcp *ca = inet_csk_ca(sk);
> 
> -       ca->last_cong = ca->undo_last_cong;
> -       ca->maxRTT = ca->undo_maxRTT;
> -       ca->old_maxB = ca->undo_old_maxB;
> +       if (ca->undo_last_cong) {
> +               ca->last_cong = ca->undo_last_cong;
> +               ca->maxRTT = ca->undo_maxRTT;
> +               ca->old_maxB = ca->undo_old_maxB;
> +               ca->undo_last_cong=0; // flag that ca->last_cong is not 
> to be reset when enter TCP_CA_Open state
> +       }
> 
>         return max(tp->snd_cwnd, (tp->snd_ssthresh << 7) / ca->beta);
>  }
> @@ -265,12 +268,15 @@
>  static void htcp_state(struct sock *sk, u8 new_state)
>  {
>         switch (new_state) {
> -       case TCP_CA_Open:
> +       case TCP_CA_Open:
>                 {
>                         struct htcp *ca = inet_csk_ca(sk);
> -                       ca->last_cong = jiffies;
> +                       if (ca->undo_last_cong) {
> +                               ca->last_cong=jiffies;
> +                               ca->undo_last_cong=0;
> +                       }
>                 }
> -               break;
> +               break;
>         case TCP_CA_CWR:
>         case TCP_CA_Recovery:
>         case TCP_CA_Loss:
> 
> 


--------------000805060604090206070902
Content-Type: text/plain;
 name="switch_adaptive_backoff.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="switch_adaptive_backoff.patch"

--- /usr/src/linux-source-2.6.25/net/ipv4/tcp_htcp.c	2008-04-17 12:49:44.000000000 +1000
+++ tcp_htcp.c	2008-10-24 17:02:27.000000000 +1100
@@ -22,6 +22,10 @@
 module_param(use_bandwidth_switch, int, 0644);
 MODULE_PARM_DESC(use_bandwidth_switch, "turn on/off bandwidth switcher");
 
+static int use_adaptive_backoff __read_mostly = 1;
+module_param(use_adaptive_backoff, int, 0644);
+MODULE_PARM_DESC(use_adaptive_backoff, "turn on/off adaptive backoff");
+
 struct htcp {
 	u32	alpha;		/* Fixed point arith, << 7 */
 	u8	beta;           /* Fixed point arith, << 7 */
@@ -155,7 +159,7 @@
 		}
 	}
 
-	if (ca->modeswitch && minRTT > msecs_to_jiffies(10) && maxRTT) {
+	if (use_adaptive_backoff && ca->modeswitch && minRTT > msecs_to_jiffies(10) && maxRTT) {
 		ca->beta = (minRTT << 7) / maxRTT;
 		if (ca->beta < BETA_MIN)
 			ca->beta = BETA_MIN;

--------------000805060604090206070902--
