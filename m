From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: Deadlock in Bluetooth code in 2.6.36
Date: Sat, 25 Sep 2010 21:14:48 -0300
Message-ID: <20100926001448.GA2979@vigoh>
References: <1285104013-9946-1-git-send-email-padovan@profusion.mobi>
 <20100924.211824.242130957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	mathewm-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100924.211824.242130957.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> [2010-09-24 21:18:24 -0700]:

> From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> Date: Tue, 21 Sep 2010 18:20:12 -0300
> 
> > My questions here is on how to fix this properly. Maybe
> > sock_alloc_send_skb() should not be used with SOCK_STREAM and reliable
> > protocols and I'm not aware of that? And should I use something like
> > sk_stream_alloc_skb() instead?
> > 
> > Any comments are welcome. With lucky we can fix that for 2.6.36 and
> > together with others fixes we have queued deliver a fully functional
> > L2CAP layer on 2.6.36.
> 
> Use sock_alloc_send_skb() as you do now, but if it fails wait for socket
> space to become available just like TCP does, then loop back and try to
> allocate again if the space-wait doesn't return an error.

sock_alloc_send_skb() doesn't fail when there is no space available
it sleeps and try again later. That is the problem. So if
sock_alloc_send_skb() is called with the socket lock held potentially we
can have a starvation in the backlog queue and then the deadlock due to
be unable to read the acknowledgments packets residing in the backlog
queue.

Our current solution is release the lock before call
sock_alloc_send_skb() and acquire it again when sock_alloc_send_skb()
returns. Patch follows:

------
Bluetooth: Fix deadlock in the ERTM logic                        
                                                                                      
The Enhanced Retransmission Mode(ERTM) is a reliable mode of operation               
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

Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Signed-off-by: Ulisses Furquim <ulisses-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
---
 include/net/bluetooth/bluetooth.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 27a902d..118b69b 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -161,10 +161,21 @@ static inline struct sk_buff *bt_skb_send_alloc(struct sock *sk, unsigned long l
 {
        struct sk_buff *skb;
 
+       release_sock(sk);
        if ((skb = sock_alloc_send_skb(sk, len + BT_SKB_RESERVE, nb, err))) {
                skb_reserve(skb, BT_SKB_RESERVE);
                bt_cb(skb)->incoming  = 0;
        }
+       lock_sock(sk);
+
+       if (*err)
+               return NULL;
+
+       *err = sock_error(sk);
+       if (*err) {
+               kfree_skb(skb);
+               return NULL;
+       }
 
        return skb;
 }
-- 
1.7.2.2

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
