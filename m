From: Ben Greear <greearb@candelatech.com>
Subject: Re: packet re-ordering on SMP machines.
Date: Sun, 25 Aug 2002 11:32:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D6922B2.1020400@candelatech.com>
References: <Pine.GSO.4.30.0208251149320.29461-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jamal wrote:
> 
> 
> 
> NAPI fixes packet reordering problems.

It does indeed.  I just patched the e1000 with the latest NAPI patch
I could find (from Aug 15 or so), and the re-ordering problems went away.

The amount of packets dropped decreased too, but I still see about 1 out of
1000 packets dropped due to rx-FIFO or rx-dropped.  This is when trying to run
60,000 pps of 1514 byte packets from one port to the other on the same dual-port e1000
NIC (copper).  It will generate up to about 72,000 pps without dropping too many
more...

I will do some more tests on two single-port NICs soon to see if that
performs better.

Also, I see the hard_start_xmit call failing 5876 times out of 2719493
calls (for example).  The code that calls the method looks like this:

                         spin_lock_bh(&odev->xmit_lock);
                         if (!netif_queue_stopped(odev)) {
                                 if (odev->hard_start_xmit(next->skb, odev)) {
                                         if (net_ratelimit()) {
                                                 printk(KERN_INFO "Hard xmit error\n");
                                         }
                                         next->errors++;
                                         next->last_ok = 0;
                                 }
                                 else {
                                         next->last_ok = 1;
                                         next->sofar++;
                                         next->tx_bytes += (next->cur_pkt_size + 4); /* count csum */
                                 }

                                 next->next_tx_ns = getRelativeCurNs() + next->ipg;
                         }
                         else {  /* Re-try it next time */
                                 next->last_ok = 0;
                         }

                         spin_unlock_bh(&odev->xmit_lock);

I have not seen hard_start_xmit fail on other drivers, even when over-driving them
well beyond their capabilities.  Any ideas what causes the hard_start_xmit errors?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
