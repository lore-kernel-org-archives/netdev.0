From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP fast open question
Date: Mon, 10 Mar 2014 10:09:06 -0700
Message-ID: <CAK6E8=cJnjReDL+TCv-hKxd1EaAud3T8kdz2C01NK=yYgAgBLQ@mail.gmail.com>
References: <20140308115823.GA3185@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jerry Chu <hkchu@google.com>,
	Xiaochen Wang <xiaochen.wxc@alibaba-inc.com>,
	Zheng Liu <wenqing.lz@taobao.com>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:51356 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbaCJRJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:09:47 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so7571471iec.10
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:09:47 -0700 (PDT)
In-Reply-To: <20140308115823.GA3185@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 8, 2014 at 3:58 AM, Zheng Liu <gnehzuil.liu@gmail.com> wrote:
> Hi all,
>
> Now we are trying to use TCP fast open in our nginx server, and we
> encounter a problem under non-blocking socket.  I appreciate if some one
> can reply this question.  Thanks in advance.
>
> I describe our question here.  we have two machines, one is as server and
> another is as client.  'net.ipv4.tcp_fastopen' on both of them are set to
> 3.  The server program looks like below:
>
>   ...
>   listenfd = socket(AF_INET, SOCK_STREAM, 0);
>   bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
>   int tfo_opt = 1;
>   setsockopt(listenfd, SOL_TCP, TCP_LISTEN_INFO, &tfo_opt, sizeof(tfo_opt));
>   listen(listenfd, 5);
>   connfd = accept(listenfd, (struct sockaddr *)NULL, NULL);
>   recv(connfd, &buf, 4096)
>   ...
>
> The client program:
>
>   ...
>   sockfd = socket(AF_INET, SOCK_STREAM, 0);
>   fcntl(sockfd, F_SETFL, fcntl(sockfd, F_GETFL, 0)|O_NONBLOCK);
>   sendto(sockfd, msg, strlen(msg), MSG_FASTOPEN,
>         (struct sockaddr *)&servaddr, sizeof(servaddr);
>   recv(sockfd, buf, 4096, 0);
>   ...
>
> We use a non-blocking socket to connect the server and send some
> messages.  After calling sendto(2) we always get an EINPROGRESS error.
> We think it is reasonable because connect(2) could also return this
> error with a non-blocking socket and the connection will be established
> later.  The question is *whether or not the data will be sent* after the
> connection is established.  If I understand correctly, sendto(2) will
> return the number of bytes of data queued up in the kernel or sent in
> the SYN packet.  Even though the EINPROGRESS is returned.  If sendto(2)
> returns -1, that means that no data is queued up in kernel or sent in
> the packet.  Please correct me if I miss-understand something.
Correct.
http://tools.ietf.org/html/draft-ietf-tcpm-fastopen-07#appendix-A.1

>
> We run the program in our testing environment, and we use tcpdump(1) to
> capture the packets.  From the result we can see there is no any data
> that is sent.  Then we do another testing that after calling sendto(2)
The first handshake is used to get the Fast Open cookie for future
connections. I suspect you didn't enable Fast Open on the server side.
What're the output of 'sysctl net.ipv4.tcp_fastopen' on your client
and server? pls send the tcpdump traces on both sides as well.

> the client program will sleep for 5 seconds and then call send(2) to
> transfer some data.
>
>   $ ./client xx.xx.xx.xx
>   ret -1 errno 115
>
> The program works well.  So that means that after getting a EINPROGRESS
> error, the program must call send(2) manually.  Is it correct?  If we
> want to avoid this problem, we need to set 'net.ipv4.tcp_fastopen' to
> 0x707 ?
>
> Regards,
>                                                 - Zheng
