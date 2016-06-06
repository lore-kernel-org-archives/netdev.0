From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net 3/3] RDS: TCP: fix race windows in send-path
 quiescence by rds_tcp_accept_one()
Date: Mon, 6 Jun 2016 12:20:28 -0700
Message-ID: <8ec8cf1b-2b08-82d2-f39f-b4c26e822918@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
 <b5c21c0947c123c6a7812bb1e3547d7f445fdc43.1465071319.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30280 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbcFFTUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 15:20:37 -0400
In-Reply-To: <b5c21c0947c123c6a7812bb1e3547d7f445fdc43.1465071319.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/2016 2:00 PM, Sowmini Varadhan wrote:
> The send path needs to be quiesced before resetting callbacks from
> rds_tcp_accept_one(), and commit eb192840266f ("RDS:TCP: Synchronize
> rds_tcp_accept_one with rds_send_xmit when resetting t_sock") achieves
> this using the c_state and RDS_IN_XMIT bit following the pattern
> used by rds_conn_shutdown(). However this leaves the possibility
> of a race window as shown in the sequence below
>     take t_conn_lock in rds_tcp_conn_connect
>     send outgoing syn to peer
>     drop t_conn_lock in rds_tcp_conn_connect
>     incoming from peer triggers rds_tcp_accept_one, conn is
> 	marked CONNECTING
>     wait for RDS_IN_XMIT to quiesce any rds_send_xmit threads
>     call rds_tcp_reset_callbacks
>     [.. race-window where incoming syn-ack can cause the conn
> 	to be marked UP from rds_tcp_state_change ..]
>     lock_sock called from rds_tcp_reset_callbacks, and we set
> 	t_sock to null
> As soon as the conn is marked UP in the race-window above, rds_send_xmit()
> threads will proceed to rds_tcp_xmit and may encounter a null-pointer
> deref on the t_sock.
>
> Given that rds_tcp_state_change() is invoked in softirq context, whereas
> rds_tcp_reset_callbacks() is in workq context, and testing for RDS_IN_XMIT
> after lock_sock could result in a deadlock with tcp_sendmsg, this
> commit fixes the race by using a new c_state, RDS_TCP_RESETTING, which
> will prevent a transition to RDS_CONN_UP from rds_tcp_state_change().
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
As we discussed off-list, for immediate fix, this patch is fine.
Dual sync/ack issue we have 'is_outgoing' and now 'RDS_TCP_RESETTING'
so will be good to address that later.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
