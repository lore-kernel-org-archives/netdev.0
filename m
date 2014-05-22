From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Thu, 22 May 2014 16:27:45 +0200
Message-ID: <537E0961.8040005@gmail.com>
References: <536101C9.9090601@gmail.com> <CAKgNAkgA_xTfRZhpyVwuACpCY7xMK89e0bK4PuVMG9reNV6Skw@mail.gmail.com> <20140512143451.GB13801@kernel.org> <20140521210535.GA5414@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?UTF-8?B?T25kxZllaiBCw61sa2E=?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1v?= =?UTF-8?B?bnQ=?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	Chris Friesen <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140521210535.GA5414-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

On 05/21/2014 11:05 PM, Arnaldo Carvalho de Melo wrote:
> Em Mon, May 12, 2014 at 11:34:51AM -0300, Arnaldo Carvalho de Melo escreveu:
>> Em Mon, May 12, 2014 at 12:15:25PM +0200, Michael Kerrisk (man-pages) escreveu:
>>> Hi Arnaldo,
>  
>>> Ping!
> 
>> I acknowledge the problem, the timeout has to be passed to the
>> underlying ->recvmsg() implementations that should return the time spent
>> waiting for each packet, so that we can accrue that at recvmmsg level.
>  
>> We can do either passing an extra timeout parameter to the recvmsg
>> implementations or using some struct sock member to specify that
>> timeout.
>  
>> The first approach is intrusive, touches tons of files, so I'll try
>> making it all mostly transparent by hooking into sock_rcvtimeo()
>> somehow.
> 
> But after thinking a bit more, looks like we need to do that, please
> take a look at the attached patch to see if it addresses the problem.
> 
> Mostly it adds a new timeop to the per protocol recvmsg()
> implementations, that, if not NULL, should be used instead of
> SO_RCVTIMEO.
> 
> since the underlying recvmsg implementations already check that timeout,
> return what is remaining, that will then be used in subsequent recvmsg
> calls, at the end we just convert it back to timespec format.
> 
> In most cases it is just passed to skb_recv_datagram, that will check
> the pointer, use it and update if not NULL.
> 
> Should have no problems, but I only did a boot with a system with this
> patch applied, no problems noticed on a normal desktop session, ssh,
> etc.

Thanks! I applied this patch against 3.15-rc6.

recvmmsg() now (mostly) does what I expect: 
* it waits until either the timeout expires or vlen messages 
  have been received
* If no message is received before timeout, it returns -1/EAGAIN.
* If vlen messages are received before the timeout expires, then
  the remaining time is returned in timeout.

One question: in the event that the call is interrupted by a signal 
handler, it fails (as expected) with EINTR, but the 'timeout' value is 
not updated with the remaining time on the timer. Would it be desirable 
to emulate the behavior of select() (and other syscalls) in this 
respect, and instead return the remaining time if interrupted by 
a signal?

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
