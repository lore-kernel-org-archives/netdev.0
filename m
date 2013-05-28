From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for
 the i210.
Date: Tue, 28 May 2013 17:49:21 +0000
Message-ID: <CDCA3AA1.1E8D4%matthew.vick@intel.com>
References: <20130528162325.GD4678@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:35126 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964881Ab3E1Rte convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 13:49:34 -0400
In-Reply-To: <20130528162325.GD4678@netboy>
Content-Language: en-US
Content-ID: <44ED0FE56139EE40AB247181C6200E1C@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/28/13 9:23 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:

>On Tue, May 28, 2013 at 03:58:07PM +0000, Vick, Matthew wrote:
>> On 5/27/13 2:21 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:
> 
>> I would prefer it if we did a MAC check before these two TSICR checks,
>> since we're making some assumptions about the hardware within the
>> interrupt cases. At the very least, a comment that these are only
>> applicable to I210/I211 would be nice.
>
>I can respin with a comment that the additional bits are i210 only. I
>think this is better than adding more checks into ISR. Since we only
>enable these bits for the i210, the checks would be redundant.

Personal preference would dictate a MAC check, but I'm alright with a
comment. :)

>> >diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c
>> >b/drivers/net/ethernet/intel/igb/igb_ptp.c
>> >index 5944de0..8cf4b8a 100644
>> >--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
>> >+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
>> >@@ -23,6 +23,15 @@
>> > 
>> > #include "igb.h"
>> > 
>> >+static int igb_input_sdp = 0;
>> >+static int igb_output_sdp = 1;
>> >+module_param(igb_input_sdp, int, 0444);
>> >+module_param(igb_output_sdp, int, 0444);
>> >+MODULE_PARM_DESC(igb_input_sdp,
>> >+		 "The SDP used as an input, to time stamp external events");
>> >+MODULE_PARM_DESC(igb_output_sdp,
>> >+		 "The SDP used to output the programmable periodic signal");
>> >+
>> 
>> Is there any other mechanism we could use to control this? I would
>>imagine
>> not, but I know module parameters are generally frowned upon.
>
>This the way I handled it for the PHYTER, and I think it is the best
>way from our three choices:
>
>1. kconfig option (inflexible)
>2. module param
>3. ethtool (can o'worms)

Ah, I didn't realize we had a precedent. Module param is fine with me,
then. ethtool does seem like the right long-term solution, but I don't
think that should gate your patchset if we already have a precedent for
this functionality.

>> >@@ -711,6 +800,68 @@ int igb_ptp_hwtstamp_ioctl(struct net_device
>>*netdev,
>> > 		-EFAULT : 0;
>> > }
>> > 
>> >+static int igb_sdp_init(struct igb_adapter *adapter)
>> >+{
>> >+	struct e1000_hw *hw = &adapter->hw;
>> >+	u32 ctrl, ctrl_ext, tssdp = 0;
>> >+
>> >+	if (igb_input_sdp == igb_output_sdp) {
>> >+		pr_err("SDP %d set as both input and output\n", igb_input_sdp);
>> >+		return -1;
>> 
>> Shouldn't this return -EINVAL?
>
>Maybe we don't need the return value at all. Just the message is
>important, I think.

I think an error is the right way to go, but if it's not then we should
print a warning instead of an error.

Also, on second thought, please use the dev_err or dev_warn macros for
consistency with the rest of the codebase.

> 
>> >@@ -785,6 +936,10 @@ void igb_ptp_init(struct igb_adapter *adapter)
>> > 		struct timespec ts = ktime_to_timespec(ktime_get_real());
>> > 
>> > 		igb_ptp_settime_i210(&adapter->ptp_caps, &ts);
>> >+		igb_sdp_init(adapter);
>> 
>> What if igb_sdp_init fails?
>
>Hmm, maybe we should then disable the extra features... will consider
>for V2.

That would be my vote, since we would have failed to initialize that extra
feature.
