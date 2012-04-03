From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference at __ip_route_output_key
Date: Mon, 02 Apr 2012 20:07:11 -0400 (EDT)
Message-ID: <20120402.200711.2234324385609269937.davem@davemloft.net>
References: <20120402194056.GA1002@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fedoraproject.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab2DCAHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 20:07:15 -0400
In-Reply-To: <20120402194056.GA1002@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 2 Apr 2012 15:40:56 -0400

> We just had this reported. Look familiar to anyone ?

If you could unravel the source file and line the OOPS occurs at, I
can look at these kinds of reports much faster.  As it stands, when I
see a Fedora OOPS, it's a long process for me:

1) Edit /boot/vmlinuz-3.3.0-8, stip image until gzip header and
   store in x.gz, gzip -d x.gz

2) gdb ./x and try to match up symbols in System.map, which BTW
   I have to become root to even friggin' _READ_, and oh yes
   doubly stupid because there's a readable copy under /usr/src

3) Try to bisect where it's OOPS'ing in the source code, and given
   GCC's optimizations where it moves basic blocks all over the
   place, this is error prone and time consuming.

etc. etc.

Anyways in this case dev_out is NULL when we read it around line
2798 of net/ipv4/route.c:

	dev_out = FIB_RES_DEV(res);
	fl4->flowi4_oif = dev_out->ifindex;

and we are thus OOPS'ing on the dev_out->ifindex.

Unfortunately I've never seen a report like this.  If the reporter can
reproduce, you can try to extract more information by doing something
like this right after the dev_out assignment:

	if (!dev_out) {
		pr_crit("ipv4: FIB_RES_DEV() is NULL, nh_sel=%d\n",
			res.nh_sel);
		rth = ERR_PTR(-EINVAL);
		goto out;
	}

This debugging will also avoid the NULL pointer crash at least for
that particular invocation.
