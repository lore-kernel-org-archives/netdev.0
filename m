From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for the
 i210.
Date: Tue, 28 May 2013 18:23:25 +0200
Message-ID: <20130528162325.GD4678@netboy>
References: <cfbb4fdcf968d81b2211b97c75c9b5bf820570e4.1369645944.git.richardcochran@gmail.com>
 <CDCA1F64.1E87D%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:45595 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934576Ab3E1QXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 12:23:36 -0400
Received: by mail-we0-f172.google.com with SMTP id w62so5600932wes.3
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 09:23:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CDCA1F64.1E87D%matthew.vick@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 03:58:07PM +0000, Vick, Matthew wrote:
> On 5/27/13 2:21 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:
 
> I would prefer it if we did a MAC check before these two TSICR checks,
> since we're making some assumptions about the hardware within the
> interrupt cases. At the very least, a comment that these are only
> applicable to I210/I211 would be nice.

I can respin with a comment that the additional bits are i210 only. I
think this is better than adding more checks into ISR. Since we only
enable these bits for the i210, the checks would be redundant.

> >diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c
> >b/drivers/net/ethernet/intel/igb/igb_ptp.c
> >index 5944de0..8cf4b8a 100644
> >--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
> >+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
> >@@ -23,6 +23,15 @@
> > 
> > #include "igb.h"
> > 
> >+static int igb_input_sdp = 0;
> >+static int igb_output_sdp = 1;
> >+module_param(igb_input_sdp, int, 0444);
> >+module_param(igb_output_sdp, int, 0444);
> >+MODULE_PARM_DESC(igb_input_sdp,
> >+		 "The SDP used as an input, to time stamp external events");
> >+MODULE_PARM_DESC(igb_output_sdp,
> >+		 "The SDP used to output the programmable periodic signal");
> >+
> 
> Is there any other mechanism we could use to control this? I would imagine
> not, but I know module parameters are generally frowned upon.

This the way I handled it for the PHYTER, and I think it is the best
way from our three choices:

1. kconfig option (inflexible)
2. module param
3. ethtool (can o'worms)

> >@@ -711,6 +800,68 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
> > 		-EFAULT : 0;
> > }
> > 
> >+static int igb_sdp_init(struct igb_adapter *adapter)
> >+{
> >+	struct e1000_hw *hw = &adapter->hw;
> >+	u32 ctrl, ctrl_ext, tssdp = 0;
> >+
> >+	if (igb_input_sdp == igb_output_sdp) {
> >+		pr_err("SDP %d set as both input and output\n", igb_input_sdp);
> >+		return -1;
> 
> Shouldn't this return -EINVAL?

Maybe we don't need the return value at all. Just the message is
important, I think.
 
> >@@ -785,6 +936,10 @@ void igb_ptp_init(struct igb_adapter *adapter)
> > 		struct timespec ts = ktime_to_timespec(ktime_get_real());
> > 
> > 		igb_ptp_settime_i210(&adapter->ptp_caps, &ts);
> >+		igb_sdp_init(adapter);
> 
> What if igb_sdp_init fails?

Hmm, maybe we should then disable the extra features... will consider
for V2.

> >+		adapter->ptp_caps.n_ext_ts = 1;
> >+		adapter->ptp_caps.n_per_out = 1;
> >+		adapter->ptp_caps.pps = 1;

Thanks,
Richard
