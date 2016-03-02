From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] net: moxa: fix an error code
Date: Wed, 2 Mar 2016 15:15:26 +0300
Message-ID: <20160302121526.GS5273@mwanda>
References: <20160302101110.GI5533@mwanda>
 <7083740.CtlZQWRYiM@wuerfel>
 <20160302112129.GQ5273@mwanda>
 <2743496.LmeGdM2Ipd@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jonas Jensen <jonas.jensen@gmail.com>,
	Luis de Bethencourt <luis@debethencourt.com>,
	=?iso-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17407 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbcCBMPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 07:15:48 -0500
Content-Disposition: inline
In-Reply-To: <2743496.LmeGdM2Ipd@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2016 at 12:36:05PM +0100, Arnd Bergmann wrote:
> The uninitialized warning here is about a type mismatch preventing
> gcc from noticing that two conditions are the same, I'm not sure
> if this is a bug in gcc, or required by the C standard.

I wouldn't call it a bug, because everyone has to make trade offs
between how fast the program runs and how accurate it is.  And trade
offs between how ambitious your warnings are vs how many false positives
you can tolerate.

Anyway, I feel like we should just work around GCC on a case by case
basis instead of always using PTR_ERR_OR_ZERO().  The next version of
GCC will fix some false positives and introduce new ones...  Next time
using PTR_ERR_OR_ZERO() could cause warnings instead of fixing them.

Smatch works in a different way and it parse the code correctly.  But
Smatch is slow and sometimes runs out of memory and gives up trying to
parse large functions.  Smatch sees the two returns and tries to figure
out the implications of each (uninitialized vs initialized).  If you
change the code to:

	error = PTR_ERR_OR_ZERO(hash);

	if (!error)
		*leaf_out = be64_to_cpu(*(hash + index));

	return error;

then Smatch still breaks that up into two separate returns which imply
initialized vs uninitialized.

regards,
dan carpenter
