From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net 5/5] l2tp: take a reference on sessions used in
 genetlink handlers
Date: Fri, 31 Mar 2017 19:27:42 +0200
Message-ID: <20170331172742.xh3cxpbmjn45nbv6@alphalink.fr>
References: <cover.1490955471.git.g.nault@alphalink.fr>
 <32e49ef213e02f291b5accd3a9ac961e2d2f960b.1490955471.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        James Chapman <jchapman@katalix.com>,
        Bill Hong <bhong@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51038 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933217AbdCaR1q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 13:27:46 -0400
Content-Disposition: inline
In-Reply-To: <32e49ef213e02f291b5accd3a9ac961e2d2f960b.1490955471.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 31, 2017 at 01:02:30PM +0200, Guillaume Nault wrote:
> Callers of l2tp_nl_session_find() need to hold a reference on the
> returned session since there's no guarantee that it isn't going to
> disappear from under them.
> 
> Relying on the fact that no l2tp netlink message may be processed
> concurrently isn't enough: sessions can be deleted by other means
> (e.g. by closing the PPPOL2TP socket of a ppp pseudowire).
> 
> l2tp_nl_cmd_session_delete() is a bit special: it runs a callback
> function that may require a previous call to session->ref(). In
> particular, for ppp pseudowires, the callback is l2tp_session_delete(),
> which then calls pppol2tp_session_close() and dereferences the PPPOL2TP
> socket. The socket might already be gone at the moment
> l2tp_session_delete() calls session->ref(), so we need to take a
> reference during the session lookup. So we need to pass the do_ref
> variable down to l2tp_session_get() and l2tp_session_get_by_ifname().
> 
> Since all callers have to be updated, l2tp_session_find_by_ifname() and
> l2tp_nl_session_find() are renamed to reflect their new behaviour.
> 
> Fixes: 33f72e6f0c67 ("l2tp : multicast notification to the registered listeners")

Sorry, it should have been
Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")

Commit 33f72e6f0c67 ("l2tp : multicast notification to the registered
listeners") just worsened the existing race conditions.

David, do you want me to repost this series with the new Fixes tag?
