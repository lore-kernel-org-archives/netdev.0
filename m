From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: TTL=0 multicast packets leaving host
Date: Wed, 7 Dec 2011 15:31:58 -0600
Message-ID: <20111207213158.GA2444@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:33241 "EHLO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757892Ab1LGVcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 16:32:06 -0500
Received: by mail-gy0-f173.google.com with SMTP id z10so1008834ghb.32
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 13:32:05 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've got some machines where we've noticed that in some cases TTL=0
multicast traffic was leaving the host.  It appear that ip_mc_output()
does the correct check with:

                ...
                /* Multicasts with ttl 0 must not go beyond the host */

                if (ip_hdr(skb)->ttl == 0) {
                        kfree_skb(skb);
                        return 0;
                }
                ...

The problem is that in __mkroute_output() it checks if the local
computer is a member of the multicast group, and if not clears
RTCF_LOCAL

                ...
                if (!ip_check_mc_rcu(in_dev, fl4->daddr, fl4->saddr,
                                     fl4->flowi4_proto))
                        flags &= ~RTCF_LOCAL;
                ...

And if RTCF_LOCAL is _not_ set then ip_output() is used instead of
ip_mc_output()

        ...
        if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
                rth->rt_spec_dst = fl4->saddr;
                if (flags & RTCF_LOCAL &&
                    !(dev_out->flags & IFF_LOOPBACK)) {
                        rth->dst.output = ip_mc_output;
                        RT_CACHE_STAT_INC(out_slow_mc);
                }
        ...

This looks like a bug to me.  I'd assume that if the local computer
has not joined the multicast group and I send a TTL=0 packet that it
would simply get discarded.

--
Shawn



---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
