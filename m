From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] bcm43xx: iw_priv_args names should be <16 characters
Date: Fri, 14 Apr 2006 03:33:21 -0700
Message-ID: <20060414103321.GD26289@gaz.sfgoth.com>
References: <20060413130227.GD20839@harddisk-recovery.nl> <20060413102919.5e0bdb2e@localhost.localdomain> <20060414093503.GF20839@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gaz.sfgoth.com ([69.36.241.230]:27618 "EHLO gaz.sfgoth.com")
	by vger.kernel.org with ESMTP id S965138AbWDNK2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 06:28:21 -0400
To: Erik Mouw <erik@harddisk-recovery.com>
Content-Disposition: inline
In-Reply-To: <20060414093503.GF20839@harddisk-recovery.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Erik Mouw wrote:
> On Thu, Apr 13, 2006 at 10:29:19AM -0700, Stephen Hemminger wrote:
> > Shouldn't compiler have gagged on this?
> 
> Apparently not. At least the compiler I use doesn't warn about it (gcc
> version 3.3.5 (Debian 1:3.3.5-13)).
> 
> Linus, this might be be something for sparse to check:
> 
>   struct mystruct {
> 	char name[16];
>   };
> 
>   mystruct ms = { .name = "muchlongerthan16characters" };

If you actually try that example you'd see that gcc (even really old
versions) will warn you about that code.

What gcc WON'T warn about is if everything but the final '\0' fits in
the array.

So the code:
	struct mystruct { char name[16]; };
	struct mystruct exact_length = { .name = "0123456789abcdef" };
	struct mystruct one_too_long = { .name = "0123456789abcdefg" };

Produces:
	a.c:3: warning: initializer-string for array of chars is too long
	a.c:3: warning: (near initialization for 'one_too_long.name')

I believe this is intentional and in line with the C specs.  It's also
useful since it allows you to define macros like:

	#define DECLARE_NON_TERMINATED_STRING(name, val) \
			const name[sizeof(val "") - 1] = val;

Making sparse a bit stricter than gcc in this case might not be a bad idea,
though.

-Mitch
