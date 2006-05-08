From: Pavel Roskin <proski@gnu.org>
Subject: Re: dBm cutoff at -1dBm is too low
Date: Sun, 07 May 2006 23:35:50 -0400
Message-ID: <1147059350.32348.10.camel@dv>
References: <1146760665.5294.65.camel@dv>
	 <20060505172818.GA7543@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:35505 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932268AbWEHDgD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 23:36:03 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FcwXR-00048V-Ld
	for netdev@vger.kernel.org; Sun, 07 May 2006 23:36:02 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060505172818.GA7543@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-05 at 10:28 -0700, Jean Tourrilhes wrote:
> 	I tried to use 'signed' in the struct a long while ago, and
> for some reason it broke left and right, I don't remember the
> details. So, whatever we do, it would not be straightforward.

Then let's keep the structure as is and change what iwconfig is
displaying:

--- iwlib.c
+++ iwlib.c
@@ -1400,7 +1400,7 @@ iw_print_stats(char *		buffer,
 	    {
 	      len = snprintf(buffer, buflen, "Signal level%c%d dBm  ",
 			     qual->updated & IW_QUAL_LEVEL_UPDATED ? '=' : ':',
-			     qual->level - 0x100);
+			     ((qual->level - 192) & 0xff) + 192);
 	      buffer += len;
 	      buflen -= len;
 	    }

Semantically, it's already nonsense to use an unsigned number for a
value that is almost always negative.  The true meaning of qual->level
is already a subject of convention.  So let's just adjust this
convention so that we don't punish the clients that report valid
positive dBm values.

The client calculates a value (perhaps an integer) and pushes it into
unsigned char in the hope that the client side can understand it using
the common sense.  Interpreting 0dBm as -256dBm goes against the common
sense.  This has to be specifically worked around in the drivers.

Of course, it would be nice to document it somewhere, and to have
constants e.g.

#define DBM_MIN -192
#define DBM_MAX 63

-- 
Regards,
Pavel Roskin

