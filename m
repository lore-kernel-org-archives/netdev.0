From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 1/2] avoid OPEN_MAX in SCM_MAX_FD
Date: Tue, 13 Mar 2007 10:17:50 -0400
Message-ID: <20070313141750.GH6209@kvack.org>
References: <20070313083912.89D891801C5@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Roland McGrath <roland@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:33873 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030368AbXCMOSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 10:18:04 -0400
Content-Disposition: inline
In-Reply-To: <20070313083912.89D891801C5@magilla.sf.frob.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 13, 2007 at 01:39:12AM -0700, Roland McGrath wrote:
> The OPEN_MAX constant is an arbitrary number with no useful relation to
> anything.  Nothing should be using it.  This patch changes SCM_MAX_FD to
> use NR_OPEN instead of OPEN_MAX.  This increases the size of the struct
> scm_fp_list type fourfold, to make it big enough to contain as many file
> descriptors as could be asked of it.  This size increase may not be very
> worthwhile, but at any rate if an arbitrary limit unrelated to anything
> else is being defined it should be done explicitly here with:

> -#define SCM_MAX_FD	(OPEN_MAX-1)
> +#define SCM_MAX_FD	(NR_OPEN-1)

This is a bad idea.  From linux/fs.h:

#undef NR_OPEN
#define NR_OPEN (1024*1024)     /* Absolute upper limit on fd num */

There isn't anything I can see guaranteeing that net/scm.h is included 
before fs.h.  This affects networking and should really be Cc'd to 
netdev@vger.kernel.org, which will raise the issue that if SCM_MAX_FD is 
raised, the resulting simple kmalloc() must be changed.  That said, I 
doubt SCM_MAX_FD really needs to be raised, as applications using many 
file descriptors are unlikely to try to send their entire file table to 
another process in one go -- they have to handle the limits imposed by 
SCM_MAX_FD anyways.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
