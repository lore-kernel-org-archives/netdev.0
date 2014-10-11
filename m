From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Netlink mmap tx security?
Date: Sat, 11 Oct 2014 15:29:17 -0700
Message-ID: <CALCETrWfQe5H2Ht7cjCQLfUw+XUcRvga_H93esaWpAp37=noZg@mail.gmail.com>
References: <CALCETrWsCqy7KEKPTOeHjrO1c2JE1E_seO_J+yA=sYFhS11NXQ@mail.gmail.com>
 <CALCETrVuREGVKwrni61DEg=Tgjc7x41WYtrEiDMqMvwVFXfybw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:65181 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbaJKW3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 18:29:40 -0400
Received: by mail-la0-f51.google.com with SMTP id ge10so5036917lab.10
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2014 15:29:38 -0700 (PDT)
In-Reply-To: <CALCETrVuREGVKwrni61DEg=Tgjc7x41WYtrEiDMqMvwVFXfybw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 12, 2014 3:08 PM, "Andy Lutomirski" <luto@amacapital.net> wrote:
>
> [moving to netdev -- this is much lower impact than I thought, since
> you can't set up a netlink mmap ring without global CAP_NET_ADMIN]

Did anything ever happen here?  Despite not being a privilege
escalation in the normal sense, it's still a bug, and it's still a
fairly easy bypass of module signatures.


--Andy

>
> On Wed, May 7, 2014 at 5:46 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> > Disclaimer: I haven't tried to write a proof-of-concept, so I could be
> > wrong here.
> >
> >     /* Netlink messages are validated by the receiver before processing.
> >      * In order to avoid userspace changing the contents of the message
> >      * after validation, the socket and the ring may only be used by a
> >      * single process, otherwise we fall back to copying.
> >      */
> >     if (atomic_long_read(&sk->sk_socket->file->f_count) > 2 ||
> >         atomic_read(&nlk->mapped) > 1)
> >         excl = false;
> >
> > How is this possibly safe?  I think it's broken for at least three reasons:
> >
> > 1. Shouldn't that be atomic_long(read(&f_count) > 1))?
> >
> > 2. threads
> >
> > 3. process_vm_writev
> >
> > I wouldn't be surprised if RDMA and AIO also break this assumption.
> >
> > Does anything rely on mmapped netlink tx being fast?  If not, can this
> > code just be deleted?
> >
> > For that matter, does anything rely on mmapped netlink tx at all?
> >
> > (On a non-KASLR, non-SMEP system, this probably gives reliable kernel
> > code execution.)
> >
> > For that matter, netlink_mmap_sendmsg also appears to vulnerable to a
> > TOCTOU attack via hdr.
> >
