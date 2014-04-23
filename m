From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH] mrf24j40: seperate mrf24j40 h/w
 init and add checkings
Date: Wed, 23 Apr 2014 11:36:34 -0300
Message-ID: <20140423143633.GA19663@ws>
References: <1398258716-18319-1-git-send-email-varkab@cdac.in>
 <5357C565.8080009@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Varka Bhadram <varkabhadram@gmail.com>, alex.aring@gmail.com,
	Varka Bhadram <varkab@cdac.in>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: Alan Ott <alan@signal11.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.almesberger.net ([204.10.140.10]:36174 "EHLO
	host.almesberger.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbaDWOrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 10:47:23 -0400
Content-Disposition: inline
In-Reply-To: <5357C565.8080009@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Ott wrote:
> 3. The code to check for it just adds a lot of bloat without much 
> measurable benefit.

As a very general note, if - in any C program, not just the kernel
- you have too many error checks for comfort, you may want to
consider keeping a cumulative error status (e.g., in this case,
struct mrf24j40), and just check that. Similar to ferror in stdio.

Something like


static int my_check_and_clear_rc(struct foo *foo)
{
	int rc;

	rc = foo->rc;
	foo->rc = 0;
	return rc;
}


static int my_operation(struct foo *foo, int arg)
{
	int rc;

	/* don't make it worse - optional */
	if (foo->rc)
		return foo->rc;

	rc = really_do_my_operation(foo, arg);
	if (rc < 0 && !foo->rc)
		foo->rc = rc;

	return foo->rc ? foo->rc : rc;
}


Then the phalanx of tedious checks shrinks to

	/* make sure foo->rc is initialized to 0 */

	my_operation(foo, 1);
	my_operation(foo, 2);
	...
	my_operation(foo, 1000);

	rc = my_check_and_clear_rc(foo);
	if (rc) {
		complain("something terribly wrong");
		...
	}
	...

You can easily extend this to also record line numbers, file
names, and such, if necessary. Add atomic/locking as needed.

- Werner
