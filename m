From: "Shirish Pargaonkar" <shirishpargaonkar@gmail.com>
Subject: Re: autotuning of send buffer size of a socket
Date: Thu, 15 May 2008 13:49:07 -0500
Message-ID: <4a4634330805151149m78479f49q25eccadcc624dc5f@mail.gmail.com>
References: <4a4634330805121200m739e67bdife66c3ad81af1ceb@mail.gmail.com>
	 <1210639647.2753.10.camel@w-sridhar2.beaverton.ibm.com>
	 <4a4634330805142118l47d023caxf79a45273f4f7a28@mail.gmail.com>
	 <4a4634330805150800h42414f48l3c0b36e261d803b9@mail.gmail.com>
	 <1210873215.22262.14.camel@w-sridhar2.beaverton.ibm.com>
	 <4a4634330805151103y4073f650p56ac3e88d8cc3c5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: "Sridhar Samudrala" <sri@us.ibm.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4a4634330805151103y4073f650p56ac3e88d8cc3c5e@mail.gmail.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/15/08, Shirish Pargaonkar <shirishpargaonkar@gmail.com> wrote:
> On 5/15/08, Sridhar Samudrala <sri@us.ibm.com> wrote:
> > On Thu, 2008-05-15 at 10:00 -0500, Shirish Pargaonkar wrote:
> > > On 5/14/08, Shirish Pargaonkar <shirishpargaonkar@gmail.com> wrote:
> > > > On 5/12/08, Sridhar Samudrala <sri@us.ibm.com> wrote:
> > > > > On Mon, 2008-05-12 at 14:00 -0500, Shirish Pargaonkar wrote:
> > > > > > Hello,
> > > > > >
> > > > > > kernel_sendmsg fails with error EAGAIN, yet I no matter how long I try,
> > > > > > I still get the same error and do not see the send buffer size of a socket
> > > > > > changing (increasing)
> > > > > >
> > > > > > The initial buffer sizes are 16384 for send side and 87380 for the receive
> > > > > > side but I see receive side buffer tuning but do not see the same with
> > > > > > send side.
> > > > > >
> > > > > > If tcp does not see a need to increase the send buffer size, wonder why I
> > > > > > get EAGAIN error on this non-blocking socket for kernel_sendmsg!
> > > > >
> > > > > I think the send buffer auto-tuning doesn't happen here because there is
> > > > > already congestion window worth of packets sent that are not yet acknowledged.
> > > > > See tcp_should_expand_sndbuf().
> > > >
> > > > Sridhar,
> > > >
> > > > The unacked (packets_out) is 7 and snd_cwnd is 9, so that should not be
> > > > the case for tcp_should_expand_sndbuf to return 0 right?
> >
> > It looks like sndbuf expansion via tcp_should_expand_sndbuf() happens
> > only in response to acks/data from the receiver.
> >   tcp_rcv_established/tcp_rcv_state_process
> >     tcp_data_snd_check
> >        tcp_check_space
> >          tcp_new_space
> >            tcp_should_expand_sndbuf
> > auto-tuning doesn't increase sndbuf when trying to send more data.
> >
> > > >
> > > > >
> > > > > Also, the comments for tcp_new_space() says that sndbuf expansion does
> > > > > not work well with largesends. What is the size of your sends?
> > > > >
> > > > > Adding netdev to the CC list.
> > > > >
> > > > > Thanks
> > > > > Sridhar
> > > > >
> > > > > >
> > > > > > I do subscribe to this mailing list so, please send your responses to this
> > > > > > mail address.
> > > > > >
> > > > > > Regards,
> > > > > >
> > > > > > Shirish
> > > > > >
> > > > > > --------------------------------------------------------------------------------------------------
> > > > > > uname -r
> > > > > > 2.6.18-91.el5
> > > > > >
> > > > > >  sysctl -a
> > > > > >
> > > > > > net.ipv4.tcp_rmem = 4096        87380   4194304
> > > > > > net.ipv4.tcp_wmem = 4096        16384   4194304
> > > > > > net.ipv4.tcp_mem = 98304        131072  196608
> > > > > >
> > > > > > net.core.rmem_default = 126976
> > > > > > net.core.wmem_default = 126976
> > > > > > net.core.rmem_max = 131071
> > > > > > net.core.wmem_max = 131071
> > > > > >
> > > > > > net.ipv4.tcp_window_scaling = 1
> > > > > > net.ipv4.tcp_timestamps = 1
> > > > > > net.ipv4.tcp_moderate_rcvbuf = 1
> > > > > >
> > > > > >
> > > > > > cat /proc/sys/net/ipv4/tcp_moderate_rcvbuf
> > > > > > 1
> > > > > >
> > > > > >
> > > > > > CIFS VFS: sndbuf 16384 rcvbuf 87380
> > > > > >
> > > > > > CIFS VFS: sends on sock 0000000009903100, sendbuf 34776, rcvbuf 190080
> > > > > > stuck for 32 seconds,
> > > > > > error: -11
> > > > > > CIFS VFS: sends on sock 0000000009903a00, sndbuf 34776, rcvbuf 138240
> > > > > > stuck for 32 seconds,
> > > > > > error: -11
> > > > > >
> > > > > >
> > > > > > CIFS VFS: sends on sock 0000000009903100, sndbuf 34776, rcvbuf 126720
> > > > > > stuck for 64 seconds,
> > > > > > error: -11
> > > > > >
> > > > > > CIFS VFS: sends on sock 0000000009903100, sndbuf 34776, rcvbuf 222720
> > > > > > stuck for 256 seconds,
> > > > > > error: -11
> > > > > >
> > > > > > I see the socket receive buffer size fluctuating (tcp_moderate_rcvbuf
> > > > > > is 1) but not
> > > > > > the socket send buffer size.
> > > > > > The send buffer size remains fixed, the auto-tuning for send side is
> > > > > > enabled by default,so I do not see it happening here no matter how
> > > > > > long the c ode tries to
> > > > > > kernel_sendmsg after receiving EAGAIN return code.
> > > > > > --
> > > > > > To unsubscribe from this list: send the line "unsubscribe linux-net" in
> > > > > > the body of a message to majordomo@vger.kernel.org
> > > > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > >
> > > > >
> > > >
> > >
> > > I put some printk in tcp.c (in function tcp_sendmsg)
> > > sndbuf grows from 16384 to 34776 but never beyond it.
> > >
> > >
> > > CIFS VFS: sndbuf 16384 rcvbuf 87380 rcvtimeo 0x7fffffffffffffff
> > >
> > > !sk_stream_memory_free queued 18288, sndbuf 16384
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 28448, sndbuf 27048
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 28448, sndbuf 27048
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 32512, sndbuf 30912
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > > !sk_stream_memory_free queued 36576, sndbuf 34776
> > > sk_stream_wait_memory with 0 returned -11
> > >
> > > and so on and the sndbuf does not grow beyond 34776
> >
> > So there is outstanding data(sk_wmem_queued) that is not getting
> > acked.
> > If you set the sndbuf manually to a higher value, does it solve
> > the problem or only delay the stalls?
> >
> > Thanks
> > Sridhar
> >
> >
>
> Sridhar,
>
> snd_cwnd goes from 6 to 7 to 8 to 9 and is capped at that value.  That is how
> sndbuf grows upto but does not grow beyond 34776.
>
> If I set the sndbuf manully, it just delays stalls.  I have gone as high as 1MB
> of send size and that prevents from logging these errors longer but
> eventually it does.
>
> Regards,
>
> Shirish
>

I take it back, sndbuf has gone as high as
sk->sk_sndbuf 258888
and snd_cwnd has gone as high as 67.
