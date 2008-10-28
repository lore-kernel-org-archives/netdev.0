From: "Oscar Norlander" <oscar.norlander@gmail.com>
Subject: [LINUX-KERNEL] ARP cache update suggestion
Date: Tue, 28 Oct 2008 08:42:39 +0100
Message-ID: <6f18dd1c0810280042u58a43fe3rcfdf0ec3e4699314@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:29388 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbYJ1Hmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 03:42:39 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2469390wfd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 00:42:39 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I'm not in the list so I wish to be personally CC'ed the
answers/comments posted to the list in response to my posting.

We have found a possible glitch in the ARP cache that seldom should
appear in the general case but give problematic consequences.

Let us start with the background. We have a system that do IP Address
Takeover with gratuitous ARP (Grat ARP) and during the test of this
function we sometimes fail to updated the ARP cache. Often we can make
around 20 to 80 IP Address Takeovers before we fail to update the ARP
cache. We wait approximately 2 minutes between every IP Address
Takeover. We have used a 2.6.24 kernel with a lot of kprints to locate
why we have this problem.

The exact scenario where the ARP cache is not updated is this:
Setup: Two servers where one is passive (waiting to be switched to)
and one is active (running traffic) and one test client machine (test
client) that communicate with the active server.
1. The test machine neighbor item times out and becomes NUD_STALE.
2. The test machine neighbor item becomes NUD_DELAY.
3. A time that is less than locktime goes by (less than 20 jiffies in our case)
4. The passive server becomes active and sends out 3 Grat ARPs with 50
milli seconds in between and all are refused (We have tested to send
Grat ARPs for 3 seconds with 50 milli seconds in between to see what
happens and that do not work either).

We believe that the cause of this is the following:
1. When NUD_DELAY is set the neighbour->updated counter is updated.
2. In arp.c arp_process(struct sk_buff *skb) we will receive the Grat
ARPs one at the time and compare the current jiffy value with
neighbour->updated + n->parms->locktime. If the current jiffy value is
within the lock time then neigh_update will be called without setting
the NEIGH_UPDATE_F_OVERRIDE flag and if the current jiffy value is
outside the locktime neigh_update will be called with
NEIGH_UPDATE_F_OVERRIDE flag set. In our case we will always during
these 3 seconds of Grat ARP sending enter neigh_update  without
NEIGH_UPDATE_F_OVERRIDE being set (which we think is strange and I
will explain that in the next bullet).
3. We will enter neigh_update in neigbour.c and for our Grat ARPs the
value of argument new will always be NUD_STALE (within NUD_VALID) and
the HW address will differ from what the neighbour item contain.
Because the state is NUD_VALID we will always update
neighbour->updated but because NEIGH_UPDATE_F_OVERRIDE is not set we
will never update the hardware address. Because neighbour->updated
moves we will never be able to set flag NEIGH_UPDATE_F_OVERRIDE after
the locktime should be over. The locktime time frame in arp_process
(arp.c) is where we compare the current jiffy value with
neighbour->updated + n->parms->locktime. Because the
neighbour->updated moves you could see the locktime time frame as a
moving time frame when it probably should be a more fixed time frame.
We belive that after NUD_DELAY is set, neighbour->updated should not
be changed in neigh_update until it is more probable that the state
and/or the HW address is updated.

Our workaround right now is to set the locktime to 0.

We propose that the increase of neighbour->updated in neigh_update is
done after it is known if NEIGH_UPDATE_F_OVERRIDE is set or not, but
before we do the update of the HW address. Here is a diff -c on the
proposed code:

>diff -c neighbour.c ./linux-2.6.24/net/core/neighbour.c
*** neighbour.c 2008-10-27 12:23:22.000000000 +0100
--- ./linux-2.6.24/net/core/neighbour.c 2008-01-24 23:58:37.000000000 +0100
***************
*** 988,993 ****
--- 988,994 ----

        if (new & NUD_CONNECTED)
                neigh->confirmed = jiffies;
