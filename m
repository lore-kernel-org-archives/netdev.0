From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH v3 1/2] realtek: convert to per-chip mask
Date: Fri, 09 Aug 2013 10:51:11 +0200
Message-ID: <6171378.LP1RDUmkgD@al>
References: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com> <1374759391-16916-2-git-send-email-lekensteyn@gmail.com> <1375986341.2853.52.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:40705 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263Ab3HIIvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 04:51:17 -0400
Received: by mail-wg0-f41.google.com with SMTP id l18so1309007wgh.4
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 01:51:15 -0700 (PDT)
In-Reply-To: <1375986341.2853.52.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 08 August 2013 20:25:41 Ben Hutchings wrote:
> On Thu, 2013-07-25 at 15:36 +0200, Peter Wu wrote:
> [...]
> 
> > @@ -35,36 +32,62 @@ enum chip_type {
> > 
> >  	RTL8100E2,
> >  
> >  };
> > 
> > -enum {
> > -	chip_type_mask = HW_REVID(1, 1, 1, 1, 1, 1, 1, 1)
> > +static const char * const chip_names[] = {
> > +	[RTL8139] =		"8139",
> > +	[RTL8139_K] =		"8139-K",
> > +	[RTL8139A] =		"8139A",
> > +	[RTL8139A_G] =		"8139A-G",
> > +	[RTL8139B] =		"8139B",
> > +	[RTL8130] =		"8130",
> > +	[RTL8139C] =		"8139C",
> > +	[RTL8100] =		"8100",
> > +	[RTL8100B_8139D] =	"8100B/8139D",
> > +	[RTL8139C] =		"8139C+",
> 
> Shouldn't the index here be RTL8139Cp?

The specifications mention "RTL8139C+", I took pre-8169 names from the previous 
rtl_info_tbl contents:

-       { "RTL-8139C+",         HW_REVID(0, 1, 1, 1, 0, 1, 1, 0) },


> [...]
> 
> >  static struct chip_info {
> > 
> > -	const char *name;
> > 
> >  	u32 id_mask;
> > 
> > +	u32 id_val;
> > +	int mac_version;
> > 
> >  } rtl_info_tbl[] = {
> 
> [...]
> 
> > -	{ "RTL-8169/8110SCe",	HW_REVID(1, 0, 0, 1, 1, 0, 0, 0) },
> 
> [...]
> 
> > +	{ 0xfcc00000, 0x68000000,	RTL8169_8110SCe },
> 
> [...]
> 
> The old value would be converted to 0x98000000; is this a fix or a
> mistake?

I made a mistake here, I pre-processed it to some Javascript code, but 
apparantly (1 << 31) overflows to -0x80000000 which is what you are seeing 
here. I'll fix it up in a next revision.

In the following patch (2/2), I inserted automatically extracted values from 
the r8169 driver using an AWK script (see bottom of this message). At that 
point, "8169sc/8110sc" is restored again:

    [RTL_GIGA_MAC_VER_06] = "8169sc/8110sc",
    ...
    { 0xfc800000, 0x98000000,       RTL_GIGA_MAC_VER_06 },

Thanks for reviewing.

Regards,
Peter

--

#!/usr/bin/awk -f
# Usage: $0 drivers/net/ethernet/realtek/r8169.c
BEGIN {
	# stage 0: copy enum for chip version
	# stage 1: grab names
	# stage 2: grab masks and mappings to name
	stage = -1;
	ver = "";
}
/enum mac_version/ {
	stage = 0;
}
/struct rtl_mac_info/ {
	stage = 2;
	print "};\n"
}
{
	if (stage == 0) {
		print
	}
	if (stage == 1 && ver) {
		split($1, a, "\"");
		name = a[2];
		print "\t" ver " = \"" name "\","
		ver = "";
	}
	if (stage == 2) {
		sub("\t", "");
		print
	}
}
/};/ {
	if (stage == 0) {
		stage = 1;
		print "\nstatic const char *chip_names[] = {"
	}
	if (stage == 2) exit
}
/\[RTL_GIGA_MAC_VER_/ {
	ver = $1
}
