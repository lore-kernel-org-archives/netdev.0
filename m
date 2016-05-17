From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Mon, 16 May 2016 19:52:44 -0600
Message-ID: <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
 <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
 <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37847 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933601AbcEQBwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 21:52:49 -0400
Received: by mail-ig0-f180.google.com with SMTP id s8so2480592ign.0
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 18:52:48 -0700 (PDT)
In-Reply-To: <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/16 7:20 PM, Lorenzo Colitti wrote:
> On Tue, May 17, 2016 at 10:14 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>>
>>> For example, EOPNOTSUPP can just mean "this socket can't be closed
>>> because it's a timewait or NEW_SYN_RECV socket". In hindsight it might
>>> have been better to return EBADFD in those cases, but that still
>>> doesn't solve the UI problem. If the user does something like "ss -K
>>> dport = :443", the user would expect the command to kill all TCP
>>> sockets and not just abort if there happens to be a UDP socket to port
>>> 443 (which can't be closed because UDP doesn't currently implement
>>> SOCK_DESTROY).
>>
>>
>> Silently doing nothing is just as bad - or worse. I was running in circles trying to figure out why nothing was happening and ss was exiting 0.
>
>
> At least that's documented to be the case in the man page.
>
> On the other hand, if your patch is applied, there will be no way to
> close more than one socket if one of them returns EOPNOTSUPP. On a
> busy server where things go into TIME_WAIT all the time, you might
> never be able to close all sockets.
>
> If you want to inform the user, then you could do so via the return
> value of ss - e.g., return 0 if at least one socket was printed and
> closed, or 1 otherwise.
>

code is not setup to handle that. Only option seems to be at least dump 
an error message, but the message can not relate any of the specifics 
about the filter. So something like this though it dumps the message per 
socket matched by the filter. Could throttle it to once.

diff --git a/misc/ss.c b/misc/ss.c
index 23fff19d9199..1925c6fd9c36 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2264,8 +2264,12 @@ static int show_one_inet_sock(const struct 
sockaddr_nl *addr,
         if (!(diag_arg->f->families & (1 << r->idiag_family)))
                 return 0;
         if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
-               if (errno == EOPNOTSUPP || errno == ENOENT) {
-                       /* Socket can't be closed, or is already closed. */
+               if (errno == ENOENT) {
+                       /* socket is already closed. */
+                       return 0;
+               /* Socket can't be closed OR config is not enabled */
+               } else if (errno == EOPNOTSUPP) {
+                       perror("SOCK_DESTROY answers");
                         return 0;
                 } else {
                         perror("SOCK_DESTROY answers");
