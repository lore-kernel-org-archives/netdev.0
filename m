From: Thomas Graf <tgr@reeler.org>
Subject: leak in netlink_dump()?
Date: Wed, 13 Nov 2002 20:53:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021113195334.GM27787@reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Used Kernel: 2.4.18 (same for 2.4.19pre6)

I think I've found a memory leak in netlink_dump (af_netlink.c):

the netlink callback (sk->protinfo.af_netlink->cb) is allocated
in the calling funtion netlink_dump_start and is not freed
after the call to netlink_dump.

    ...

    netlink_dump.len = cb->dump(skb, cb);

    len = cb->dump(skb, cb);

    if (len > 0) {
        spin_unlock(&sk->protinfo.af_netlink->cb_lock);
        skb_queue_tail(&sk->receive_queue, skb);
        sk->data_ready(sk, len);
        
        /*
         * Isn't a netlink_destroy_callback(cb) missing here?
         */

        return 0;
    }

    ...

    netlink_destroy_callback(cb);   /* cb gets freed here */
    sock_put(sk);
    return 0;
}


The only other call to netlink_destroy_callback is in
netlink_release which is called from sock_release which is
called if the socket gets closed.

>From my point of view, this is a memory leak, but I'm new to
kernel code and I might be telling shit.

-- 
Thomas GRAF
