From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Is there a maximum bytes in flight limitation in the tcp stack?
Date: Mon, 7 Nov 2016 20:50:54 -0800
Message-ID: <CAK6E8=ed4yer_OLzRzUCfrU-80qC+txQ8n5UnUDT_X=3=YHLRw@mail.gmail.com>
References: <BF6B00CC65FD2D45A326E74492B2C19FB77853E9@FR711WXCHMBA05.zeu.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "De Schepper, Koen (Nokia - BE)"
        <koen.de_schepper@nokia-bell-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:33974 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbcKHEvg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 23:51:36 -0500
Received: by mail-it0-f48.google.com with SMTP id q124so15307767itd.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 20:51:35 -0800 (PST)
In-Reply-To: <BF6B00CC65FD2D45A326E74492B2C19FB77853E9@FR711WXCHMBA05.zeu.alcatel-lucent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 3, 2016 at 9:37 AM, De Schepper, Koen (Nokia - BE)
<koen.de_schepper@nokia-bell-labs.com> wrote:
>
> Hi,
>
> We experience some limit on the maximum packets in flight which seem not =
to be related with the receive or write buffers. Does somebody know if ther=
e is an issue with a maximum of around 1MByte (or sometimes 2Mbyte) of data=
 in flight per TCP flow?

does not ring a bell. I've definitely see cubic reaching >2MB cwnd (infligh=
t)
some packet trace will help.

btw, tcp_rmem is the maximum receive buffer including all header and
control overhead. the receive window announced is (very roughly) half
of your rcvbuf.

>
> It seems to be a strict and stable limit independent from the CC (tested =
with Cubic, Reno and DCTCP). On a link of 200Mbps and 200ms RTT our link is=
 only 20% (sometimes 40%, see conditions below) utilized for a single TCP f=
low with no drop experienced at all (no bottleneck in the AQM or RTT emulat=
ion, as it supports more throughput if multiple flows are active).
>
> Some configuration changes we already tried on both client and server (ke=
rnel 3.18.9):
>
> net.ipv4.tcp_no_metrics_save =3D 1
> net.ipv4.tcp_rmem =3D 4096 87380 6291456
> net.ipv4.tcp_wmem =3D 4096 16384 4194304
>
> SERVER# ss -i
> tcp    ESTAB      0      1049728  10.187.255.211:46642     10.187.16.194:=
ssh
>          dctcp wscale:7,7 rto:408 rtt:204.333/0.741 ato:40 mss:1448 cwnd:=
1466 send 83.1Mbps unacked:728 rcv_rtt:212 rcv_space:29200
> CLIENT# ss -i
> tcp    ESTAB      0      288      10.187.16.194:ssh      10.187.255.211:4=
6642
>          dctcp wscale:7,7 rto:404 rtt:203.389/0.213 ato:40 mss:1448 cwnd:=
78 send 4.4Mbps unacked:8 rcv_rtt:204 rcv_space:1074844
>
> When increasing the write and receive mem further (they were already way =
above 1 or 2 MB) it steps to double (40%; 2Mbytes in flight):
> net.ipv4.tcp_no_metrics_save =3D 1
> net.ipv4.tcp_rmem =3D 4096 8000000 16291456
> net.ipv4.tcp_wmem =3D 4096 8000000 16291456
>
> SERVER # ss -i
> tcp    ESTAB      0      2068976  10.187.255.212:54637     10.187.16.112:=
ssh
>          cubic wscale:8,8 rto:404 rtt:202.622/0.061 ato:40 mss:1448 cwnd:=
1849 ssthresh:1140 send 105.7Mbps unacked:1457 rcv_rtt:217.5 rcv_space:2920=
0
> CLIENT# ss -i
> tcp    ESTAB      0      648      10.187.16.112:ssh      10.187.255.212:5=
4637
>          cubic wscale:8,8 rto:404 rtt:201.956/0.038 ato:40 mss:1448 cwnd:=
132 send 7.6Mbps unacked:18 rcv_rtt:204 rcv_space:2093044
>
> Further increasing (x10) does not help anymore...
> net.ipv4.tcp_no_metrics_save =3D 1
> net.ipv4.tcp_rmem =3D 4096 80000000 162914560
> net.ipv4.tcp_wmem =3D 4096 80000000 162914560
>
> As all these parameters autotune, it is hard to find out which one is lim=
iting... In the examples, above unacked does not want to go higher, while c=
ongestion window in the server is big enough... rcv_space could be limiting=
, but it tunes up if I change the server with the higher buffers (switching=
 to 2MByte in flight).
>
> We also tried tcp_limit_output_bytes, setting it bigger (x10) and smaller=
(/10), without effect. We've put it in /etc/sysctl.conf and rebooted, to ma=
ke sure that it is effective.
>
> Some more detailed tests that had an effect on the 1 or 2MByte:
> - It seems that with TSO off, if we configure a bigger wmem buffer, an on=
going flow suddenly is able to immediately double its bytes in flight limit=
. We configured further up to more than 10x the buffer, but no further incr=
ease helps, and the limits we saw are only 1MByte and 2Mbyte (no intermedia=
te values depending on any parameter). When setting tcp_wmem smaller again,=
 the 2MByte limit stays on the ongoing flow. We have to restart the flow to=
 make the buffer reduction to 1MByte effective.
> - With TSO on, only the 2MByte limit is effective, independent from the w=
mem buffer. We have to restart the flow to make a tso change effective.
>
> Koen.
>
