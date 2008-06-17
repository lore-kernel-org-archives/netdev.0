From: Tihomir Heidelberg - 9a4gl <9a4gl@hamradio.hr>
Subject: Re: [PATCH]: Consolidate ax25 socket grafting.
Date: Tue, 17 Jun 2008 14:11:36 +0200
Message-ID: <4857A9F8.7040208@hamradio.hr>
References: <20080617.023201.14122891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ralf@linux-mips.org
To: linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:53043 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbYFQMLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 08:11:46 -0400
Received: by ug-out-1314.google.com with SMTP id h2so555322ugf.16
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 05:11:42 -0700 (PDT)
In-Reply-To: <20080617.023201.14122891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi linux-hams,

David Miller wrote:
> The way that listening sockets work in ax25 is that the packet input
> code path creates new socks via ax25_make_new() and attaches them
> to the incoming SKB.  This SKB gets queued up into the listening
> socket's receive queue.
>
> When accept()'d the sock gets hooked up to the real parent socket.
> Alternatively, if the listening socket is closed and released, any
> unborn socks stuff up in the receive queue get released.
>
> So during this time period these sockets are unreachable in any
> other way, so no wakeup events nor references to their ->sk_socket
> and ->sk_sleep members can occur.  And even if they do, all such
> paths have to make NULL checks.
>   
Yes, but...

I would like to direct you attention to one problem existing in ax.25 
kernel since 2.4. If listening socket is closed and its SKB queue is 
released but those sockets get weird. Those "unAccepted()" sockets 
should be destroyed in ax25_std_heartbeat_expiry, but it will not 
happen. And there is also a note about that in ax25_std_timer.c:
/* Magic here: If we listen() and a new link dies before it
is accepted() it isn't 'dead' so doesn't get removed. */

This issue cause ax25d to stop accepting new connections and I had to 
restarted ax25d approximately each day and my services were unavailable. 
Also netstat -n -l shows invalid source and device for those listening 
sockets. It is strange why ax25d's listening socket get weird because of 
this issue, but definitely when I solved this bug I do not have problems 
with ax25d anymore and my ax25d can run for months without problems.

Actually I didn't fix the bug, I made a hack. In af_ax25.c file, 
function ax25_destroy_socket in while loop:
        if (ax25->sk != NULL) {
                while ((skb = skb_dequeue(&ax25->sk->sk_receive_queue)) 
!= NULL
                        if (skb->sk != ax25->sk) {
                                /* A pending connection */
                                ax25_cb *sax25 = ax25_sk(skb->sk);

                                /* Queue the unaccepted socket for death */
                                sock_orphan(skb->sk);

+                                /* 9A4GL: hack to release unaccepted 
sockets */
+                                skb->sk->sk_state = TCP_LISTEN;

                                ax25_start_heartbeat(sax25);
                                sax25->state = AX25_STATE_0;
                        }

                        kfree_skb(skb);
                }
                skb_queue_purge(&ax25->sk->sk_write_queue);
        }

73 de Tihomir, 9a4gl

