From: Jeff Moyer <jmoyer@redhat.com>
Subject: netpoll and the bonding driver
Date: Fri, 17 Jun 2005 15:56:35 -0400
Message-ID: <17075.10995.498758.773092__38688.057420268$1119038047$gmane$org@segfault.boston.redhat.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mpm@selenic.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm trying to implement a netpoll hook for the bonding driver.  In doing
so, I ran into the following problem:

netpoll_send_skb calls the device's hard_start_xmit routine.  In this case,
it will be one of the bonding driver's xmit routines.  Each of these ends
up calling bond_dev_queue_xmit, which in turn calls dev_queue_xmit.

Now, for netconsole, the code disables interrupts before calling
netpoll_send_udp:

        local_irq_save(flags);

        for(left = len; left; ) {
                frag = min(left, MAX_PRINT_CHUNK);
                netpoll_send_udp(&np, msg, frag);
                msg += frag;
                left -= frag;
        }

        local_irq_restore(flags);

Note that if you did an alt-sysrq-t, then you would enter this code path in
interrupt context as well, and herein lies the problem.  It seems that
dev_queue_xmit is not supposed to be called with interrupts disabled.  The
immediate affect of this is that the WARN_ON in local_bh_enable triggers
(called at the end of dev_queue_xmit), causing us to loop infinitely
printing out stack traces.

So, my question is this: how in the world do we fit the bonding driver into
the generic netpoll infrastructure?  In the case of every other driver,
netpoll simply calls the hard_start_xmit routine[1], and this approach
simply doesn't work for the bonding driver, for the reasons I described
above.  So, one way to make the bonding driver fit into this model is to
modify it to not call dev_queue_xmit when called from netpoll.  This can be
done, I suppose, by adding another start_xmit routine that is specific to
netpoll.  This doesn't feel good to me, but I'm not sure how else you would
solve the problem (and netpoll already gets its own poll interface, so is
one more all that bad?).  The other approach to take is to put bonding
specific logic into netpoll.  I think we can all agree that is a bad idea.

-Jeff

[1] Note that netpoll does not perform any of the checks that dev_queue_xmit
    does.  This either means that a) in the netpoll case, this is an okay
    thing to do (since it's been working for this long), or b) netpoll has a 
    bug.
