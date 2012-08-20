From: Colin McCabe <cmccabe@alumni.cmu.edu>
Subject: Re: Documenting UNIX domain autobind
Date: Mon, 20 Aug 2012 11:42:27 -0700
Message-ID: <CA+qbEUOoEDwgWWfqfpX_D1uaCk2poDgnJS5STguZ=Qbovq=XSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-man@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:37606 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181Ab2HTSm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 14:42:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hello Tetsuo,
>
> I'm the Linux man-pages mainatiner. I write to you because I see that
> you recently (http://kerneltrap.org/mailarchive/linux-netdev/2010/8/30/6284106/thread#mid-6284106)
> did some work patchiing Linux unix_autobind(), so you may know the
> answer to this question. But, also others on the CC may know.
>
> I recently noticed this feature in the kernel, and so added some
> documentation to the unix(7) man page. That text reads as follows:
>
>   Autobind Feature
>       If a bind() call specifies addrlen as  sizeof(sa_family_t),  or
>       the  SO_PASSCRED  socket option was specified for a socket that
>       was not explicitly bound to an  address,  then  the  socket  is
>       autobound  to  an  abstract address.  The address consists of a
>       null byte followed by 5 bytes in the  character  set  [0-9a-f].
>       (Thus, there is a limit of 2^20 autobind addresses.)
>
> I think this text correctly documents the technical details (but let
> me know if you see errors). What is lacking is an explanation of why
> this feature exists. Is someone able to explain where this feature is
> used and why?
>
> thanks,
>
> Michael

I wasn't involved in developing this feature, but as someone who has
used UNIX domain sockets in the past, I think I can comment on this.

As you know, you have to bind every UNIX domain socket to a unique
identifier.  In Linux, this can be either a path or an entry in the
abstract namespace.  Either way, if you try to use an identifier that
someone is already using, it won't work.  If autobind did not exist,
you could write a loop to try random identifers until you get one that
works.  With autobind, you don't have to write this code and risk
getting it wrong.

Another consideration is that autobind gives you a guarantee that
you're not using an identifier that someone else has chosen.  Without
this guarantee, it's possible that the random-ish identifer you chose
will conflict with another process on the system.  One man's randomly
chosen string is another man's carefully-chosen identifier.  Autobind
eliminates this risk completely.

It would be nice to see some discussion in the man pages about the
potential security issues of using UNIX domain sockets.  For example,
if you create a UNIX domain socket under /tmp, a malicious process
could move it out of the way and create its own socket there,
effectively performing a man-in-the-middle attack on you.  If you
create a socket under /tmp that is named predictably (like
/tmp/my-program-name), a malicious process could create a
denial-of-service by creating a socket or other entry in that
position.  These issues can be avoided by using the abstract
namespace, or using a well-known and secure path for UNIX domain
sockets.  However, a novice wouldn't necessarily know that he needed
to do that.

cheers,
Colin McCabe
