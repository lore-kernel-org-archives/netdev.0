From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH 3.12 117/133] alpha: fix broken network checksum
Date: Thu, 6 Feb 2014 04:18:42 -0500 (EST)
Message-ID: <alpine.LRH.2.02.1402060341090.31200@file01.intranet.prod.int.rdu2.redhat.com>
References: <20140204210737.008598235@linuxfoundation.org> <20140204210740.336662867@linuxfoundation.org> <20140206043833.GA12599@omega>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Matt Turner <mattst88@gmail.com>
To: Michael Cree <mcree@orcon.net.nz>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140206043833.GA12599@omega>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 6 Feb 2014, Michael Cree wrote:

> On Tue, Feb 04, 2014 at 01:08:38PM -0800, Greg Kroah-Hartman wrote:
> > 3.12-stable review patch.  If anyone has any objections, please let me know.
> > 
> > ------------------
> > 
> > From: Mikulas Patocka <mpatocka@redhat.com>
> > 
> > commit 0ef38d70d4118b2ce1a538d14357be5ff9dc2bbd upstream.
> > 
> > The patch 3ddc5b46a8e90f3c9251338b60191d0a804b0d92 breaks networking on
> > alpha (there is a follow-up fix 5cfe8f1ba5eebe6f4b6e5858cdb1a5be4f3272a6,
> > but networking is still broken even with the second patch).
> 
> I wonder whether that follow-up (partial) fix mentioned
> (5cfe8f1ba5eebe6f4b6e5858cdb1a5be4f3272a6) should be pulled into 3.12 stable
> too?
> 
> Cheers
> Michael.

Hi

It is quite confusing - csum_partial_copy_from_user is only called from 
csum_and_copy_from_user in include/net/checksum.h.

csum_and_copy_from_user already verifies the source memory range with 
access_ok. Despite this, people started to add access_ok to many 
architecture-specific versions of csum_partial_copy_from_user (for example 
3ddc5b46a8e90f3c9251338b60191d0a804b0d92).

It seems that the best thing is to revert 
0ef38d70d4118b2ce1a538d14357be5ff9dc2bbd, 
5cfe8f1ba5eebe6f4b6e5858cdb1a5be4f3272a6 and csum_partial_copy_from_user 
change from 3ddc5b46a8e90f3c9251338b60191d0a804b0d92.


David, you are maintainer of networking - does it have any deeper sense to 
perform access_ok in csum_partial_copy_from_user if the caller performs 
this check already? Should this be just removed?

Also - the x86 and alpha implementation of csum_and_copy_from_user zero 
the destination buffer on userspace-access error - but 
csum_and_copy_from_user (that calls these function) doesn't zero the 
destination buffer on error. Should the destination buffer be zeroed on 
error or not?

Mikulas