+       neigh->updated = jiffies;

        /* If entry was valid and address is not changed,
           do not change entry state, if new one is STALE.
***************
*** 1012,1019 ****
                }
        }

-       neigh->updated = jiffies;
-
        if (new != old) {
                neigh_del_timer(neigh);
                if (new & NUD_IN_TIMER) {
--- 1013,1018 ----
LINUX scratch/tmp2>diff -c ./linux-2.6.24/net/core/neighbour.c neighbour.c
*** ./linux-2.6.24/net/core/neighbour.c 2008-01-24 23:58:37.000000000 +0100
--- neighbour.c 2008-10-27 12:23:22.000000000 +0100
***************
*** 988,994 ****

        if (new & NUD_CONNECTED)
                neigh->confirmed = jiffies;
-       neigh->updated = jiffies;

        /* If entry was valid and address is not changed,
           do not change entry state, if new one is STALE.
--- 988,993 ----
***************
*** 1013,1018 ****
--- 1012,1019 ----
                }
        }

+       neigh->updated = jiffies;
+
        if (new != old) {
                neigh_del_timer(neigh);
                if (new & NUD_IN_TIMER) {


Here is some code in neighbour.c neigh_update that contains the changes:

/* Compare new lladdr with cached one */
if (!dev->addr_len) {
        /* First case: device needs no address. */
        lladdr = neigh->ha;
} else if (lladdr) {
        /* The second case: if something is already cached
           and a new address is proposed:
           - compare new & old
           - if they are different, check override flag
         */
        if ((old & NUD_VALID) &&
            !memcmp(lladdr, neigh->ha, dev->addr_len))
                lladdr = neigh->ha;
} else {
        /* No address is supplied; if we know something,
           use it, otherwise discard the request.
         */
        err = -EINVAL;
        if (!(old & NUD_VALID))
                goto out;
        lladdr = neigh->ha;
}


if (new & NUD_CONNECTED)
       neigh->confirmed = jiffies;

/* If entry was valid and address is not changed,
   do not change entry state, if new one is STALE.
 */
err = 0;
update_isrouter = flags & NEIGH_UPDATE_F_OVERRIDE_ISROUTER;
if (old & NUD_VALID) {
        if (lladdr != neigh->ha && !(flags & NEIGH_UPDATE_F_OVERRIDE)) {
                update_isrouter = 0;
                if ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) &&
                    (old & NUD_CONNECTED)) {
                        lladdr = neigh->ha;
                        new = NUD_STALE;
                } else
                        goto out;
        } else {
                if (lladdr == neigh->ha && new == NUD_STALE &&
                    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
                     (old & NUD_CONNECTED))
                    )
                        new = old;
        }
}

neigh->updated = jiffies;

if (new != old) {
        neigh_del_timer(neigh);
        if (new & NUD_IN_TIMER) {
                neigh_hold(neigh);
                neigh_add_timer(neigh, (jiffies +
                                        ((new & NUD_REACHABLE) ?
                                         neigh->parms->reachable_time :
                                         0)));
        }
        neigh->nud_state = new;
}

I suppose that the solution could be more unforgiving so that the
jiffies update is only done when we really know that we will update
the state and/or HW address. Then the new code would look something
like this:

}

if (new != old) {
        neigh_del_timer(neigh);
        if (new & NUD_IN_TIMER) {
                neigh_hold(neigh);
                neigh_add_timer(neigh, (jiffies +
                                        ((new & NUD_REACHABLE) ?
                                         neigh->parms->reachable_time :
                                         0)));
                       printk("nu 12\n");
        }
        neigh->nud_state = new;

        //New code
        if (lladdr != neigh->ha)
                neigh->updated = jiffies;
}

if (lladdr != neigh->ha) {
        memcpy(&neigh->ha, lladdr, dev->addr_len);
        neigh_update_hhs(neigh);
        if (!(new & NUD_CONNECTED))
                neigh->confirmed = jiffies -
                              (neigh->parms->base_reachable_time << 1);
        notify = 1;

        //New code
        neigh->updated = jiffies;
}


Best regards
Oscar Norlander
