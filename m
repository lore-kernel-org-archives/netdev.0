From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] ethtool: Report driver features described in
 struct ethtool_drvinfo
Date: Fri, 18 Mar 2011 22:44:37 +0000
Message-ID: <1300488277.2589.50.camel@bwh-desktop>
References: <ae232d9a-90c7-47ae-856d-bc5a2b3a8037@exht1.ad.emulex.com>
	 ,<1300483939.2589.46.camel@bwh-desktop>
	 <49395329523DD64492581B505F80C86D5A5BCD38EA@EXMAIL.ad.emulex.com>
	 ,<1300485636.2589.48.camel@bwh-desktop>
	 <49395329523DD64492581B505F80C86D5A5BCD38EB@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit.Khaparde@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51727 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176Ab1CRWol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 18:44:41 -0400
In-Reply-To: <49395329523DD64492581B505F80C86D5A5BCD38EB@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 15:07 -0700, Ajit.Khaparde@Emulex.Com wrote:
> ________________________________________
> From: Ben Hutchings [bhutchings@solarflare.com]
> Sent: Friday, March 18, 2011 5:00 PM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: RE: [RFC] ethtool: Display reg dump length via get driver info.
> 
> > On Fri, 2011-03-18 at 14:52 -0700, Ajit.Khaparde@Emulex.Com wrote:
> >> ______________________________________
> >> From: Ben Hutchings [bhutchings@solarflare.com]
> >> Sent: Friday, March 18, 2011 4:32 PM
> >> To: Khaparde, Ajit
> >> Cc: netdev@vger.kernel.org
> >> Subject: Re: [RFC] ethtool: Display reg dump length via get driver info.
> >>
> >> On Fri, 2011-03-18 at 16:06 -0500, Ajit Khaparde wrote:
> >> >> Devices like BE store Reg Dump Data in the hardware.
> >>
> > >> Where else would it be?
> >>
> >> Well yes. That's true.
> >>
> >> >> This change will allow to just peek into the hardware
> >> >> to see if any data is available for a dump and analysis,
> >> >> without actually dumping the register data.
> >> > [...]
> >>
> >> > This is wrong.  ethtool_ops::get_regs_len really should return a
> >> > constant, otherwise ethtool (and the kernel) cannot allocate a buffer of
> >> > the right size.  If the size of a dump really does vary then make it
> >> > return the maximum possible size for the device.
> >>
> >> Yes, it is a constant size. And will always be the max size possible.
> >> I just want to see if I can get the length, without really making the ethtoool -d call.
> >> Because that will trigger the dump too.
> >> At that moment, I may not be interested in the data itself.
> 
> > OK, so what you're really interested in is 'does this version of the
> > driver support register dump'?
> 
> Yes. I did not want to add another option in ethtool to get this info out.

So, how about this?

Ben.

---
ETHTOOL_GDRVINFO fills out struct ethtool_drvinfo with the size of the
data returned by various other operations.  The size should be non-zero
if and only if the driver implements that operation.  Therefore, we can
report whether the driver supports certain operations without actually
trying them (which may be expensive and disruptive).

Do this in dump_drvinfo() rather than adding a separation operation.
---
 ethtool.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index e9cb2c9..32df0ee 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1423,11 +1423,19 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 		"driver: %s\n"
 		"version: %s\n"
 		"firmware-version: %s\n"
-		"bus-info: %s\n",
+		"bus-info: %s\n"
+		"supports-statistics: %s\n"
+		"supports-test: %s\n"
+		"supports-eeprom-access: %s\n"
+		"supports-register-dump: %s\n",
 		info->driver,
 		info->version,
 		info->fw_version,
-		info->bus_info);
+		info->bus_info,
+		info->n_stats ? "yes" : "no",
+		info->testinfo_len ? "yes" : "no",
+		info->eedump_len ? "yes" : "no",
+		info->regdump_len ? "yes" : "no");
 
 	return 0;
 }
---

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

