From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection
 establishment with the data
Date: Fri, 23 Mar 2012 12:03:36 -0700
Message-ID: <CAK6E8=dnYBLQm4eDh4HOeN_O8uRy8Gvf=PeuT69+6rycjRwRfg@mail.gmail.com>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
 <1332374452.9433.15.camel@edumazet-glaptop> <CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
 <1332458037.6521.12.camel@edumazet-glaptop> <1332458223.6521.14.camel@edumazet-glaptop>
 <CAK3+h2yFeww84QStvugyaYGfWsL2cw3TnG3CoeLk-q2pQ70_+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45298 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030306Ab2CWTD5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 15:03:57 -0400
Received: by iagz16 with SMTP id z16so5005763iag.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 12:03:57 -0700 (PDT)
In-Reply-To: <CAK3+h2yFeww84QStvugyaYGfWsL2cw3TnG3CoeLk-q2pQ70_+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vincent

On Fri, Mar 23, 2012 at 8:38 AM, Vincent Li <vincent.mc.li@gmail.com> w=
rote:
> On Thu, Mar 22, 2012 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> On Thu, 2012-03-22 at 16:13 -0700, Eric Dumazet wrote:
>>
>>> A third possibility (reading the code) if you use non blocking IO, =
is to
>>> send() a message right after connect()
>>>
>>>
>>
>> Or use the auto connect on sendto() more probably...
>>
>> That combines the connect() and send()
>>
>
> thanks,
>
> I got the TCP_QUICKACK working, but not the non blocking IO,
> basically, what I did is
>
> =A0if((sock =3D socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
> =A0 =A0perror("Can't create TCP socket");
> =A0 =A0return 0;
> =A0}
>
> =A0val =3D Fcntl(sock, F_GETFL, 0);
> =A0Fcntl(sock, F_SETFL, val | O_NONBLOCK);
>
>
> =A0ip =3D get_ip(host);
> =A0fprintf(stderr, "IP is %s\n", ip);
> =A0remote =3D (struct sockaddr_in *)malloc(sizeof(struct sockaddr_in =
*));
> =A0remote->sin_family =3D AF_INET;
> =A0tmpres =3D inet_pton(AF_INET, ip, (void *)(&(remote->sin_addr.s_ad=
dr)));
> =A0if( tmpres < 0)
> =A0{
> =A0 =A0perror("Can't set remote->sin_addr.s_addr");
> =A0 =A0return 0;
> =A0}else if(tmpres =3D=3D 0)
> =A0{
> =A0 =A0fprintf(stderr, "%s is not a valid IP address\n", ip);
> =A0 =A0return 0;
> =A0}
> =A0remote->sin_port =3D htons(PORT);
>
> char *query =3D "GET / HTTP/1.0\r\nHost: 127.0.0.1\r\n\r\n";
>
> tmpres =3D sendto(sock, query, strlen(query), 0, (struct sockaddr
> *)remote, sizeof(struct sockaddr));
>
> =A0maybe I mis-interpret you.
>
> Vincent
AFAICT the feature that Eric refers to is TCP Fast Open that I am
still testing and have not yet submit to netdev.

But one way to achieve that currently is doing a non-blocking connect
then a blocking write.

I just tried this on 2.6 machine to a remote server

fcntl(sd, F_SETFL, fcntl(sd, F_GETFL, 0) | O_NONBLOCK);
connect(sd, ...);
fcntl(sd, F_SETFL, fcntl(sd, F_GETFL, 0) & ~O_NONBLOCK);
sendto(sd, buf, buf, 0, ...);

The key is that the socket has to be in progress of connecting
when application calls write/sendto(2). If you are testing on loopback,
the connect might finish before sendto so this won't work.

HTH
