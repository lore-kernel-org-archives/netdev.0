From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Wed, 2 Oct 2013 12:34:22 -0500
Message-ID: <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
 <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:50479 "EHLO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754840Ab3JBReh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 13:34:37 -0400
Received: by mail-ie0-f172.google.com with SMTP id x13so2645364ief.17
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 10:34:34 -0700 (PDT)
In-Reply-To: <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 01:52:49PM -0700, Eric Dumazet wrote:
> On Tue, 2013-10-01 at 14:33 -0500, Shawn Bohrer wrote:
> > The removal of the routing cache introduced a performance regression for
> > some UDP workloads since a dst lookup must be done for each packet.
> > This change caches the dst per socket in a similar manner to what we do
> > for TCP by implementing early_demux.
> > 
> > For UDP multicast we can only cache the dst if there is only one
> > receiving socket on the host.  Since caching only works when there is
> > one receiving socket we do the multicast socket lookup using RCU.
> 
> For unicast, we should find a matching socket for early demux only if
> this is a connected socket.
> 
> Otherwise, forwarding setups will break.
> 
> You probably need to add a minimum score to __udp4_lib_lookup()

Perhaps I'm missing something but I don't think a minimum score would
work because compute_score() and compute_score2() have several ways of
returning a score of lets say 4 and I don't think they all mean the
socket is connected.  Why not just test the socket returned by
__udp4_lib_lookup() to see if it is connected in
udp_v4_early_demux()?  Something like:

        sk = __udp4_lib_lookup(net, iph->saddr, uh->source,
                               iph->daddr, uh->dest, dif,
                               &udp_table);
        /* Only demux connected sockets or forwarding setups will break */
        if (sk && !inet_sk(sk)->inet_daddr)
                return;

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
