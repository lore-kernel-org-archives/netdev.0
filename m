From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ip: report the original address of ICMP messages
Date: Tue, 23 Jun 2015 23:06:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506232248560.3482@ja.home.ssi.bg>
References: <1435037679-2304-1-git-send-email-ja@ssi.bg> <CA+FuTSeza4ZhCUPoL9hLuZzNHAQf79mSBi9EvMvx3mK58A2RRQ@mail.gmail.com> <alpine.LFD.2.11.1506232123320.1804@ja.home.ssi.bg> <CA+FuTSf1AtHJtwwDZmPvH7+wvMYTX9BU4=PUVEJOp0ZJix=TQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:45413 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933200AbbFWUGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 16:06:39 -0400
In-Reply-To: <CA+FuTSf1AtHJtwwDZmPvH7+wvMYTX9BU4=PUVEJOp0ZJix=TQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 23 Jun 2015, Willem de Bruijn wrote:

> >         It is using IP_RECVERR and may be relying only on
> > original address returned in msg_name from MSG_ERRQUEUE.
> 
> It's not very important, in that even if ping does not use this
> msg_name, another tool very well might. But from ping.c in that
> srpm:
> 
>         res = recvmsg(icmp_sock, &msg, MSG_ERRQUEUE|MSG_DONTWAIT);
> ...
>         e = NULL;
>         for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
>                 if (cmsg->cmsg_level == SOL_IP) {
>                         if (cmsg->cmsg_type == IP_RECVERR)
>                                 e = (struct sock_extended_err *)CMSG_DATA(cmsg);
>                 }
>         }
> ...
>         } else if (e->ee_origin == SO_EE_ORIGIN_ICMP) {
>                 struct sockaddr_in *sin = (struct sockaddr_in*)(e+1);
> ...

	It is used, it compares the embedded original address
from error message here (msg.msg_name = (void*)&target):

	target.sin_addr.s_addr != whereto.sin_addr.s_addr

and it does not match because kernel failed to fill the
msg_name buffer. In fact, kernel returns msg_namelen=0 but
it is not checked here, so may be ping.c compares random memory.

>                         printf("From %s icmp_seq=%u ",
> pr_addr(sin->sin_addr.s_addr), ntohs(icmph.un.echo.sequence));

	What you are referring here is the offender address (sin),
the sender of the ICMP error, it is just printed...

Regards

--
Julian Anastasov <ja@ssi.bg>
