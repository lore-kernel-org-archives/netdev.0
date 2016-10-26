From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute: ss truncates abstract unix domain socket embedding
 null
Date: Wed, 26 Oct 2016 15:22:17 -0700
Message-ID: <20161026152217.4058fcaa@xeon-e3>
References: <CAC-fF8SMUsj8pPJO+VYdRSQAOcwyBpJY1C9V3VEk3zrFS=Jy4Q@mail.gmail.com>
        <CAC-fF8SdbDHPMZbOwHg=cOpsy+4ewTq9KGi-Cp=uaaG0hEJ8Fg@mail.gmail.com>
        <20161026101554.15d8d37b@xeon-e3>
        <CAC-fF8SuSWabeCW-nBUwn6VsgFyMfQF9s1f0XZhdjAgiSGzVTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Isaac Boukris <iboukris@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34919 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935650AbcJZWWe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 18:22:34 -0400
Received: by mail-pf0-f171.google.com with SMTP id s8so4002266pfj.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 15:22:03 -0700 (PDT)
In-Reply-To: <CAC-fF8SuSWabeCW-nBUwn6VsgFyMfQF9s1f0XZhdjAgiSGzVTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Oct 2016 21:49:35 +0300
Isaac Boukris <iboukris@gmail.com> wrote:

> Hi Stephen, thanks for looking into this.
> 
> On Wed, Oct 26, 2016 at 8:15 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Tue, 18 Oct 2016 21:46:48 +0300
> > Isaac Boukris <iboukris@gmail.com> wrote:
> >  
> >> Hi again,
> >>
> >> On Sun, Oct 16, 2016 at 11:43 PM, Isaac Boukris <iboukris@gmail.com> wrote:  
> >> > Hello,
> >> >
> >> > The unix(7) man page says that null have no special meaning in
> >> > abstract unix domain socket address (the length is specified
> >> > therefore).
> >> >
> >> > However, when such name (embedding null) is used, ss (and netstat)
> >> > will only show up to the first null occurrence (second technically, if
> >> > we count the null prefix).
> >> > e.g. the name "\0/tmp/fo\0.sock" is displayed as: "@/tmp/fo" (whilst
> >> > strace tool shows it as: sun_path=@"/tmp/fo\0.sock").
> >> >
> >> > Would it be more useful if it printed the whole name and escaped the null?
> >> > If so, would '\0' be ok for escaping the null?  
> >>
> >>
> >> Meanwhile, I've got it to escape the null character with with '\0' as suggested.
> >> Can anyone take a look and advise if I'm on the right track? Thanks!  
> >
> > I did a little investigation and current ss behavior matches the output
> > of other commands (netstat and lsof).  Therefore I really can't see the motivation
> > to fix this.  
> 
> The motivation behind the fix is because the usage of abstract unix
> domain socket is somewhat tricky.
> I've seen it being used incorrectly where for example the addrlen was
> specified as 'sizeof(struct sockaddr_un)' which is ok for regular unix
> sockets because their names are null-terminated, but with abstract
> sockets it causes extra null padding which leads to interoperability
> problems.
> On another occasion, addrlen was incremented to account for an
> additional null-termination byte.
> 
> I was thinking therefore, it could help if the diagnostic tools would
> show all the significant bytes of the name in order to make it clear
> and easy to distinguish.
> 
> On the other hand, I think I've complicated it a little bit with the
> '\0' escaping.
> Perhaps it would suffice to substitute each null character with an '@'
> sign, the same way we do for the null prefix.
> 
> As regarding netstat, I have in fact made a patch for it, but then I
> realized it perhaps isn't its fault as it prints what it reads from
> '/proc/net/unix' which prints the null prefix as '@' but leaves
> subsequent nulls as is (literally, can be seen with 'cat -A').
> So I'm trying to see if '/proc/net/unix' can be fixed to translate all
> null occurrences to '@' sign (not only the prefix).
> This should fix netstat and also (I think) the alternative 'proc' base
> implementation in ss (unix_use_proc).
> 
> What do you think?

Just translating all null characters to @ seems the most consistent and
logical. Also translating other all non-printing characters to something (maybe '?')
might be wise. It would be nice if all utilities output the same thing.
