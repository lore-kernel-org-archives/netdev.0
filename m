From: Minho Ban <mhban@samsung.com>
Subject: Re: [RFC/PATCH] Bluetooth: prevent double l2cap_chan_destroy
Date: Tue, 22 May 2012 11:50:29 +0900
Message-ID: <4FBAFEF5.2000207@samsung.com>
References: <4FB992C8.8090105@samsung.com> <20120521162137.GE16942@joana>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Gustavo Padovan <gustavo@padovan.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20120521162137.GE16942@joana>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2012 01:21 AM, Gustavo Padovan wrote:
> Hi Minho,
> 
> * Minho Ban <mhban@samsung.com> [2012-05-21 09:56:40 +0900]:
> 
>> l2cap_sock_kill can be called in l2cap_sock_release and l2cap_sock_close_cb
>> either. This lead l2cap_chan_destroy to be called twice for same channel.
>> To prevent double list_del and double chan_put, chan_destroy should be protected
>> with chan->refcnt and chan_list_lock so that reentrance could be forbidden.
> 
> Even if l2cap_sock_kill() is called twice it will call l2cap_chan_destroy()
> only once. If this is not happening we just have a broken piece of code
> somewhere else and not here.
> 
> 	Gustavo
> 

Thanks for comment but I could not found any suitable code in l2cap_sock_kill that 
can make l2cap_chan_destroy to be called just once. sock flag test is not enough to 
do it.

I agree this path should not be the fix. Testing chan->refcnt is nonsense because 
chan might have been freed already. So I looked for another point,

@@ -1343,10 +1343,10 @@ static void l2cap_conn_del(struct hci_conn *hcon, int err)
                l2cap_chan_lock(chan);
 
                l2cap_chan_del(chan, err);
+               chan->ops->close(chan->data);
 
                l2cap_chan_unlock(chan);
 
-               chan->ops->close(chan->data);
                l2cap_chan_put(chan);
        }

close callback must locate within chan_lock unless it can be scheduled to other thread 
which may wait for chan_lock in l2cap_sock_shutdown and this lead to duplicate sock_kill.

 static void l2cap_sock_kill(struct sock *sk)
 {
-       if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
+       if (!sock_flag(sk, SOCK_ZAPPED) || sock_flag(sk, SOCK_DEAD) ||
+                       sk->sk_socket)
                return;
 
        BT_DBG("sk %p state %s", sk, state_to_string(sk->sk_state));

Duplicate sock_kill may happen anyway, need test SOCK_DEAD if chan_destroy is already called.

Regards,
Minho Ban
