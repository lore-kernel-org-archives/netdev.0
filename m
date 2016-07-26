From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v3] UCC_GETH/UCC_FAST: Use IS_ERR_VALUE_U32 API to avoid
 IS_ERR_VALUE abuses.
Date: Tue, 26 Jul 2016 09:04:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F5023E2@AcuExch.aculab.com>
References: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "qiang.zhao@freescale.com" <qiang.zhao@freescale.com>,
	"scottwood@freescale.com" <scottwood@freescale.com>,
	"viresh.kumar@linaro.org" <viresh.kumar@linaro.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"arnd@arndb.de" <arnd@arndb.de>
To: 'Arvind Yadav' <arvind.yadav.cs@gmail.com>,
	"zajec5@gmail.com" <zajec5@gmail.com>,
	"leoli@freescale.com" <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:62970 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbcGZJGp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 05:06:45 -0400
In-Reply-To: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvind Yadav
> Sent: 23 July 2016 19:06
> IS_ERR_VALUE() assumes that its parameter is an unsigned long.
> It can not be used to check if an 'unsigned int' reflects an error.
> As they pass an 'unsigned int' into a function that takes an
> 'unsigned long' argument. This happens to work because the type
> is sign-extended on 64-bit architectures before it gets converted
> into an unsigned type.
> 
> However, anything that passes an 'unsigned short' or 'unsigned int'
> argument into IS_ERR_VALUE() is guaranteed to be broken, as are
> 8-bit integers and types that are wider than 'unsigned long'.
> 
> It would be nice to any users that are not passing 'unsigned int'
> arguments.

Isn't that a load of bollocks???
It is certainly very over-wordy.

IS_ERR_VALUE(x) is ((x) >= (unsigned long)-4096)

Assuming sizeof (short) == 2 && sizeof (int) == 4 && sizeof (long) == 8.

'signed char' and 'signed short' are first sign extended to 'signed int'.
'unsigned char' and 'unsigned short' are first zero extended to 'signed int'.
'signed int' is sign extended to 'signed long'.
'signed long' is converted to 'unsigned long' treating the bit-pattern as 'unsigned long'.
'unsigned int' is zero extended to 'unsigned long'.

It is probably enough to say that on 64bit systems IS_ERR_VALUE() of unsigned int
is always false because the 32bit value is zero extended to 64 bits.

A possible 'fix' would be to define IS_ERR_VALUE() as:
#define IS_ERR_VALUE(x) unlikely(sizeof (x) > sizeof (int) ? (x) > (unsigned long)-MAX_ERRNO : (x) > (unsigned int)-MAX_ERRNO)

However correct analysis of every case might show up real errors.
So a compilation warning/error might be more appropriate.

	David
