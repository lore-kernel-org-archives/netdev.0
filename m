From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: pull-request: bluetooth-2.6 2010-09-27
Date: Tue, 28 Sep 2010 19:49:41 -0300
Message-ID: <20100928224941.GA19409@vigoh>
References: <20100928023035.GA3033@vigoh>
 <20100927.200016.226762808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100927.200016.226762808.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> [2010-09-27 20:00:16 -0700]:

> From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> Date: Mon, 27 Sep 2010 23:30:35 -0300
> 
> > And a fix for a deadlock issue between the sk_sndbuf and the backlog
> > queue in ERTM. The rest are also needed bug fixes.
> 
> This fix is still under discussion.
> 
> That change effects quite a few code paths.  And when I looked
> at them, I was not at all convinced that dropping the socket
> lock like that is safe.
> 
> Are you sure there are no pieces of socket or socket related state
> that might change under us while we drop that lock, which would thus
> make the operation suddenly invalid or cause a state corruption or
> crash?

We can group all the code paths in only two different code paths. One
wirh SCO, L2CAP Basic Mode and L2CAP Streaming Mode once they are very
similar and other for ERTM, a more complicated protocol.
For the first group the only bottom half action we have are incoming data,
which doesn't affect the sk states, and disconnection request, that can
change the sk states. We guarantee that this won't affect by checking the
sk_err after get the lock again. Looking to the code again we might
also want to check the sk->sk_shutdown value like TCP does inside
sk_stream_wait_memory().

Actually sk_stream_wait_memory is another point why it's safe to release
the lock and block waiting for memory. We've been doing that safely in
protocols like TCP, SCTP and DCCP for a long time.

Back to patch, the other code path it affects is the ERTM one, besides
the incoming data we have other bottom halves actions, but in the end the
only action that can affect ERTM flow is closing the channeli, but we are
prepared for that by checking the sk->sk_err and sk->sk_shutdown when we
get the lock back.


---

Bluetooth: Fix deadlock in the ERTM logic

The Enhanced Retransmission Mode(ERTM) is a realiable mode of operation
of the Bluetooth L2CAP layer. Think on it like a simplified version of
TCP.
The problem we were facing here was a deadlock. ERTM uses a backlog
queue to queue incomimg packets while the user is helding the lock. At
some moment the sk_sndbuf can be exceeded and we can't alloc new skbs
then the code sleep with the lock to wait for memory, that stalls the
ERTM connection once we can't read the acknowledgements packets in the
backlog queue to free memory and make the allocation of outcoming skb
successful.

This patch actually affect all users of bt_skb_send_alloc(), i.e., all
L2CAP modes and SCO.

We are safe against socket states changes or channels deletion while the
we are sleeping wait memory. Checking for the sk->sk_err and
sk->sk_shutdown make the code safe, since any action that can leave the
socket or the channel in a not usable state set one of the struct
members at least. Then we can check both of them when getting the lock
again and return with the proper error if something unexpected happens.

Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Signed-off-by: Ulisses Furquim <ulisses-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
---
 include/net/bluetooth/bluetooth.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 27a902d..e8d64ba 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -161,12 +161,30 @@ static inline struct sk_buff *bt_skb_send_alloc(struct sock *sk, unsigned long l
 {
        struct sk_buff *skb;
 
+       release_sock(sk);
        if ((skb = sock_alloc_send_skb(sk, len + BT_SKB_RESERVE, nb, err))) {
                skb_reserve(skb, BT_SKB_RESERVE);
                bt_cb(skb)->incoming  = 0;
        }
+       lock_sock(sk);
+
+       if (!skb && *err)
+               return NULL;
+
+       *err = sock_error(sk);
+       if (*err)
+               goto out;
+
+       if (sk->sk_shutdown) {
+               *err = ECONNRESET;
+               goto out;
+       }
 
        return skb;
+
+out:
+       kfree_skb(skb);
+       return NULL;
 }
 
 int bt_err(__u16 code);
-- 
1.7.3


-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
