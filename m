From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Tue, 10 Jul 2012 17:38:05 +0300
Message-ID: <1341931085.27035.13.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1341923634.27035.6.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120710.053724.1002197670026212780.davem@davemloft.net>
 <1341924089.27035.7.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120710.060616.2081630953053267615.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3667 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327Ab2GJOiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 10:38:14 -0400
In-Reply-To: <20120710.060616.2081630953053267615.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 06:06 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Tue, 10 Jul 2012 15:41:29 +0300
> 
> > OK. Since it blocks the ability to add SR-IOV support, is it acceptable
> > to submit it as constant enabled for PF and disabled for VF (SR-IOV)?
> 
> You're not describing to me why you guys are turning on features like
> the CNIC mode before you necessarily have any users of that feature.

The chips controlled by the bnx2x have shared HW - there is more than
one port using the same HW. So changing shared HW configuration affects
more than one interface and therefore should not be done in runtime -
one of the requirements is that operations on one interface will not
affect any other interface.

> Why can't you turn CNIC off at the start, and if a CNIC user actually
> arrives and is activated, reset the entire chip and put it into CNIC
> mode?

Since the CNIC mode should not change under traffic, and since it is a
shared HW attribute, we need to consider a scenario on which one
interface is loaded and running in L2 only mode, and then on another
interface the CNIC is required, but enabling it will affect the first
interface that is already running.

> And if CNIC being on is such a latency killer, why in the world
> haven't you done things more reasonably like that from the very
> beginning?
> 
> Why are you making it so that lower latency with your chips is only
> available to a group of users who are effectively statistically
> insignificant?

The chip latency is advertised with the CNIC support for customers.
However, some of them have full control over the environment and do not
care about offloaded storage and they were able to optimize it by
removing the CNIC completely. This is somewhat similar to customers that
do not want the other port and we tweak the device nvram to completely
shutdown one port and by that save some power - most customers that use
only one port cannot benefit from this additional power saving of
completely disabling that port. Most of our customers are OEM that sells
machines that might run Linux, and they want to allow users to use iSCSI
and FCoE - and we are not enabling this extra optimization for those -
simply because the HW was designed to be a converged NIC and this L2
only optimization was added later for those special cases.

This patch is removing the ifdefs from all over the bnx2x and placing
the equivalent ifdef about the Kconfig in one location - this will allow
adding support for the SR-IOV that cannot support the CNIC alongside
with PF that does support it.
