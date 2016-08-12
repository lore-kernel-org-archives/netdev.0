From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Sat, 13 Aug 2016 00:45:16 +0900
Message-ID: <CAKD1Yr3LNv+hDm0HfxYiGvotiTYab9W-+5R0OUjinF-tdwKy1g@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <20160808.143500.473355495580691289.davem@davemloft.net> <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
 <20160808.222030.1314134961786852070.davem@davemloft.net> <CAAedzxq-XYTVgZ7=VX-OWHYNSRjDuf==si-my=Jy3YEo7atcWQ@mail.gmail.com>
 <04a393c9-39f8-8d73-3476-928732e5b193@cumulusnetworks.com> <ed271d49-e796-ebaa-2e71-35711710fd49@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>, Erik Kline <ek@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:35366 "EHLO
	mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbcHLPqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:46:04 -0400
Received: by mail-it0-f50.google.com with SMTP id u186so14851566ita.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:45:37 -0700 (PDT)
In-Reply-To: <ed271d49-e796-ebaa-2e71-35711710fd49@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 7:44 AM, YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com> wrote:
>
> >> I could see a point of view that says when bound_if is in play sending
> >> to destinations on/via other interfaces--by any mechanism--should
> >> effectively get ENETUNREACH (or something).
> >
> > VRF uses this capability to send on an enslaved interface. ie., socket is bound to VRF device to limit packets to that L3 domain and then uses PKTINFO to force a packet out a particular interface.
>
> We could extend our code to allow enslave devices, maybe.

So something like this, then?

static inline bool inet_check_bound_oif(const struct sock *sk, int oif)
{
        if (!oif || !sk->sk_bound_dev_if || oif == sk->sk_bound_dev_if)
                return true;

#ifdef CONFIG_NET_L3_MASTER_DEV
        return l3mdev_master_ifindex_by_index(sock_net(sk), oif) ==
                sk->sk_bound_dev_if;
#endif

        return false;
}

and then in the various sendmsg functions:

        if (!inet_check_bound_oif(sk, oif))
                return -EINVAL;
