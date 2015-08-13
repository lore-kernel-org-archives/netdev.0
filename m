From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: fix races with reqsk timers
Date: Thu, 13 Aug 2015 14:30:12 -0700
Message-ID: <1439501412.7960.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
	 <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2FC70745-2105-465E-A82E-44D565A930F0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34264 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120AbbHMVaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:30:14 -0400
Received: by paccq16 with SMTP id cq16so1651538pac.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 14:30:13 -0700 (PDT)
In-Reply-To: <2FC70745-2105-465E-A82E-44D565A930F0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-14 at 00:13 +0300, Nikolay Aleksandrov wrote:
> > On Aug 13, 2015, at 11:44 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >=20
> > On Thu, 2015-08-13 at 13:19 -0700, Eric Dumazet wrote:
> >=20
> >>=20
> >> A caller handler can not call del_timer_sync()
> >=20
> > A timer handler can not call del_timer_sync()
> >=20
> > I am testing a minimal fix :
> >=20
> > diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connec=
tion_sock.c
> > index 05e3145f7dc3..134957159c27 100644
> > --- a/net/ipv4/inet_connection_sock.c
> > +++ b/net/ipv4/inet_connection_sock.c
> > @@ -593,7 +593,7 @@ static bool reqsk_queue_unlink(struct request_s=
ock_queue *queue,
> > 	}
> >=20
> > 	spin_unlock(&queue->syn_wait_lock);
> > -	if (del_timer_sync(&req->rsk_timer))
> > +	if (timer_pending(&req->rsk_timer) && del_timer_sync(&req->rsk_ti=
mer))
> > 		reqsk_put(req);
> > 	return found;
> > }
> >=20
> >=20
>=20
> Wouldn=E2=80=99t try_to_del_timer_sync(&req->rsk_timer) > 0 be better=
 ?

I am not sure : there are contexts where we need to wait for the timer
being completed (this was point of commit
2235f2ac75fd2501c251b0b699a9632e80239a6d)

(problem is that timer handler can rearm itself)
