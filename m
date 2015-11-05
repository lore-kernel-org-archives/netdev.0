From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: kernel 3.14.53 + bnx2x loss of connectivity / parity errors /
 MCP SCPAD
Date: Thu, 5 Nov 2015 06:45:20 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E6B99B@avmb3.qlogic.org>
References: <1727409.Ct3NHyBiXb@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Greg KH <gregkh@linuxfoundation.org>,
	"ariele@broadcom.com" <ariele@broadcom.com>
To: Patrick Schaaf <netdev@bof.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:29058 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033954AbbKEGp2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2015 01:45:28 -0500
In-Reply-To: <1727409.Ct3NHyBiXb@rofl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> on a production server (HP DL380 Gen9 with HP 10GE dual port card - bnx2x
> driver), I just encountered a full loss of connectivity through the 10 GE ports.
> Kernel in use is vanilla 3.14.53.
> 
> On the console I could see this (timestamps omitted, have to type by hand,
> damn ILO console does not let me copy+paste text...)
> 
> MCP SCPAD
> MCP SCPAD
> bnx2x 0000:04:00.1 eth1: Parity errors detected in blocks:
> MCP SCPAD
> MCP SCPAD
> bnx2x 0000:04:00.0 eth0: Parity errors detected in blocks:
> bnx2x: [bnx2x_attn_int_deasserted3:4080(eth0)]LATCHED attention
> 0x80000000
> (masked)
> MCP SCPAD
> ...
> systemd-journald[491]: /dev/kmsg buffer overrun, some messages lost.
> 
> Some googling around finds:
> 
> https://github.com/torvalds/linux/commit/ad6afbe9578d1fa26680faf78c846bd
> 8c00d1d6e
> 
> which might be related. If I read that correctly (and I have no real idea what I'm
> talking about, sorry...) that patch removes superflous printks which might, e.g. in
> our case, hide the real cause. i.e. even with that patch we would have had a
> problem / loss of connectivity, but we might know better why.

> 
> Maybe that changeset would be suitable for backporting to long term stable
> kernels?
> 
> Incidentally, how should these parity events be judged generally? Hope it's a one
> time cosmic ray incident? Cry "faulty hardware, please repair" to the supplier?
> Anything else?

A couple of things to note - 
1. On older kernels, MCP SCPAD parity on its own would have resulted in
Entering the parity recovery flows, and assuming those would have failed
resulting in an adapter in an unsteady state.
But 3.14.53 should be passed that point, and only log MCP SCPAD errors
instead of initiating recovery.

2. Since the SCPAD is not on the datapath, even assuming a real parity
would occur, if that's the only problem then it shouldn't have stopped traffic.

3. In most cases SCPAD is due to utilities, e.g., `ethtool -d' or `ethtool -t'
that are ran on the adapter's network interface; Theoretically, if there's some
unexpected incompatibility between driver and management FW it might
also happen.

4. The patch you've listed merely removes the MCP SCPAD prints, as they're
unavoidable in certain scenarios; It doesn't actually solve anything.

Having said that, do you know if anything happened to the setup that
triggered this? I.e., so configuration change, new utility, etc.?
Alternatively, did the log show anything else in addition to the MCP SCPAD?
