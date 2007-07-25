From: "Latchesar Ionkov" <lucho@ionkov.net>
Subject: Re: net/9p/mux.c: use-after-free
Date: Wed, 25 Jul 2007 13:13:34 -0600
Message-ID: <f158dc670707251213i65501f9eh6d35a8712583cd90@mail.gmail.com>
References: <20070723012014.GV26212@stusta.de>
	 <a4e6962a0707251143ie0b0ce8s7d4a9078fed7eb26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@stusta.de>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Eric Van Hensbergen" <ericvh@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934012AbXGYTNy@vger.kernel.org>
In-Reply-To: <a4e6962a0707251143ie0b0ce8s7d4a9078fed7eb26@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yep, it's a leak.

Thanks,
    Lucho

On 7/25/07, Eric Van Hensbergen <ericvh@gmail.com> wrote:
> On 7/22/07, Adrian Bunk <bunk@stusta.de> wrote:
> > The Coverity checker spotted the following use-after-free
> > in net/9p/mux.c:
> >
> > <--  snip  -->
> >
> > ...
> > struct p9_conn *p9_conn_create(struct p9_transport *trans, int msize,
> >                                     unsigned char *extended)
> > {
> > ...
> >         if (!m->tagpool) {
> >                 kfree(m);
> >                 return ERR_PTR(PTR_ERR(m->tagpool));
> >         }
> > ...
> >
> > <--  snip  -->
> >
>
> I've got a fix for this one:
>         if (!m->tagpool) {
>                 mtmp = ERR_PTR(PTR_ERR(m->tagpool));
>                 kfree(m);
>                 return mtmp;
>         }
>
> but I was wondering about one of the other returns further down the function:
>
> ...
>         memset(&m->poll_waddr, 0, sizeof(m->poll_waddr));
>         m->poll_task = NULL;
>         n = p9_mux_poll_start(m);
>         if (n)
>                 return ERR_PTR(n);
>
>         n = trans->poll(trans, &m->pt);
> ...
>
> lucho: doesn't that constitute a leak?  Shouldn't we be doing:
>
>         if (n) {
>                 kfree(m);
>                 return ERR_PTR(n);
>         }
>
>          -eric
>
