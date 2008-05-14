From: "Shirish Pargaonkar" <shirishpargaonkar@gmail.com>
Subject: Re: autotuning of send buffer size of a socket
Date: Wed, 14 May 2008 09:22:11 -0500
Message-ID: <4a4634330805140722x3494626bpc78dd92831d384a@mail.gmail.com>
References: <4a4634330805121200m739e67bdife66c3ad81af1ceb@mail.gmail.com>
	 <1210639647.2753.10.camel@w-sridhar2.beaverton.ibm.com>
	 <4a4634330805130654n1aafbf10pa73da07e792f7b@mail.gmail.com>
	 <1210722503.11436.9.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: "Sridhar Samudrala" <sri@us.ibm.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1210722503.11436.9.camel@w-sridhar2.beaverton.ibm.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/13/08, Sridhar Samudrala <sri@us.ibm.com> wrote:
> On Tue, 2008-05-13 at 08:54 -0500, Shirish Pargaonkar wrote:
> > On 5/12/08, Sridhar Samudrala <sri@us.ibm.com> wrote:
> > > On Mon, 2008-05-12 at 14:00 -0500, Shirish Pargaonkar wrote:
> > > > Hello,
> > > >
> > > > kernel_sendmsg fails with error EAGAIN, yet I no matter how long I try,
> > > > I still get the same error and do not see the send buffer size of a socket
> > > > changing (increasing)
> > > >
> > > > The initial buffer sizes are 16384 for send side and 87380 for the receive
> > > > side but I see receive side buffer tuning but do not see the same with
> > > > send side.
> > > >
> > > > If tcp does not see a need to increase the send buffer size, wonder why I
> > > > get EAGAIN error on this non-blocking socket for kernel_sendmsg!
> > >
> > > I think the send buffer auto-tuning doesn't happen here because there is
> > > already congestion window worth of packets sent that are not yet acknowledged.
> > > See tcp_should_expand_sndbuf().
> > >
> > > Also, the comments for tcp_new_space() says that sndbuf expansion does
> > > not work well with largesends. What is the size of your sends?
> > >
> > > Adding netdev to the CC list.
> > >
> > > Thanks
> > > Sridhar
> > >
> > > >
> > > > I do subscribe to this mailing list so, please send your responses to this
> > > > mail address.
> > > >
> > > > Regards,
> > > >
> > > > Shirish
> > > >
> > > > --------------------------------------------------------------------------------------------------
> > > > uname -r
> > > > 2.6.18-91.el5
> > > >
> > > >  sysctl -a
> > > >
> > > > net.ipv4.tcp_rmem = 4096        87380   4194304
> > > > net.ipv4.tcp_wmem = 4096        16384   4194304
> > > > net.ipv4.tcp_mem = 98304        131072  196608
> > > >
> > > > net.core.rmem_default = 126976
> > > > net.core.wmem_default = 126976
> > > > net.core.rmem_max = 131071
> > > > net.core.wmem_max = 131071
> > > >
> > > > net.ipv4.tcp_window_scaling = 1
> > > > net.ipv4.tcp_timestamps = 1
> > > > net.ipv4.tcp_moderate_rcvbuf = 1
> > > >
> > > >
> > > > cat /proc/sys/net/ipv4/tcp_moderate_rcvbuf
> > > > 1
> > > >
> > > >
> > > > CIFS VFS: sndbuf 16384 rcvbuf 87380
> > > >
> > > > CIFS VFS: sends on sock 0000000009903100, sendbuf 34776, rcvbuf 190080
> > > > stuck for 32 seconds,
> > > > error: -11
> > > > CIFS VFS: sends on sock 0000000009903a00, sndbuf 34776, rcvbuf 138240
> > > > stuck for 32 seconds,
> > > > error: -11
> > > >
> > > >
> > > > CIFS VFS: sends on sock 0000000009903100, sndbuf 34776, rcvbuf 126720
> > > > stuck for 64 seconds,
> > > > error: -11
> > > >
> > > > CIFS VFS: sends on sock 0000000009903100, sndbuf 34776, rcvbuf 222720
> > > > stuck for 256 seconds,
> > > > error: -11
> > > >
> > > > I see the socket receive buffer size fluctuating (tcp_moderate_rcvbuf
> > > > is 1) but not
> > > > the socket send buffer size.
> > > > The send buffer size remains fixed, the auto-tuning for send side is
> > > > enabled by default,so I do not see it happening here no matter how
> > > > long the c ode tries to
> > > > kernel_sendmsg after receiving EAGAIN return code.
>
> > Sridhar,
> >
> > The size of the sends is 56K.
>
> As David pointed out, the send size may not be an issue.
> When do you see these stalls? Do they happen frequently or only under
> stress?
>
> It could be that the receiver is not able to drain the receive queue
> causing the send path to be blocked. You could run netstat -tn on
> the receiver and take a look at 'Recv-Q' output to see if there is
> data pending in the receive queue.
>
> Thanks
> Sridhar
>
>

These errors are logged during stress testing, not otherwise.
I am running fsstress on 10 shares mounted  on this machine running cifs client
which are exported by a samba server on another machine.

I was running netstat -tn on the machine running samba server in a while loop
in a script untill errors started showing up on the cifs client.
Some of the entries captured in the file are listed below, rest of them
(34345 out of 34356 ) have Recv-Q as 0.

tcp    10080      0 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp    10080      0 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp    10080     51 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp    10983   7200 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp    11884  10080 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp    11925   1440 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp    12116   7200 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp    12406      0 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp      290      0 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp     5028  11627 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED
tcp     8640     51 123.456.78.238:445          123.456.78.239:39538
     ESTABLISHED

It is hard to match exact netstat -tn output on the machine running
samba server
with the errors on machine running cifs client but as soon as I saw the errors
appearing on the client, I ran netstat -tn command on the server and found
Recv-Q entry was 0 (may be the Recv-Q entries were processed/cleared by
the samba server by then).

Regards,

Shirish
