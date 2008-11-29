From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH v2 5/5] fs: new_inode_single() and iput_single()
Date: Sat, 29 Nov 2008 12:14:53 +0100
Message-ID: <20081129111452.GB11959@logfs.org>
References: <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <49310115.8010306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lazybastard.de ([212.112.238.170]:45719 "EHLO
	longford.logfs.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996AbYK2LPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 06:15:15 -0500
Content-Disposition: inline
In-Reply-To: <49310115.8010306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 November 2008 09:45:09 +0100, Eric Dumazet wrote:
> =20
> +void iput_single(struct inode *inode)
> +{
> +	if (atomic_dec_and_test(&inode->i_count)) {
> +		destroy_inode(inode);
> +		percpu_counter_dec(&nr_inodes);
> +	}
> +}

I wonder if it is possible to avoid the atomic_dec_and_test() here, at
least in the common case, and combine it with the atomic_dec_and_test()
of the dentry.  A quick look at fs/inode.c indicates that inode->i_coun=
t
may never get changed for a SINGLE inode, except during creation or
deletion.

It might be worth to
- remove the conditional from iput_single() and measure that it makes a
  difference,
- poison SINGLE inodes with some value and
- put a BUG_ON() in __iget() that checks for the poison value.

I _think_ the BUG_ON() is unnecessary, but at least my brain is not
sufficient to convince me.  Can inotify somehow get a hold of a socket?
Or dquot (how insane would that be?)

J=C3=B6rn

--=20
Mac is for working,
Linux is for Networking,
Windows is for Solitaire!
-- stolen from dc
