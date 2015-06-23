From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net] ip: report the original address of ICMP messages
Date: Tue, 23 Jun 2015 15:08:32 -0400
Message-ID: <CA+FuTSf1AtHJtwwDZmPvH7+wvMYTX9BU4=PUVEJOp0ZJix=TQw@mail.gmail.com>
References: <1435037679-2304-1-git-send-email-ja@ssi.bg> <CA+FuTSeza4ZhCUPoL9hLuZzNHAQf79mSBi9EvMvx3mK58A2RRQ@mail.gmail.com>
 <alpine.LFD.2.11.1506232123320.1804@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33694 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416AbbFWTJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 15:09:03 -0400
Received: by obpn3 with SMTP id n3so12638116obp.0
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 12:09:03 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1506232123320.1804@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2015 at 2:55 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Tue, 23 Jun 2015, Willem de Bruijn wrote:
>
>> The ping utility from iputils relies on cmsg IP_RECVERR to get
>> the source address on icmp errors, not on msg_name, so that
>> worked for me both before and after applying the patch. I used
>> `ping -t 2 $hostname` to trigger a TTL exceeded. Perhaps you used
>> a different tool or test? In any case, the change looks fine to me.
>> Thanks for preparing the patch.
>
>
> # rpm -qf `which ping`
> iputils-20140519-1.fc20.i686
>
>         It is using IP_RECVERR and may be relying only on
> original address returned in msg_name from MSG_ERRQUEUE.

It's not very important, in that even if ping does not use this
msg_name, another tool very well might. But from ping.c in that
srpm:

        res = recvmsg(icmp_sock, &msg, MSG_ERRQUEUE|MSG_DONTWAIT);
...
        e = NULL;
        for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
                if (cmsg->cmsg_level == SOL_IP) {
                        if (cmsg->cmsg_type == IP_RECVERR)
                                e = (struct sock_extended_err *)CMSG_DATA(cmsg);
                }
        }
...
        } else if (e->ee_origin == SO_EE_ORIGIN_ICMP) {
                struct sockaddr_in *sin = (struct sockaddr_in*)(e+1);
...
                        printf("From %s icmp_seq=%u ",
pr_addr(sin->sin_addr.s_addr), ntohs(icmph.un.echo.sequence));



> May be it ignores the error if original address is missing
> or is different.
>
>         I didn't checked the ping source but I noticed that
> it does not print anything on the read from raw socket, only
> on IP_RECVERR. I noticed it when my network connection
> failed. The incoming ICMP packet from my router was
> DEST_UNREACH(type=3), HOST_UNREACH(code=1) but simple
> REJECT rule in OUTPUT can do the same.

>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
