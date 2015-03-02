From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCHv3 net-next 3/4] ipv4: shrink current mss for tcp PMTU
 blackhole detection
Date: Mon, 2 Mar 2015 15:32:22 -0500
Message-ID: <CABrhC0nXCtWCgNm6Gz8UCXg=7Vt1pN0Q+aqO1TYZ74JK45Tq-g@mail.gmail.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com>
	<1425093785-27380-4-git-send-email-fan.du@intel.com>
	<CABrhC0m6nCwHy-CCLiFStYhSbMf78E1i6Lvh=DsPi6Pcg-GCOw@mail.gmail.com>
	<54F42D94.6070802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fan Du <fan.du@intel.com>, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:43938 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbbCBUcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:32:24 -0500
Received: by labgf13 with SMTP id gf13so8426354lab.10
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 12:32:22 -0800 (PST)
In-Reply-To: <54F42D94.6070802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 4:29 AM, Fan Du <fengyuleidian0615@gmail.com> wrote:
> Timeout indicates search_high should be set to the new mtu corresponding to
> current_mss no
> matter how we change search_low. So the best shot here IMO would be updating
> search_high
> with current_mss, which in return makes the search window *slide* from right
> to left, and
> the probing will converge in good speed eventually.
>
> So my thoughts is:
> @@ -113,6 +113,7 @@ static void tcp_mtu_probing(struct inet_connection_sock
> *icsk, struct sock *sk)
>                         struct tcp_sock *tp = tcp_sk(sk);
>                         int mss;
>
> +                       icsk_mtup.search_high = tcp_mss_to_mtu(sk,
> tcp_current_mss(sk));
>                         mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)
>>> 1;
>                         mss = min(net->ipv4.sysctl_tcp_base_mss, mss);
>                         mss = max(mss, 68 - tp->tcp_header_len);

Search_high should be adjusted downward only when you're quite certain
that you've gotten a negative signal.  There are many possible reasons
for successive timeouts including intermittent disconnection, and they
should not have a persistent (or very long-term) effect on MTU.  Leave
search_high where it is until a working MTU can be established, then
probe upward until probing can give you confidence you've found a new
ceiling, or gotten back to the old one.

If you think the current approach is broken, it would help to see a
concrete demonstration of how it's deficient (a real packet trace is
good!), and how a different approach work better.

Thanks,
  -John
