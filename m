From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Tue, 17 May 2016 10:20:58 +0900
Message-ID: <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com> <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:35043 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874AbcEQBVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 21:21:19 -0400
Received: by mail-yw0-f171.google.com with SMTP id g133so1539279ywb.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 18:21:18 -0700 (PDT)
In-Reply-To: <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 10:14 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>
>> For example, EOPNOTSUPP can just mean "this socket can't be closed
>> because it's a timewait or NEW_SYN_RECV socket". In hindsight it might
>> have been better to return EBADFD in those cases, but that still
>> doesn't solve the UI problem. If the user does something like "ss -K
>> dport = :443", the user would expect the command to kill all TCP
>> sockets and not just abort if there happens to be a UDP socket to port
>> 443 (which can't be closed because UDP doesn't currently implement
>> SOCK_DESTROY).
>
>
> Silently doing nothing is just as bad - or worse. I was running in circles trying to figure out why nothing was happening and ss was exiting 0.


At least that's documented to be the case in the man page.

On the other hand, if your patch is applied, there will be no way to
close more than one socket if one of them returns EOPNOTSUPP. On a
busy server where things go into TIME_WAIT all the time, you might
never be able to close all sockets.

If you want to inform the user, then you could do so via the return
value of ss - e.g., return 0 if at least one socket was printed and
closed, or 1 otherwise.
