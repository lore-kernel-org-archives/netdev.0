From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Thu, 19 May 2016 09:55:10 +0900
Message-ID: <CAKD1Yr1u-p8hyjd_e672kYrXw+-Mkmj_Cxai=WUYM-9QQG=DQg@mail.gmail.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
 <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
 <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
 <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
 <CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com>
 <3d0fd83a-fa88-8ceb-a44d-237f5a005eb4@cumulusnetworks.com>
 <CAKD1Yr0E9i0s0ocSyYhEjODnVVQVBPOfbepvORAhT9gi9Qqz6A@mail.gmail.com> <a3cafb2342fa6a754fc389947f77f248@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:36486 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcESAzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 20:55:31 -0400
Received: by mail-yw0-f174.google.com with SMTP id x189so63326545ywe.3
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 17:55:30 -0700 (PDT)
In-Reply-To: <a3cafb2342fa6a754fc389947f77f248@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 3:35 AM, <subashab@codeaurora.org> wrote:
> Would it be acceptable to have a separate column which displays the result of the sock destroy operation per socket.
> State    ... Killed
> ESTAB         Y
> TIME_WAIT     N

Fine by me, but... what problem are we trying to address? People who
compile their own kernels and don't turn CONFIG_INET_DIAG_DESTROY, and
then are confused why it doesn't work? Seems like we could fix that by
turning CONFIG_INET_DIAG_DESTROY on by default. CCing the people who
commented on the original SOCK_DESTROY patch to see if they have
opinions.

> If it is not supported from kernel, maybe print U (unsupported) for this.

In current code there is no way to distinguish U from N because in
both cases the error will be EOPNOTSUPP. It's certainly possible to
change SOCK_DESTROY to return something else (e.g., EBADFD) to
indicate "kernel supports closing this type of socket, but it can't be
closed due to the state it's in". In hindsight, perhaps I should have
done that from the start.

Regardless, we still have the problem of what to do if the user says
"ss -K dport = :443" and we encounter a UDP socket connected to port
443. Options:

1. Silently skip. if the tool prints something, it means it closed it.
2. Abort with an error message.
3. Skip the socket and print an error every time this happens.
4. Skip the socket and print an error the first time this happens.

Personally I still think #1 is the best option.
