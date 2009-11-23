From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH 0/7] via-velocity performance fixes
Date: Mon, 23 Nov 2009 14:39:22 +0100
Message-ID: <20091123143922.273d13f9@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091120090348.1e51e29e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	romieu@fr.zoreil.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:47257 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751365AbZKWNjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 08:39:22 -0500
In-Reply-To: <20091120090348.1e51e29e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen and David!

Thanks for the comments, I'll address these in the next version.

On Fri, 20 Nov 2009 09:03:48 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:
 
> > 1. Correct setting of skipped checksums (unsure about this). The
> >    mainline driver sets CHECKSUM_UNNECESSARY if this is an IP packet
> >    except if the TCP checksum is NOT ok.
> > 
> >    The VIA driver sets CHECKSUM_UNNECESSARY if this is an UDP/TCP
> >    packet except if the TCP checksum is not OK. The patch selects the
> >    VIA behavior.
>
> The mainline driver is already doing the correct thing. 
> The VIA driver would send packet
> with known bad checksum up the stack with CHECKSUM_UNNECESSARY.
> What is supposed to happen is:
> 
> Checksum good:  set CHECKSUM_UNNECESSARY
>           bad:  leave CHECKSUM_NONE

Yes, I see now that mainline is correct and I'll remove the patch from
the upcoming version 2 of the series. However, I don't think the driver
would send bad packets upwards - it would rather be more conservative.
What the current driver does is

	ip_summed = CHECKSUM_NONE;
	if (hardware sees that this is an IP packet):
		if (hw IP checksum is OK):
			if (hw sees that this is a TCP/UDP packet):
				if (hw TCP/UDP checksum is NOT OK):
					return  # Returning CHECKSUM_NONE
			ip_summed = CHECKSUM_UNNECESSARY

while the VIA driver does

	ip_summed = CHECKSUM_NONE;
	if (hardware sees that this is an IP packet):
		if (hw IP checksum is OK):
			if (hw sees that this is a TCP/UDP packet):
				if (hw TCP/UDP checksum is NOT OK):
					return  # Returning CHECKSUM_NONE
				ip_summed = CHECKSUM_UNNECESSARY

i.e., it will return CHECKSUM_NONE also for non-TCP/UDP IP packets.

// Simon
