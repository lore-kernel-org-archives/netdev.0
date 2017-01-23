From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Mon, 23 Jan 2017 23:01:21 +0100
Message-ID: <20170123220121.GG20894@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170123211623.GE20894@1wt.eu>
 <CAEA6p_DxVMAry1PCz_idmk=TGpnnTib3WpWso03FB1oMVXN+sg@mail.gmail.com>
 <20170123213732.GF20894@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Wang <tracywwnj@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:63051 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751136AbdAWWIp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 17:08:45 -0500
Content-Disposition: inline
In-Reply-To: <20170123213732.GF20894@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 10:37:32PM +0100, Willy Tarreau wrote:
> On Mon, Jan 23, 2017 at 01:28:53PM -0800, Wei Wang wrote:
> > Hi Willy,
> > 
> > True. If you call connect() multiple times on a socket which already has
> > cookie without a write(), the second and onward connect() call will return
> > EINPROGRESS.
> > It is basically because the following code block in __inet_stream_connect()
> > can't distinguish if it is the first time connect() is called or not:
> > 
> > case SS_CONNECTING:
> >                 if (inet_sk(sk)->defer_connect)  <----- defer_connect will
> > be 0 only after a write() is called
> >                         err = -EINPROGRESS;
> >                 else
> >                         err = -EALREADY;
> >                 /* Fall out of switch with err, set for this state */
> >                 break;
> 
> Ah OK that totally makes sense, thanks for the explanation!
> 
> > I guess we can add some extra logic here to address this issue. So the
> > second connect() and onwards will return EALREADY.

Thinking about it a bit more, I really think it would make more
sense to return -EISCONN here if we want to match the semantics
of a connect() returning zero on the first call. This way the
caller knows it can write whenever it wants and can disable
write polling until needed.

I'm currently rebuilding a kernel with this change to see if it
behaves any better :

-                        err = -EINPROGRESS;
+                        err = -EISCONN;

I'll keep you updated.

Thanks,
Willy
