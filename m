From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 21:16:43 +0300
Message-ID: <200807182116.43451.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807182004.44664.opurdila@ixiacom.com> <20080718175341.GA21496@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759254AbYGRSTD@vger.kernel.org>
In-Reply-To: <20080718175341.GA21496@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 July 2008, Evgeniy Polyakov wrote:
> Hi.
>
> On Fri, Jul 18, 2008 at 08:04:44PM +0300, Octavian Purdila 
(opurdila@ixiacom.com) wrote:
> > Suppose we have 20 packets in the socket queue and the pipe is empty and
> > the application calls splice(sock, pipe, 17, flags=0).
> >
> > Then, tcp_splice_read will be called, which in turn calls tcp_read_sock.
> >
> > tcp_read_sock will loop until all the 17 bytes will be read from the
> > socket. tcp_read_sock calls skb_splice_bits which calls splice_to_pipe.
>
> How come?
> spd_fill_page() should fail when it will be called for the 17'th skb and
> all reading from the socket will return, and thus can be sent to the
> file.
>

spd_fill_page work with the splice_pipe_descriptor declared in 
skb_splice_bits, thus spd_fill_page does not have visibility across multiple 
skb_splice_bits calls.

> > Now while skb_splice_bits is carefull to only put a maximum of
> > PIPE_BUFFERS during its iteration, due to the looping in tcp_read_sock,
> > we will end up with 17 calls to splice_to_pipe. Thus on the 17th call,
> > splice_to_pipe will block.
>
> Where exactly?
> Why
> tcp_splice_data_recv()->skb_splice_bits()->__skb_splice_bits()->spd_fill_pa
>ge() callchain does not return error and that pipe is full?


Ok, let me try to move through the function calls:

tcp_read_sock
 ... -> skb_splice_bits -> spd_fill_page; 
  on return (spd->nr_page is 1 and pipe->nrbufs is 1)
 ... -> skb_splice_bits -> spd_fill_page; 
  on return (spd->nr_page is 1 and pipe->nrbufs is 2)
 ... -> skb_splice_bits -> spd_fill_page; 
  on return (spd->nr_page is 1 and pipe->nrbufs is 3)
...

and so on until pipe->nrbufs is 16. At than point, we will block in pipe_wait, 
inside splice_to_pipe.

Thanks,
tavi
