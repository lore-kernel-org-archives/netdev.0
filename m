From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 3 Sep 2009 17:44:54 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909031731540.24199@V090114053VZO-1>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>  <alpine.DEB.1.10.0908121820410.3257@gentwo.org>  <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>  <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>
 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>  <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>  <4A9EEF07.5070800@gmail.com>  <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>  <4A9F1620.2080105@gmail.com>
 <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com>
 <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <4AA00400.1030005@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:33889 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932513AbZICXOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 19:14:55 -0400
In-Reply-To: <4AA00400.1030005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Sep 2009, Eric Dumazet wrote:

> It seems very smart, but needs review of all callers to make sure no slabs
> are waiting for final freeing in call_rcu queue on some cpu.

Yes. Again this is the first time we encounter a situation where a
DESTROY_BY_RCU slab has to be destroyed. So the review is quite short.

> I suspect most of them will then have to use rcu_barrier() before calling
> kmem_cache_destroy(), so why not factorizing code in one place ?

There are different forms of RCU which require different forms of
barriers. Its best to leave that up to the user. Again the user must make
sure that no objects are in use before a slab is destroyed. For
SLAB_DESTROY_BY_RCU this means that there are no potential outstanding
reads on the structure. You may need an rcu_barrier() to accomplish that.

Slight variations in the use of RCU could require different method. Better
reduce the entanglement of slabs to RCU to a mininum possible.


