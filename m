From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
Date: Thu, 9 Oct 2014 00:38:46 +0200
Message-ID: <4F8303E0-EA1B-4D93-B898-10ACD072F404@suse.de>
References: <1412803407-10621-1-git-send-email-agraf@suse.de> <1412807355.2260.17.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Aaron Brown <aaron.f.brown@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59144 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbaJHWit convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 18:38:49 -0400
In-Reply-To: <1412807355.2260.17.camel@jtkirshe-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> Am 09.10.2014 um 00:29 schrieb Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> 
>> On Wed, 2014-10-08 at 23:23 +0200, Alexander Graf wrote:
>> Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac
>> address to the VF on reset rather than a random one.
>> 
>> However, that behavioral change also requires igbvf driver changes
>> which can be hard especially when we want to talk to proprietary
>> guest OSs.
>> 
>> Looking at the code previous to the commit in Linux that made igbvf
>> work with empty mac addresses (8d56b6d), we can see that on reset
>> failure the driver will try to generate a new mac address with both
>> the old and the new code.
>> 
>> Furthermore, ixgbe does send reset failure when it detects an empty
>> mac address (35055928c).
>> 
>> So I think it's safe to make igb behave the same. With this patch I
>> can successfully run a Windows 8.1 guest with an empty mac address
>> and an assigned igbvf device that has no mac address set by the host.
>> 
>> If anyone is aware of a guest driver that chokes on NACK returns of
>> VF RESET commands, please speak up.
>> 
>> Signed-off-by: Alexander Graf <agraf@suse.de>
>> ---
>> drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++++--
>> 1 file changed, 6 insertions(+), 2 deletions(-)
> 
> Actually after further review of this patch and the reported bug in
> SuSE's bugzilla, we are NACK'ing this patch.
> 
> If the reset has not failed, why are we indicating that it has?

Very good question. It's what the ixgbe driver does and older Linux, newer Linux as well as Windows seem to interpret it as "I need to generate a mac address".

I have no idea whether that's the intended meaning of a reset nack, but if it isn't, ixgbe probably shouldn't nack it either then.

Is the mbox message protocol documented anywhere? I could only find references to register layouts so far, but nothing about the comminucation on top of them.

> We
> originally supplied the VF with a NULL MAC, so we should supply it
> again.  That way, the VF can choose to either regenerate a new random
> MAC or keep using the one that it had.

Where is this documented? And why doesn't ixgbe adhere to this?

> The current method was a fix that was requested by the community in the
> first place, also we cannot take into account "proprietary guest OS's".

I don't think I understand this comment. "The community" is a very broad term in Linux ;). Also, this patch merely moves igb to behave identically to ixgbe in how it tells an igbvf driver that the mac address is empty. Nothing changes wrt the original change to not generate random mac addresses. That stays identical.


Alex
