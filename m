From: "Eric Van Hensbergen" <ericvh@gmail.com>
Subject: Re: net/9p/mux.c: use-after-free
Date: Wed, 25 Jul 2007 13:43:16 -0500
Message-ID: <a4e6962a0707251143ie0b0ce8s7d4a9078fed7eb26@mail.gmail.com>
References: <20070723012014.GV26212@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Latchesar Ionkov" <lucho@ionkov.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Adrian Bunk" <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:26766 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755064AbXGYSnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 14:43:18 -0400
Received: by wa-out-1112.google.com with SMTP id v27so307344wah
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 11:43:17 -0700 (PDT)
In-Reply-To: <20070723012014.GV26212@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/22/07, Adrian Bunk <bunk@stusta.de> wrote:
> The Coverity checker spotted the following use-after-free
> in net/9p/mux.c:
>
> <--  snip  -->
>
> ...
> struct p9_conn *p9_conn_create(struct p9_transport *trans, int msize,
>                                     unsigned char *extended)
> {
> ...
>         if (!m->tagpool) {
>                 kfree(m);
>                 return ERR_PTR(PTR_ERR(m->tagpool));
>         }
> ...
>
> <--  snip  -->
>

I've got a fix for this one:
        if (!m->tagpool) {
                mtmp = ERR_PTR(PTR_ERR(m->tagpool));
                kfree(m);
                return mtmp;
        }

but I was wondering about one of the other returns further down the function:

...
        memset(&m->poll_waddr, 0, sizeof(m->poll_waddr));
        m->poll_task = NULL;
        n = p9_mux_poll_start(m);
        if (n)
                return ERR_PTR(n);

        n = trans->poll(trans, &m->pt);
...

lucho: doesn't that constitute a leak?  Shouldn't we be doing:

        if (n) {
                kfree(m);
                return ERR_PTR(n);
        }

         -eric
