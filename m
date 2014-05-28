From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Wed, 28 May 2014 14:20:10 +0200
Message-ID: <5385D47A.3070401@gmail.com>
References: <536101C9.9090601@gmail.com> <CAKgNAkgA_xTfRZhpyVwuACpCY7xMK89e0bK4PuVMG9reNV6Skw@mail.gmail.com> <20140512143451.GB13801@kernel.org> <20140521210535.GA5414@kernel.org> <537E0961.8040005@gmail.com> <20140526134647.GB8176@kernel.org> <20140526211706.GA25474@kernel.org> <5384BEC5.2080607@gmail.com> <20140527192115.GD25474@kernel.org> <CAKgNAkht1vubHueYPpkRu_W5B8OYW3rPUkHeLEq5WMVbCvO47w@mail.gmail.com> <20140527203010.GA2764@kernel.org>
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
To: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140527203010.GA2764-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/27/2014 10:30 PM, Arnaldo Carvalho de Melo wrote:
> Em Tue, May 27, 2014 at 09:28:37PM +0200, Michael Kerrisk (man-pages) escreveu:
>> On Tue, May 27, 2014 at 9:21 PM, Arnaldo Carvalho de Melo
>> <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org> wrote:
>>> Em Tue, May 27, 2014 at 06:35:17PM +0200, Michael Kerrisk (man-pages) escreveu:
>>>> On 05/26/2014 11:17 PM, Arnaldo Carvalho de Melo wrote:
>>>>> Can you try the attached patch on top of the first one?
>>>
>>>> Patches on patches is a way to make your testers work unnecessarily
>>>> harder. Also, it means that anyone else who was interested in this
>>>
>>> It was meant to highlight the changes with regard to the previous patch,
>>> i.e. to make things easier for reviewing.
>>
>> (I don't think that works...)
> 
> Lets try both then, 

That's better!

> attached goes the updated patch, and this is the
> diff to the last combined one:
> 
> diff --git a/net/socket.c b/net/socket.c
> index 310a50971769..379be43879db 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -2478,8 +2478,7 @@ SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
>  
>  	datagrams = __sys_recvmmsg(fd, mmsg, vlen, flags, &timeout_sys);
>  
> -	if (datagrams > 0 &&
> -	    copy_to_user(timeout, &timeout_sys, sizeof(timeout_sys)))
> +	if (copy_to_user(timeout, &timeout_sys, sizeof(timeout_sys)))
>  		datagrams = -EFAULT;
>  
>  	return datagrams;
>  
> ------------------------------------------
> 
> This is a quick thing just to show where the problem lies, need to think
> how to report an -EFAULT at this point properly, i.e. look at
> __sys_recvmmsg for something related (returning the number of
> successfully copied datagrams to userspace while storing the error for
> subsequent reporting):
> 
>         if (err == 0)
>                 return datagrams;
> 
>         if (datagrams != 0) {
>                 /*
>                  * We may return less entries than requested (vlen) if
>                  * the
>                  * sock is non block and there aren't enough
>                  * datagrams...
>                  */
>                 if (err != -EAGAIN) {
>                         /*
>                          * ... or  if recvmsg returns an error after we
>                          * received some datagrams, where we record the
>                          * error to return on the next call or if the
>                          * app asks about it using getsockopt(SO_ERROR).
>                          */
>                         sock->sk->sk_err = -err;
>                 }
> 
>                 return datagrams;
>         }
> 
> I.e. userspace would have to use getsockopt(SO_ERROR)... need to think
> more about it, sidetracked now, will be back to this.
> 
> Anyway, attached goes the current combined patch.

So, I applied against net-next as you suggested offlist.
Builds and generally tests fine. Some observations:

* In the case that the call is interrupted by a signal handler and no
  datagrams have been received, the call fails with EINTR, as expected.

* The call always updates 'timeout', both in the success case and in the
  EINTR case. (That seems fine.)

But, another question...

In the case that the call is interrupted by a signal handler and some
datagrams have already been received, then the call succeeds, and
returns the number of datagrams received, and 'timeout' is updated with
the remaining time. Maybe that's the right behavior, but I just want to
check. There is at least one other possibility:

* Fetch no datagrams (i.e., the datagrams are left to receive in a
  future call), and the call fails with EINTR, and 'timeout' is updated.

Maybe that possibility is hard to implement (not sure). But my main point
is to make the current behavior clear, note the alternative, and ask:
is the current behavior the best choice. (I'm not saying it's not, but I
do want the choice to be a conscious one.)

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
