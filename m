From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Possible bug in net/core/neighbor.c
Date: Wed, 5 Nov 2014 11:46:02 +0100
Message-ID: <5459FFEA.3000101@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:56982 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbaKEKqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 05:46:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find the following in "net/core/neighbor.c"

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

         /* POSSIBLE BUG */
         if ((old & NUD_VALID) &&
             !memcmp(lladdr, neigh->ha, dev->addr_len))
             lladdr = neigh->ha;
         /* END POSSIBLE BUG */
     } else {
         /* No address is supplied; if we know something,
            use it, otherwise discard the request.
          */
         err = -EINVAL;
         if (!(old & NUD_VALID))
             goto out;
         lladdr = neigh->ha;
     }

     It looks to me like the code is saying
         if the proposed address is equal to the original address,
             set the proposed address  to the original address.

     which is pretty meaningless.

     Should it not be:

         if ((old & NUD_VALID) &&
             memcmp(lladdr, neigh->ha, dev->addr_len))    /* True if 
addresses are not equal */
             neigh->ha = lladdr;             /* Update to new address */

     If not, I would appreciate an explanation what the code is doing.

-- 
Best Regards,
Ulf Samuelsson
