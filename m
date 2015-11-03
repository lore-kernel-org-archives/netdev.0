From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3] xfrm: dst_entries_init() per-net dst_ops
Date: Tue, 3 Nov 2015 14:22:32 +0100
Message-ID: <20151103132232.GQ7701@secunet.com>
References: <1446118162-5385-1-git-send-email-dan.streetman@canonical.com>
 <1446126676-7242-1-git-send-email-dan.streetman@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Dan Streetman <ddstreet@ieee.org>
To: Dan Streetman <dan.streetman@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48120 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976AbbKCNWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 08:22:39 -0500
Content-Disposition: inline
In-Reply-To: <1446126676-7242-1-git-send-email-dan.streetman@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 09:51:16AM -0400, Dan Streetman wrote:
> Remove the dst_entries_init/destroy calls for xfrm4 and xfrm6 dst_ops
> templates; their dst_entries counters will never be used.  Move the
> xfrm dst_ops initialization from the common xfrm/xfrm_policy.c to
> xfrm4/xfrm4_policy.c and xfrm6/xfrm6_policy.c, and call dst_entries_init
> and dst_entries_destroy for each net namespace.
> 
> The ipv4 and ipv6 xfrms each create dst_ops template, and perform
> dst_entries_init on the templates.  The template values are copied to each
> net namespace's xfrm.xfrm*_dst_ops.  The problem there is the dst_ops
> pcpuc_entries field is a percpu counter and cannot be used correctly by
> simply copying it to another object.
> 
> The result of this is a very subtle bug; changes to the dst entries
> counter from one net namespace may sometimes get applied to a different
> net namespace dst entries counter.  This is because of how the percpu
> counter works; it has a main count field as well as a pointer to the
> percpu variables.  Each net namespace maintains its own main count
> variable, but all point to one set of percpu variables.  When any net
> namespace happens to change one of the percpu variables to outside its
> small batch range, its count is moved to the net namespace's main count
> variable.  So with multiple net namespaces operating concurrently, the
> dst_ops entries counter can stray from the actual value that it should
> be; if counts are consistently moved from one net namespace to another
> (which my testing showed is likely), then one net namespace winds up
> with a negative dst_ops count while another winds up with a continually
> increasing count, eventually reaching its gc_thresh limit, which causes
> all new traffic on the net namespace to fail with -ENOBUFS.
> 
> Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>

Applied to the ipsec tree, thanks Dan!
