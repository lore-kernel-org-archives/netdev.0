From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] fix memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Fri, 11 Aug 2006 00:18:44 +0200
Message-ID: <9a8748490608101518s38c6e6a3r9d8599ca3c106ef3@mail.gmail.com>
References: <9a8748490607301451j21589110ifd8677f328b7eba6@mail.gmail.com>
	 <20060730.155640.10246145.davem@davemloft.net>
	 <9a8748490608041630t5e667bf5k3a50dcf148187e6c@mail.gmail.com>
	 <20060804.165931.48505912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, shemminger@osdl.org, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:2618 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750811AbWHJWSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 18:18:49 -0400
Received: by nf-out-0910.google.com with SMTP id a4so678548nfc
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 15:18:44 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060804.165931.48505912.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/08/06, David Miller <davem@davemloft.net> wrote:
> From: "Jesper Juhl" <jesper.juhl@gmail.com>
> Date: Sat, 5 Aug 2006 01:30:49 +0200
>
> > On 31/07/06, David Miller <davem@davemloft.net> wrote:
> > > From: "Jesper Juhl" <jesper.juhl@gmail.com>
> > > Date: Sun, 30 Jul 2006 23:51:20 +0200
> > >
> > > > Looks ok to me.
> > >
> > > I've applied James's version of the fix, thanks everyone.
> > >
> > Hmm, if you are refering to commit
> > 118075b3cdc90e0815362365f3fc64d672ace0d6 -
> > http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=118075b3cdc90e0815362365f3fc64d672ace0d6
> > then I think a mistake has crept in. That commit only initializes
> > 'cnt' to 0 - I don't see how that would fix the leak - looks like you
> > forgot the business end of the patch...
>
> See the commit right before that, the initialize of cnt to
> zero is just to fix a compiler warning that resulted from
> James's version of the fix.
>

Hmm, perhaps I'm going blind, but I don't see it.

The commit right before the one I linked to above is completely
unrelated : "[ATALK]: Make CONFIG_DEV_APPLETALK a tristate."
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9cac2c35e26cc44978df654306bb92d7cfe7e2de

And if I download 2.6.18-rc4 the tcpprobe_read() function (still)
looks like this :


static ssize_t tcpprobe_read(struct file *file, char __user *buf,
                             size_t len, loff_t *ppos)
{
        int error = 0, cnt = 0;
        unsigned char *tbuf;

        if (!buf || len < 0)
                return -EINVAL;

        if (len == 0)
                return 0;

        tbuf = vmalloc(len);
        if (!tbuf)
                return -ENOMEM;

        error = wait_event_interruptible(tcpw.wait,
                                         __kfifo_len(tcpw.fifo) != 0);
        if (error)
                return error;

        cnt = kfifo_get(tcpw.fifo, tbuf, len);
        error = copy_to_user(buf, tbuf, cnt);

        vfree(tbuf);

        return error ? error : cnt;
}


That function still contains the 'tbuf' leak.

I also couldn't find the fix in your git trees at
http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.19.git;a=summary
http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.git;a=summary


So either I'm going blind or a mistake has been made getting the fix
into mainline...


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
