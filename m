From: Ben Greear <greearb@candelatech.com>
Subject: Re: e100 "Ferguson" release
Date: Sun, 03 Aug 2003 00:32:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2CBA71.2070503@candelatech.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com> <3F2CA65F.8060105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2CA65F.8060105@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Comments:

> * (API) Does the out-of-tx-resources condition in e100_xmit_frame ever 
> really happen?  I am under the impression that returning non-zero in 
> ->hard_start_xmit results in the packet sometimes being requeued and 
> sometimes dropped.  I prefer to guarantee a more-steady state, by simply 
> dropping the packet unconditionally, when this uncommon condition 
> occurs.  So, I would
> a) mark the failure condition with unlikely(), and
> b) if the condition occurs, simply drop the packet (tx_dropped++, kfree 
> skb), and return zero.
> 
> Though, ultimately, I wish the net stack would support some way to 
> _guarantee_ that the skb is requeued for transmit.  Some packet 
> schedulers in the kernel will drop the skb even if the ->hard_start_xmit 
> return code indicates "requeue".  This makes sense from the rule of 
> "skbs are lossy, and can be dropped"... but it really sucks on hardware 
> where unexpected -- but temporary -- loss of TX resources occurs.  One 
> can prevent 20-50% (or more) packet loss on certain classes of 
> connections, simply by being able to tell the net stack "hey, if I could 
> go back in time and issue a netif_stop_queue, before you called 
> ->hard_start_xmit, I would" :)

Although I have not tried this latest patch, the existing e100 and e1000 in
2.4.21 seldom seem to return true to this method:  netif_queue_stopped(odev),
even when the next hard_start_xmit() call fails.  For instance, this is the
code I use in pktgen.c:

                         if (!netif_queue_stopped(odev)) {
                                 if (odev->hard_start_xmit(next->skb, odev)) {
                                         if (net_ratelimit()) {
                                                 printk(KERN_INFO "Hard xmit error\n");
                                         }
                                         next->errors++;
                                         next->last_ok = 0;
                                         queue_stopped++;
                                 }
                                 else {
                                         queue_stopped = 0;
                                         next->last_ok = 1;
                                         next->sofar++;
                                         next->tx_bytes += (next->cur_pkt_size + 4); /* count csum */
                                 }

With e100 and e1000, I see the very large numbers of the hard_start_xmit failure
when running very high packets-per-second rates (small packets).
I see virtually no failures with tulip.  pktgen knows how to re-queue, but it's
curious it has to so often.  For code that does not requeue, this could be even
more of a bummer.

To point b), I think if the driver accepts the packet in hard_start_xmit, it should
be able to send the packet out, otherwise return the 'requeue' value and let the
calling code know.  It is very important to me, at least, to know if a packet has
really been sent or not.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
