From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Tue, 17 May 2016 11:04:53 +0900
Message-ID: <CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
 <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
 <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com> <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Ahern <dsa@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:35117 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbcEQCFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 22:05:14 -0400
Received: by mail-yw0-f171.google.com with SMTP id g133so2305723ywb.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 19:05:14 -0700 (PDT)
In-Reply-To: <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 10:52 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> code is not setup to handle that. Only option seems to be at least dump an
> error message, but the message can not relate any of the specifics about the
> filter. So something like this though it dumps the message per socket
> matched by the filter. Could throttle it to once.
> [...]
>         if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
> -               if (errno == EOPNOTSUPP || errno == ENOENT) {
> -                       /* Socket can't be closed, or is already closed. */
> +               if (errno == ENOENT) {
> +                       /* socket is already closed. */
> +                       return 0;
> +               /* Socket can't be closed OR config is not enabled */
> +               } else if (errno == EOPNOTSUPP) {
> +                       perror("SOCK_DESTROY answers");

The reason the code was written like that is that I didn't want to
print one error message for every socket that can't be closed - such
as TIME_WAIT sockets or UDP sockets.

Given that the filter can specify a number of sockets, some of which
can and some of which can't be closed, and that whether a given socket
can be closed is only known at the time we attempt to close it, there
is a choice between two bad outcomes:

1. Users try to use "ss -K" with a kernel that doesn't support it, and
get confused about why it does nothing and doesn't print an error
message.
2. Users use "ss -K" with a kernel that does support it, and get
irritated by seeing one error message per TCP_TIME_WAIT socket, UDP
socket, etc.

Personally I think it's more important to avoid #2 than #1, because #1
is one time (only if you're compiling your own kernel), but #2 is
forever. Also, I think it's consistent with other behaviours in ss -
for example, if the kernel doesn't support SOCK_DIAG for UDP, you just
get nothing back if you run "ss -u".

That said, I'm not the maintainer of this code. Stephen, any thoughts?
