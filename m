From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 100% CPU load when generating traffic to destination network
 that nexthop is not reachable
Date: Tue, 15 Aug 2017 12:11:00 -0700
Message-ID: <1502824260.4936.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
         <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>
         <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38470 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752247AbdHOTLD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 15:11:03 -0400
Received: by mail-pg0-f68.google.com with SMTP id 123so2726144pga.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 12:11:03 -0700 (PDT)
In-Reply-To: <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 19:42 +0200, Paweł Staszewski wrote:
> # To display the perf.data header info, please use 
> --header/--header-only options.
> #
> #
> # Total Lost Samples: 0
> #
> # Samples: 2M of event 'cycles'
> # Event count (approx.): 1585571545969
> #
> # Children      Self  Command         Shared Object         Symbol
> # ........  ........  ..............  .................... 
> ..............................................
> #
>       1.82%     0.00%  ksoftirqd/43    [kernel.vmlinux]      [k] 
> __softirqentry_text_start
>              |
>               --1.82%--__softirqentry_text_start
>                         |
>                          --1.82%--net_rx_action
>                                    |
>                                     --1.82%--mlx5e_napi_poll
>                                               |
> --1.81%--mlx5e_poll_rx_cq
>                                                          |
> --1.81%--mlx5e_handle_rx_cqe
>                                                                     |
> --1.79%--napi_gro_receive
> |
> --1.78%--netif_receive_skb_internal
> |
> --1.78%--__netif_receive_skb
> |
> --1.78%--__netif_receive_skb_core
> |
> --1.78%--ip_rcv
> |
> --1.78%--ip_rcv_finish
> |
> --1.76%--ip_forward
> |
> --1.76%--ip_forward_finish
> |
> --1.76%--ip_output
> |
> --1.76%--ip_finish_output
> |
> --1.76%--ip_finish_output2
> |
> --1.73%--neigh_resolve_output
> |
> --1.73%--neigh_event_send
> |
> --1.73%--__neigh_event_send
> |
> --1.70%--_raw_write_lock_bh
> queued_write_lock
> queued_write_lock_slowpath
> |
> --1.67%--queued_spin_lock_slowpath
> 
> 

Please try this :
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 16a1a4c4eb57fa1147f230916e2e62e18ef89562..95e0d7702029b583de8229e3c3eb923f6395b072 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -991,14 +991,18 @@ static void neigh_timer_handler(unsigned long arg)
 
 int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
-	int rc;
 	bool immediate_probe = false;
+	int rc;
+
+	/* We _should_ test this under write_lock_bh(&neigh->lock),
+	 * but this is too costly.
+	 */
+	if (READ_ONCE(neigh->nud_state) & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
+		return 0;
 
 	write_lock_bh(&neigh->lock);
 
 	rc = 0;
-	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
-		goto out_unlock_bh;
 	if (neigh->dead)
 		goto out_dead;
 
