From: zhigang gong <zhigang.gong@gmail.com>
Subject: Re: TCP stack bug related to F-RTO?
Date: Fri, 25 Sep 2009 10:32:55 +0800
Message-ID: <40c9f5b20909241932k5e1f1d74kf8065e2e06aa4d09@mail.gmail.com>
References: <427999.33681.qm@web63406.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jcaoco2002@yahoo.com,
	netdev@vger.kernel.org
To: Joe Cao <caoco2002@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f194.google.com ([209.85.216.194]:59054 "EHLO
	mail-px0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbZIYCcv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 22:32:51 -0400
In-Reply-To: <427999.33681.qm@web63406.mail.re1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2009 at 1:43 AM, Joe Cao <caoco2002@yahoo.com> wrote:
> Hello,
>
> I have found the following behavior with different versions of linux =
kernel. The attached pcap trace is collected with server (192.168.0.13)=
 running 2.6.24 and shows the problem. Basically the behavior is like t=
his:
>
> 1. The client opens up a big window,
> 2. the server sends 19 packets in a row (pkt #14- #32 in the trace), =
but all of them are dropped due to some congestion.
> 3. The server hits RTO and retransmits pkt #14 in #33
> 4. The client immediately acks #33 (=3D#14), and the server (seems li=
ke to enter F-RTO) expends the window and sends *NEW* pkt #35 & #36.=3D=
A0 Timeoute is doubled to 2*RTO; The client immediately sends two Dup-a=
ck to #35 and #36.
> 5. after 2*RTO, pkt #15 is retransmitted in #39.
> 6. The client immediately acks #39 (=3D#15) in #40, and the server co=
ntinues to expand the window and sends two *NEW* pkt #41 & #42. Now the=
 timeoute is doubled to 4 *RTO.
> 8. After 4*RTO timeout, #16 is retransmitted.
> 9....
> 10. The above steps repeats for retransmitting pkt #16-#32 and each t=
ime the timeout is doubled.
> 11. It takes a long long time to retransmit all the lost packets and =
before that is done, the client sends a RST because of timeout.
>
> The above behavior looks like F-RTO is in effect. =A0And there seems =
to be a bug in the TCP's congestion control and
> retransmission algorithm. Why doesn't the TCP on server (running 2.6.=
24) enter the slow start?
As I know, the early implementation hasn't enter slow start if the
remote end is in the same network.  I'm not sure that of the version
2.6.24. But after I have a look at your trace, I think this is not the
point of your problem. The behaviour of your client 192.168.0.82 is
very strange. The client always send a packet with error TCP checksum
and the 4# to 13# packets sent by the client   totally don't conform
to  the TCP protocol, not only with wrong TCP checksum but also with
incorrect seq and ack number.

My suggestion is that before you start to investigate the server
side's behaviour, you need to correct your client side's TCP/IP stack
implementation first.

>Why should the server take that long to recover from a short period of=
 packet loss?

>
> Has anyone else noticed similar problem before? =A0If my analysis was=
 wrong, can anyone gives me some pointers to what's really wrong and ho=
w to fix it?
>
> Thanks a lot,
> Joe
>
> PS. Please cc me when this message is replied.
>
>
>
