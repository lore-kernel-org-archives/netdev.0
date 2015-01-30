From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 2/6] net: Add STT tunneling protocol.
Date: Thu, 29 Jan 2015 21:02:29 -0800
Message-ID: <CALnjE+okwQ0FBzq5YVSKDgkdo=u=DhCkX-Voo6qeSwOMQD-S0w@mail.gmail.com>
References: <1422574170-1889-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx-gs0G5+uJX3kYc6-1piqVqetcUx2EgrmWOAzZ2j5Q1yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:57701 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750708AbbA3FCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 00:02:32 -0500
Received: by mail-ie0-f178.google.com with SMTP id rp18so1030918iec.9
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 21:02:29 -0800 (PST)
In-Reply-To: <CA+mtBx-gs0G5+uJX3kYc6-1piqVqetcUx2EgrmWOAzZ2j5Q1yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 8:10 PM, Tom Herbert <therbert@google.com> wrote:
> On Thu, Jan 29, 2015 at 3:29 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> This adds a device level support for Stateless TCP Tunnel (STT)
>> protocol encapsulation. NF-hook is used for receiving STT
>> packets from networking stack.
>> Open vSwitch can be used for configuring, set up and tear down
>> STT tunnels.
>>
>> The protocol is documented at
>> http://www.ietf.org/archive/id/draft-davie-stt-06.txt
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> ---
>>  include/net/stt.h |   59 +++
>>  net/ipv4/Kconfig  |   11 +
>>  net/ipv4/Makefile |    1 +
>>  net/ipv4/stt.c    | 1398 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 1469 insertions(+)
>>  create mode 100644 include/net/stt.h
>>  create mode 100644 net/ipv4/stt.c
>>

....
>> +
>> +static void tcp_sock_release(struct socket *sock)
>> +{
>> +       kernel_sock_shutdown(sock, SHUT_RDWR);
>> +       sk_release_kernel(sock->sk);
>> +}
>> +
>> +static int tcp_sock_create4(struct net *net, __be16 port,
>> +                           struct socket **sockp)
>> +{
>> +       int err;
>> +       struct socket *sock = NULL;
>> +       struct sockaddr_in tcp_addr;
>> +
>> +       err = sock_create_kern(AF_INET, SOCK_STREAM, 0, &sock);
>
> Should be: err = sock_create_kern(AF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
>

ok.

>> +       if (err < 0)
>> +               goto error;
>> +
>> +       sk_change_net(sock->sk, net);
>> +
>> +       memset(&tcp_addr, 0, sizeof(tcp_addr));
>> +       tcp_addr.sin_family = AF_INET;
>> +       tcp_addr.sin_addr.s_addr = htonl(INADDR_ANY);
>> +       tcp_addr.sin_port = port;
>> +       err = kernel_bind(sock, (struct sockaddr *)&tcp_addr,
>> +                         sizeof(tcp_addr));
>
> I think there should also be a kernel_listen also. I'm a little
> surprised that this could work without it, it doesn't seem like we
> should be finding closed sockets on input. In any case even if that
> did work, it is quite annoying that the socket doesn't appear in
> "netstat -ant".
>

This is fake TCP socket. it is created to gain exclusive access to the
TCP port. STT receives packet from nf-hook, so no need to listening
TCP socket.
I am not updating any socket stats so I do not think you will see any
socket stats.


>> +       if (err < 0)
>> +               goto error;
>> +
>> +       *sockp = sock;
>> +       return 0;
