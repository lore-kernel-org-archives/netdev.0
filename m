From: Ashwin Rao <ashwin.shirvanthe@gmail.com>
Subject: Re: Restricting payload size in do_tcp_sendpages.
Date: Thu, 1 Mar 2012 18:30:42 +0100
Message-ID: <CAJNbMrwrNZkMQcBJ12QjrVYbC_1HR0FBcCF44d3dC7kOopSAoA@mail.gmail.com>
References: <CAJNbMryYORXmp0CPhL9zt8ne5P5yOKvNLsqnjeNwb4m0OAQeiQ@mail.gmail.com>
	<1330617525.2465.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:39558 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab2CARap convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 12:30:45 -0500
Received: by ggnh1 with SMTP id h1so367561ggn.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 09:30:44 -0800 (PST)
In-Reply-To: <1330617525.2465.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 1, 2012 at 4:58 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 01 mars 2012 =E0 16:16 +0100, Ashwin Rao a =E9crit :
>> Hi,
>>
>> I would like to perform some experiments where I want TCP to send
>> packets of size less than the MSS even more than an MSS worth of dat=
a
>> is available in the TCP buffers. =A0I am performing these experiment=
s to
>> submit a patch that can avoid synchronization of TCP flows. I have
>> modified the following code in the function do_tcp_sendpages in the
>> file net/ipv4/tcp.c. =A0For testing purposes I have currently set th=
e
>> mss_now to half of the value that would have been typically used. I
>> have even updated the size_goal which controls the maximum size that
>> can be sent when offloading is enabled. To avoid coalescing smaller
>> skbs I have even set the can_coalesce to 0. Despite these changes th=
e
>> frames sent over the Ethernet have the length of 1514 bytes. I would
>> like to know which function is responsible for coalescing these
>> packets despite forcing a small segment size.
>>
>> *** linux-3.2.6/net/ipv4/tcp.c
>> --- linux-3.2.6-modified/net/ipv4/tcp.c
>> *************** static ssize_t do_tcp_sendpages(struct s
>> *** 774,779 ****
>> --- 774,783 ----
>> =A0 =A0 =A0 clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
>>
>> =A0 =A0 =A0 mss_now =3D tcp_send_mss(sk, &size_goal, flags);
>> + =A0 =A0 /* hack begin */
>> + =A0 =A0 mss_now =3D mss_now >> 1;
>> + =A0 =A0 size_goal =3D mss_now;
>> + =A0 =A0 /* hack end */
>> =A0 =A0 =A0 copied =3D 0;
>>
>> =A0 =A0 =A0 err =3D -EPIPE;
>> *************** new_segment:
>> *** 805,810 ****
>> --- 809,817 ----
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D skb_shinfo(skb)->nr_frags;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 can_coalesce =3D skb_can_coalesce(skb, i=
, page, offset);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* hack begin */
>> + =A0 =A0 =A0 =A0 =A0 =A0 can_coalesce =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* hack end */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!can_coalesce && i >=3D MAX_SKB_FRAG=
S) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_mark_push(tp, skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto new_segment;
>> *************** wait_for_memory:
>> *** 857,862 ****
>> --- 864,873 ----
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto do_error;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss_now =3D tcp_send_mss(sk, &size_goal,=
 flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* hack begin */
>> + =A0 =A0 =A0 =A0 =A0 =A0 mss_now =3D mss_now >> 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 size_goal =3D mss_now;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* hack end */
>> =A0 =A0 =A0 }
>>
>>
>
> You dont need to hack kernel
>
> man 7 tcp
>
> =A0 =A0 =A0 TCP_MAXSEG
> =A0 =A0 =A0 =A0 =A0 =A0 =A0The =A0maximum =A0segment =A0size =A0for =A0=
outgoing TCP packets. =A0If this
> =A0 =A0 =A0 =A0 =A0 =A0 =A0option is set before connection establishm=
ent, it =A0also =A0changes
> =A0 =A0 =A0 =A0 =A0 =A0 =A0the =A0MSS value announced to the other en=
d in the initial packet.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0Values greater than the (eventual) interfa=
ce MTU have no effect.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0TCP =A0will =A0also =A0impose =A0its minim=
um and maximum bounds over the
> =A0 =A0 =A0 =A0 =A0 =A0 =A0value provided.
>
>

My objective is to send a train of packets each of which has a
different packet size. The maximum packet size should be restricted by
the MSS however the packet sizes should not be the same. Before
randomizing the packet sizes, I wanted to check if I set the packet
size to a fixed value will it be reflected on the packets being sent
over the wire.

Regards,
Ashwin
