From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5 net-next] inet: kill smallest_size and smallest_port
Date: Wed, 21 Dec 2016 11:29:04 -0800
Message-ID: <1482348544.8944.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
         <1482264424-15439-3-git-send-email-jbacik@fb.com>
         <20161221.133003.1401543777326711002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jbacik@fb.com, hannes@stressinduktion.org, kraigatgoog@gmail.com,
        tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34400 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763472AbcLUT3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 14:29:21 -0500
Received: by mail-pg0-f68.google.com with SMTP id b1so17281512pgc.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 11:29:21 -0800 (PST)
In-Reply-To: <20161221.133003.1401543777326711002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-21 at 13:30 -0500, David Miller wrote:
> From: Josef Bacik <jbacik@fb.com>
> Date: Tue, 20 Dec 2016 15:07:01 -0500
> 
> > In inet_csk_get_port we seem to be using smallest_port to figure out where the
> > best place to look for a SO_REUSEPORT sk that matches with an existing set of
> > SO_REUSEPORT's.  However if we get to the logic
> > 
> > if (smallest_size != -1) {
> > 	port = smallest_port;
> > 	goto have_port;
> > }
> > 
> > we will do a useless search, because we would have already done the
> > inet_csk_bind_conflict for that port and it would have returned 1, otherwise we
> > would have gone to found_tb and succeeded.  Since this logic makes us do yet
> > another trip through inet_csk_bind_conflict for a port we know won't work just
> > delete this code and save us the time.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> 
> So the "all else being equal, use 'tb' with smallest socket count" logic
> wasn't being used at all?
> 
> Instead of removing it why don't we make it work properly again?  Something
> obviously broke it somewhere along the line, because I am pretty sure this
> heuristic worked at some point in the past.

Yeah, but heuristic to choose the smallest list was hurting a lot, since
it tends to consume all ports.

At connect() time we prefer to have another heuristic, actually leaving
some slots absolutely empty, so that a bind() will succeed later.

Remember I had more than 30 ms latency as described in the 2nd commit
changelog :

References :

commit ea8add2b190395408b22a9127bed2c0912aecbc8
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Feb 11 16:28:50 2016 -0800

    tcp/dccp: better use of ephemeral ports in bind()
    
    Implement strategy used in __inet_hash_connect() in opposite way :
    
    Try to find a candidate using odd ports, then fallback to even ports.
    
    We no longer disable BH for whole traversal, but one bucket at a time.
    We also use cond_resched() to yield cpu to other tasks if needed.
    
    I removed one indentation level and tried to mirror the loop we have
    in __inet_hash_connect() and variable names to ease code maintenance.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 1580ab63fc9a03593072cc5656167a75c4f1d173
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Feb 11 16:28:49 2016 -0800

    tcp/dccp: better use of ephemeral ports in connect()
    
    In commit 07f4c90062f8 ("tcp/dccp: try to not exhaust ip_local_port_range
    in connect()"), I added a very simple heuristic, so that we got better
    chances to use even ports, and allow bind() users to have more available
    slots.
    
    It gave nice results, but with more than 200,000 TCP sessions on a typical
    server, the ~30,000 ephemeral ports are still a rare resource.
    
    I chose to go a step further, by looking at all even ports, and if none
    was available, fallback to odd ports.
    
    The companion patch does the same in bind(), but in opposite way.
    
    I've seen exec times of up to 30ms on busy servers, so I no longer
    disable BH for the whole traversal, but only for each hash bucket.
    I also call cond_resched() to be gentle to other tasks.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
