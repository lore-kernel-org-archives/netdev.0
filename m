From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: [PATCH] atm : fix
	/sys/devices/virtual/atm/X/carrier(ATM_PHY_SIG_UNKNOWN)
Date: Sun, 14 Feb 2010 18:51:36 +0100
Message-ID: <20100214175136.GA15891@frolo.macqel>
References: <20100213215633.GA4345@frolo.macqel> <201002132324.o1DNOY0F030510@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:24894 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752489Ab0BNRvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 12:51:52 -0500
Content-Disposition: inline
In-Reply-To: <201002132324.o1DNOY0F030510@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chas,

On Sat, Feb 13, 2010 at 06:24:34PM -0500, Chas Williams (CONTRACTOR) wrote:
> In message <20100213215633.GA4345@frolo.macqel>,Philippe De Muyter writes:
> >value '1' while actually carrier was not yet established and real carrier
> >state was not yet known to linux.  I propose to fix that by using '?' as the
> >/sys/devices/virtual/atm/cxacru0/carrier value when carrier state is not yet
> >known to linux.  Any other value except '1' would also be OK for me.
> 
> this is sort of intentional because some drivers dont actually implement
> atm_dev->signal.  ATM_PHY_SIG_UNKNOWN and ATM_PHY_SIG_LOST should
> likely be carrier = 0.  if the driver doesnt isnt going to handle
> changing the state of atm_dev->signal it should just set the value to
> ATM_PHY_SIG_FOUND.
> 
> i dont like the idea of carrier being '?' -- carrier is either true or false.
> you have it or you dont.

OK for me.  I would agree with

	carrier = 0 when signal == ATM_PHY_SIG_UNKNOWN,

but currently we have

	carrier = 1 when signal == ATM_PHY_SIG_UNKNOWN

cxacru itself does the right thing : as soon as carrier state is known,
signal is set to ATM_PHY_SIG_LOST or ATM_PHY_SIG_FOUND, but
atm_sysfs.c::show_carrier is wrong.

So here is a revised patch :

--

The carrier field of /sys/devices/virtual/atm/cxacru0 shows 1 when carrier
is actually down (but unknown to linux).  Make it show 0 instead in that case.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>

--- a/net/atm/atm_sysfs.c	2010-02-14 18:17:05.604508129 +0100
+++ b/net/atm/atm_sysfs.c	2010-02-14 18:15:08.316917041 +0100
@@ -63,8 +63,7 @@ static ssize_t show_carrier(struct devic
 	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
 
-	pos += sprintf(pos, "%d\n",
-		       adev->signal == ATM_PHY_SIG_LOST ? 0 : 1);
+	pos += sprintf(pos, "%d\n", adev->signal == ATM_PHY_SIG_FOUND);
 
 	return pos - buf;
 }
