From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: TCP fast open question
Date: Sun, 16 Mar 2014 13:57:25 +0800
Message-ID: <20140316055725.GA2659@gmail.com>
References: <20140308115823.GA3185@gmail.com>
 <CAK6E8=cJnjReDL+TCv-hKxd1EaAud3T8kdz2C01NK=yYgAgBLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jerry Chu <hkchu@google.com>,
	Xiaochen Wang <xiaochen.wxc@alibaba-inc.com>,
	Zheng Liu <wenqing.lz@taobao.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:54315 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbaCPFvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 01:51:41 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so4203326pdj.8
        for <netdev@vger.kernel.org>; Sat, 15 Mar 2014 22:51:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAK6E8=cJnjReDL+TCv-hKxd1EaAud3T8kdz2C01NK=yYgAgBLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yuchung,

Sorry for the late reply because of an urgent issue.

On Mon, Mar 10, 2014 at 10:09:06AM -0700, Yuchung Cheng wrote:
> On Sat, Mar 8, 2014 at 3:58 AM, Zheng Liu <gnehzuil.liu@gmail.com> wrote:
> > Hi all,
> >
> > Now we are trying to use TCP fast open in our nginx server, and we
> > encounter a problem under non-blocking socket.  I appreciate if some one
> > can reply this question.  Thanks in advance.
> >
> > I describe our question here.  we have two machines, one is as server and
> > another is as client.  'net.ipv4.tcp_fastopen' on both of them are set to
> > 3.  The server program looks like below:
> >
> >   ...
> >   listenfd = socket(AF_INET, SOCK_STREAM, 0);
> >   bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
> >   int tfo_opt = 1;
> >   setsockopt(listenfd, SOL_TCP, TCP_LISTEN_INFO, &tfo_opt, sizeof(tfo_opt));
> >   listen(listenfd, 5);
> >   connfd = accept(listenfd, (struct sockaddr *)NULL, NULL);
> >   recv(connfd, &buf, 4096)
> >   ...
> >
> > The client program:
> >
> >   ...
> >   sockfd = socket(AF_INET, SOCK_STREAM, 0);
> >   fcntl(sockfd, F_SETFL, fcntl(sockfd, F_GETFL, 0)|O_NONBLOCK);
> >   sendto(sockfd, msg, strlen(msg), MSG_FASTOPEN,
> >         (struct sockaddr *)&servaddr, sizeof(servaddr);
> >   recv(sockfd, buf, 4096, 0);
> >   ...
> >
> > We use a non-blocking socket to connect the server and send some
> > messages.  After calling sendto(2) we always get an EINPROGRESS error.
> > We think it is reasonable because connect(2) could also return this
> > error with a non-blocking socket and the connection will be established
> > later.  The question is *whether or not the data will be sent* after the
> > connection is established.  If I understand correctly, sendto(2) will
> > return the number of bytes of data queued up in the kernel or sent in
> > the SYN packet.  Even though the EINPROGRESS is returned.  If sendto(2)
> > returns -1, that means that no data is queued up in kernel or sent in
> > the packet.  Please correct me if I miss-understand something.
> Correct.
> http://tools.ietf.org/html/draft-ietf-tcpm-fastopen-07#appendix-A.1
> 
> >
> > We run the program in our testing environment, and we use tcpdump(1) to
> > capture the packets.  From the result we can see there is no any data
> > that is sent.  Then we do another testing that after calling sendto(2)
> The first handshake is used to get the Fast Open cookie for future
> connections. I suspect you didn't enable Fast Open on the server side.
> What're the output of 'sysctl net.ipv4.tcp_fastopen' on your client
> and server? pls send the tcpdump traces on both sides as well.

Sorry, let me clarify the description please.  We can capture the syn
packet without data.  So that means that client has issued a cookie
request.  My question is when the data could be sent out.

Here I miss understand the behaviour when the program is the first time
to call sendto(2).  As RFC draft of TFO described, sendto(2) will return
-1 with EINPROGRESS error if the cookie is not available locallly.  That
means that we need to call write(2) to send the data after the connection
is established.  Namely, after getting -1 with EINPROGRESS, the caller
must call write(2) again later.  Now this problem has been solved.

Thanks for your help,
                                                - Zheng
