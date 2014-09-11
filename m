From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 2/2] mac80211: Resolve sk_refcnt/sk_wmem_alloc
 issue in wifi ack path
Date: Thu, 11 Sep 2014 17:53:22 +0200
Message-ID: <1410450802.22863.16.camel@jlt4.sipsolutions.net>
References: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>
		 <20140910220536.23225.92956.stgit@ahduyck-bv4.jf.intel.com>
	 <1410419198.1825.5.camel@jlt4.sipsolutions.net>
	 <5411BDEF.7070105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com, linville@tuxdriver.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:60276 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222AbaIKPxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 11:53:37 -0400
In-Reply-To: <5411BDEF.7070105@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-11 at 08:21 -0700, Alexander Duyck wrote:

[...]
> >>  EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
> > 
> > Here I'm not sure it matters *for this function*? Wouldn't it be freed
> > then in sock_put(), which has the same net effect on this function
> > overall? It doesn't use it after sock_queue_err_skb().
> 
> The significant piece is that we are calling sock_put *after*.  So if we
> are dropping the last reference the buffer is already in the
> sk_error_queue and will be purged when __sk_free is called.

Yeah, I understand. But that's more of a problem of sock_queue_err_skb()
rather than this function.

> > Seems like maybe this should be in sock_queue_err_skb() itself, since it
> > does the orphaning first and then looks at the socket. Or the
> > documentation for that function should state that it has to be held, but
> > there are plenty of callers?
> 
> The problem is there are a number of cases where the sock_hold/put are
> not needed.  For example, if we were to clone the skb and immediately
> send the clone up the sk_error_queue then we don't need it.  We only
> need it if there is a risk that orphaning the buffer sent could
> potentially result in the destructor calling __sk_free.

Ok, that's reasonable. Maybe then you can add that to the documentation
of sock_queue_err_skb() - that it must (somehow) ensure the socket can't
go away while it's being called? That way this caller change would
become clearer IMHO.

> > So you're removing this part, but can't we really not reuse the clone_sk
> > copy? The difference is that it's charged, but that's fine for the
> > purposes here, no? Or am I misunderstanding that?

> The copy being held cannot really be used for transmit.  The problem is
> that it is holding the wrong kind of reference.

Ok.

> The problem lies in the order things are released.  The sock_put
> function will dec_and_test sk_refcnt, once it reaches 0 it will do a
> dec_and_test on sk_wmem_alloc to see if it should call __sk_free.  Until
> that reaches 0 sk_wmem_alloc cannot reach 0.  Once either of these drops
> to 0 we cannot bring the value back up from there.  So if I were to
> transmit the clone then it could let the sk_refcnt drop to 0 in which
> case any calls to sock_hold are invalid.
> 
> I would need to somehow hold the reference based on sk_wmem_alloc if we
> want to transmit the clone.  Many of the hardware timestamping drivers
> seem to just clone the original skb, queue that clone onto the
> sk_error_queue, and then free the original after completing the call.  I
> suppose we could change it to something like that, but you are still
> looking at possibly 2 clones in that case anyway.

Well, no need. I just had originally wanted to reuse the clone so under
these corner case conditions we didn't clone twice - no big deal, it
never happens anyway (that IDR thing should never actually run out of
space)

Anyway, thanks. I expect due to the patch 1 davem will apply both
patches (and I'm going to be on vacation anyway), so 

Acked-by: Johannes Berg <johannes@sipsolutions.net>

for both patches.

Thanks!

johannes
