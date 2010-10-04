From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: pull-request: bluetooth-2.6 2010-09-27
Date: Mon, 4 Oct 2010 19:35:13 -0300
Message-ID: <20101004223513.GB3234@vigoh>
References: <20100928023035.GA3033@vigoh>
 <20100927.200016.226762808.davem@davemloft.net>
 <20100928224941.GA19409@vigoh>
 <20100930.172657.123994559.davem@davemloft.net>
 <20101001012203.GE3048@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, marcel@holtmann.org,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:55872 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab0JDWfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 18:35:19 -0400
Content-Disposition: inline
In-Reply-To: <20101001012203.GE3048@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

* Gustavo F. Padovan <padovan@profusion.mobi> [2010-09-30 22:22:03 -0300]:

> Hi Dave,
> 
> * David Miller <davem@davemloft.net> [2010-09-30 17:26:57 -0700]:
> 
> > From: "Gustavo F. Padovan" <padovan@profusion.mobi>
> > Date: Tue, 28 Sep 2010 19:49:41 -0300
> > 
> > > Actually sk_stream_wait_memory is another point why it's safe to release
> > > the lock and block waiting for memory. We've been doing that safely in
> > > protocols like TCP, SCTP and DCCP for a long time.
> > 
> > Do you notice what TCP does when sk_stream_wait_memory() returns?
> > 
> > It reloads all volatile state that might have changed in the socket
> > while the lock was dropped.
> > 
> > For example, TCP will reload the current MSS that can change
> > asynchronously while we don't have the socket lock.
> 
> I got your point. And what I tried to say in the last e-mail is that
> ERTM doesn't have such volatile states that need to restore after get
> the lock back. The others code path it affect are very simple and also
> doesn't have such problem. So we are safe against asynchronous changes.
> We obvious have volatiles states, but the code paths where
> bt_skb_send_alloc() is used doesn't rely on that states. I'm seeing no
> problem on release the lock, alloc memory, and lock it again.

I did a proper audit of the code paths:

sco_send_frame(): after bt_skb_send_alloc() returns the function doesn't
touch any sk state anymore, it just picks the skb and sends it to the
HCI.

l2cap_create_connless_pdu(): after bt_skb_send_alloc() returns the
function only reads l2cap_pi(sk)->dcid and l2cap_pi(sk)->psm, those
value are static and don't change with the connection alive

l2cap_create_connless_pdu(): after bt_skb_send_alloc() returns the
function only reads l2cap_pi(sk)->dcid, that value is static and doesn't
change with the connection alive.

l2cap_create_iframe_pdu(): after bt_skb_send_alloc() returns, we only 
reads l2cap_pi(sk)->dcid and l2cap_pi(sk)->fcs which doesn change with 
the connection alive, l2cap_create_iframe_pdu() returns the skb to 
l2cap_sar_segment_sdu(), which changes only the TX_QUEUE(sk), but it 
only appends in the end while the rest of the L2CAP code reads from 
the begin. After that we have the process of sending of ERTM and 
Streaming Mode, this process is independent from the skb alloc process,
so no problem here.

Other point already discussed are the check after get the lock again, 
they guarantee that the socket is still connected, otherwise returns 
error.

An extra check will be added to setsockopt() just to make sure that
l2cap_pi(sk)->fcs won't change while the sk_state is BT_CONNECTED. That
was an issue even before this backlog queue issue.

Follow the output of git show for that change, if we agree on the change I
can append it to the bluetooth pull request.


Author: Gustavo F. Padovan <padovan@profusion.mobi>
Date:   Mon Oct 4 19:28:52 2010 -0300

    Bluetooth: Disallow to change L2CAP_OPTIONS values when connected
    
    L2CAP doesn't permit change like MTU, FCS, TxWindow values while the
    connection is alive, we can only set that before the
    connection/configuration process. That can lead to bugs in the L2CAP
    operation.
    
    Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 44a8fb0..0b54b7d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1950,6 +1950,11 @@ static int l2cap_sock_setsockopt_old(struct socket *sock, int optname, char __us
 
        switch (optname) {
        case L2CAP_OPTIONS:
+               if (sk->sk_state == BT_CONNECTED) {
+                       err = -EINVAL;
+                       break;
+               }
+
                opts.imtu     = l2cap_pi(sk)->imtu;
                opts.omtu     = l2cap_pi(sk)->omtu;
                opts.flush_to = l2cap_pi(sk)->flush_to;


-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
