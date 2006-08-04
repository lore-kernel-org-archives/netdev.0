From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] fix memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Sat, 5 Aug 2006 01:30:49 +0200
Message-ID: <9a8748490608041630t5e667bf5k3a50dcf148187e6c@mail.gmail.com>
References: <20060730142922.7c1d4f7d@localhost.localdomain>
	 <Pine.LNX.4.64.0607301747170.26424@d.namei>
	 <9a8748490607301451j21589110ifd8677f328b7eba6@mail.gmail.com>
	 <20060730.155640.10246145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, shemminger@osdl.org, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:52175 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161473AbWHDXav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 19:30:51 -0400
Received: by nf-out-0910.google.com with SMTP id k26so56049nfc
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2006 16:30:49 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060730.155640.10246145.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/07/06, David Miller <davem@davemloft.net> wrote:
> From: "Jesper Juhl" <jesper.juhl@gmail.com>
> Date: Sun, 30 Jul 2006 23:51:20 +0200
>
> > Looks ok to me.
>
> I've applied James's version of the fix, thanks everyone.
>
Hmm, if you are refering to commit
118075b3cdc90e0815362365f3fc64d672ace0d6 -
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=118075b3cdc90e0815362365f3fc64d672ace0d6
then I think a mistake has crept in. That commit only initializes
'cnt' to 0 - I don't see how that would fix the leak - looks like you
forgot the business end of the patch...

The function still looks like this after that commit :

114 static ssize_t tcpprobe_read(struct file *file, char __user *buf,
115 size_t len, loff_t *ppos)
116 {
117 int error = 0, cnt = 0;
118 unsigned char *tbuf;
119
120 if (!buf || len < 0)
121 return -EINVAL;
122
123 if (len == 0)
124 return 0;
125
126 tbuf = vmalloc(len);
127 if (!tbuf)
128 return -ENOMEM;
129
130 error = wait_event_interruptible(tcpw.wait,
131 __kfifo_len(tcpw.fifo) != 0);
132 if (error)
133 return error;
134

    ^^^--- we are still leaking 'tbuf' here.


135 cnt = kfifo_get(tcpw.fifo, tbuf, len);
136 error = copy_to_user(buf, tbuf, cnt);
137
138 vfree(tbuf);
139
140 return error ? error : cnt;
141 }


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
