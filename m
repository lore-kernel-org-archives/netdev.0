From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Tue, 17 May 2016 10:01:48 +0900
Message-ID: <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com> <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:34450 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbcEQBCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 21:02:09 -0400
Received: by mail-yw0-f174.google.com with SMTP id j74so1223107ywg.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 18:02:09 -0700 (PDT)
In-Reply-To: <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 8:53 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> @@ -2264,7 +2264,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
>         if (!(diag_arg->f->families & (1 << r->idiag_family)))
>                 return 0;
>         if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
> -               if (errno == EOPNOTSUPP || errno == ENOENT) {
> +               if (errno == ENOENT) {
>                         /* Socket can't be closed, or is already closed. */
>                         return 0;
>                 } else {

I don't think you can do this without breaking the functionality of -K.

The else branch will cause show_one_inet_sock to return -1, which will
cause rtnl_dump_filter to abort and not close any other sockets that
the user requested killing. That's incorrect, because getting
EOPNOTSUPP on one socket doesn't necessarily mean we'll get EOPNOTSUPP
on any future sockets in the same dump.

For example, EOPNOTSUPP can just mean "this socket can't be closed
because it's a timewait or NEW_SYN_RECV socket". In hindsight it might
have been better to return EBADFD in those cases, but that still
doesn't solve the UI problem. If the user does something like "ss -K
dport = :443", the user would expect the command to kill all TCP
sockets and not just abort if there happens to be a UDP socket to port
443 (which can't be closed because UDP doesn't currently implement
SOCK_DESTROY).
