From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net 1/2] RDS:TCP: Synchronize rds_tcp_accept_one with
 rds_send_xmit when resetting t_sock
Date: Mon, 2 May 2016 12:37:15 -0400
Message-ID: <20160502163715.GD20517@oracle.com>
References: <cover.1462127059.git.sowmini.varadhan@oracle.com>
 <470ac585d014a6d8ea1600b8897bdc313e7c2431.1462127059.git.sowmini.varadhan@oracle.com>
 <7fac68dc-0ff5-36a5-6a3d-df802d8db82d@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	davem@davemloft.net
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47487 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbcEBQhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:37:21 -0400
Content-Disposition: inline
In-Reply-To: <7fac68dc-0ff5-36a5-6a3d-df802d8db82d@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/02/16 09:20), Santosh Shilimkar wrote:
> > 	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
> >+	if (rs_tcp->t_sock) {
> >+		/* Need to resolve a duelling SYN between peers.
> >+		 * We have an outstanding SYN to this peer, which may
> >+		 * potentially have transitioned to the RDS_CONN_UP state,
> >+		 * so we must quiesce any send threads before resetting
> >+		 * c_transport_data.
> >+		 */
> >+		wait_event(conn->c_waitq,
> >+			   !test_bit(RDS_IN_XMIT, &conn->c_flags));
> Would it be good to check the return value of rds_conn_transition()
> since if CONN is already UP above will fail and then send message
> might again race and we will let message through even though passive
> hasn't finished its connection.

no, that was the original issue that I was running into, which needed
commit 241b2719 - prior to that commit, if the conn was already UP,
we'd end up doing a rds_conn_drop on a good connection, and both sides
would end up in a pair of infinite 3WH loops. Even if we dont do
a rds_conn_drop on the UP connection, we've just (before
rds_tcp_accept_one) sent out a syn-ack on the incoming syn, and now
need to RST that syn-ac.  The other side is going to receive the rst,
and get confused about what to clean up (since there's already an UP
connection going on).

In short, when there is a duel, it's cleanest to have a deterministic
arbitration- both sides use the numeric value of saddr and faddr to 
figure out which side is active, which side is passive. (Thus the
basis on the BGP router-id based model for 241b2719)

FWIW, much of this is actually a corner case-  in practice, its not
frequent to have syns crossing each other at "almost the same time".

--Sowmini
