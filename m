From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: WARN trace - skb_warn_bad_offload - vxlan - large udp packet -
 udp checksum disabled
Date: Thu, 7 Jan 2016 07:46:40 +0100
Message-ID: <20160107064640.GA27753@unicorn.suse.cz>
References: <FC41C24E35F18A40888AACA1A36F3E418AFD00B5@fmsmsx115.amr.corp.intel.com>
 <568DCF2B.2090502@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Nelson, Shannon" <shannon.nelson@intel.com>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38354 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbcAGGqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 01:46:44 -0500
Content-Disposition: inline
In-Reply-To: <568DCF2B.2090502@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 03:36:27AM +0100, Hannes Frederic Sowa wrote:
> On 15.12.2015 02:35, Nelson, Shannon wrote:
> >Using a slightly modified version of udpspam (see diff below -
> >hopefully not mangled by corporate email servers), where I set the
> >SO_NO_CHECK socket option and can specify a large buffer size, I can
> >reliably get the following WARN trace.  I have reproduced this on
> >both ixgbe and i40e drivers using "udpspam-no-check <target-ip>
> >6000".
> >
> >It looks to me like this is in the Tx path before we get to the
> >actual NIC drivers, but I may be wrong.
> 
> Does UFO offloading on the tunnel interface fix this error?
> 
> ethtool -K vxlan ufo off
> 
> If yes we can't feed SO_NO_CHECK udp packets into UFO as gso/ufo
> requires CHECKSUM_PARTIAL (or add some more logic into the skb or
> query socket status from skb_gso_segment).

I believe you are right. This sounds like the issue addressed by commit
acf8dd0a9d0b ("udp: only allow UFO for packets from SOCK_DGRAM sockets")
except for a regular SOCK_DGRAM socket with SO_NO_CHECK option. If so,
changing both instances of the check

	    (sk->sk_type == SOCK_DGRAM)

added by this commit to

	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx

should fix the problem (and it should be done even if the issue reported
here is caused by something else).

                                                        Michal Kubecek
