From: Fields Bruce James <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/2] SUNRPC: accept() may return sockets that are still
 in SYN_RECV
Date: Wed, 27 Jul 2016 14:48:06 -0400
Message-ID: <20160727184806.GA19229@fieldses.org>
References: <1469541080-4184-1-git-send-email-trond.myklebust@primarydata.com>
 <20160726154354.GA6692@fieldses.org>
 <7C18520C-D486-4466-8D9D-FF2052B03F0E@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: List Linux NFS Mailing <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7C18520C-D486-4466-8D9D-FF2052B03F0E-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2016 at 04:08:29PM +0000, Trond Myklebust wrote:
> 
> > On Jul 26, 2016, at 11:43, J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:
> > 
> > On Tue, Jul 26, 2016 at 09:51:19AM -0400, Trond Myklebust wrote:
> >> We're seeing traces of the following form:
> >> 
> >> [10952.396347] svc: transport ffff88042ba4a 000 dequeued, inuse=2
> >> [10952.396351] svc: tcp_accept ffff88042ba4 a000 sock ffff88042a6e4c80
> >> [10952.396362] nfsd: connect from 10.2.6.1, port=187
> >> [10952.396364] svc: svc_setup_socket ffff8800b99bcf00
> >> [10952.396368] setting up TCP socket for reading
> >> [10952.396370] svc: svc_setup_socket created ffff8803eb10a000 (inet ffff88042b75b800)
> >> [10952.396373] svc: transport ffff8803eb10a000 put into queue
> >> [10952.396375] svc: transport ffff88042ba4a000 put into queue
> >> [10952.396377] svc: server ffff8800bb0ec000 waiting for data (to = 3600000)
> >> [10952.396380] svc: transport ffff8803eb10a000 dequeued, inuse=2
> >> [10952.396381] svc_recv: found XPT_CLOSE
> >> [10952.396397] svc: svc_delete_xprt(ffff8803eb10a000)
> >> [10952.396398] svc: svc_tcp_sock_detach(ffff8803eb10a000)
> >> [10952.396399] svc: svc_sock_detach(ffff8803eb10a000)
> >> [10952.396412] svc: svc_sock_free(ffff8803eb10a000)
> >> 
> >> i.e. an immediate close of the socket after initialisation.
> > 
> > Interesting, thanks!
> > 
> > So the one thing I don't understand is why this is correct behavior for
> > accept--I thought it wasn't supposed to return a socket until it was
> > fully established.
> 
> inet_accept() appears to allow SYN_RECV:

OK.  Cc'ing netdev just to make sure we didn't overlook anything.

(Also: what were user-visible symptoms?  Mounts failing, or unexpected
delays?)

--b.

> 
> int inet_accept(struct socket *sock, struct socket *newsock, int flags)
> {
>         struct sock *sk1 = sock->sk;
>         int err = -EINVAL;
>         struct sock *sk2 = sk1->sk_prot->accept(sk1, flags, &err);
> 
>         if (!sk2)
>                 goto do_err;
> 
>         lock_sock(sk2);
> 
>         sock_rps_record_flow(sk2);
>         WARN_ON(!((1 << sk2->sk_state) &
>                   (TCPF_ESTABLISHED | TCPF_SYN_RECV |
>                   TCPF_CLOSE_WAIT | TCPF_CLOSE)));
> 
>         sock_graft(sk2, newsock);
> 
>         newsock->state = SS_CONNECTED;
>         err = 0;
>         release_sock(sk2);
> do_err:
>         return err;
> }
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
