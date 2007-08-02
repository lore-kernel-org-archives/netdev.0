From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: strange tcp behavior
Date: Thu, 02 Aug 2007 18:15:52 +0100
Message-ID: <46B21148.2090004@simon.arlott.org.uk>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv>    <20070802095550.GA27226@2ka.mipt.ru>    <20070802101655.GA14749@2ka.mipt.ru>    <36758.simon.1186054739@5ec7c279.invalid>    <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: john@screen.lv
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:60254 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010AbXHBRQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 13:16:18 -0400
In-Reply-To: <48738.simon.1186056932@5ec7c279.invalid>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/07 13:15, Simon Arlott wrote:
> (Don't remove CC:s, don't top post)
>>> On Thu, August 2, 2007 11:16, Evgeniy Polyakov wrote:
>>>> On Thu, Aug 02, 2007 at 01:55:50PM +0400, Evgeniy Polyakov
>>>> (johnpol@2ka.mipt.ru) wrote:
>>>>> On Thu, Aug 02, 2007 at 09:19:06AM +0300, john@screen.lv
>>>>> (john@screen.lv) wrote:
>>>>> > 1186035057.207629    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [SYN]
>>>>> > Seq=0 Len=0
>>>>> > 1186035057.207632    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [SYN,
>>>>> ACK]
>>>>> > Seq=0 Ack=1 Win=32792 Len=0 MSS=16396
>>>>> > 1186035057.207666    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [ACK]
>>>>> > Seq=1 Ack=1 Win=1500 Len=0
>>>>> > 1186035057.207699    127.0.0.1 -> 127.0.0.1    SMTP Command: EHLO
>>>>> localhost
>>>>> > 1186035057.207718    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [ACK]
>>>>> > Seq=1 Ack=17 Win=32792 Len=0
>>>>> > 1186035057.207736    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [RST]
>>>>> > Seq=17 Len=0
>>>>> > 1186035057.223934    127.0.0.1 -> 127.0.0.1    TCP 33787 > 50000
>>>>> [RST,
>>>>> > ACK] Seq=0 Ack=0 Win=32792 Len=0
>>>>> >
>>>>> > Can someone please comment as to why, tcp  stack sends rst packet
>>>>> from the
>>>>> > wrong source port in this situation.

> I don't know where that extra RST is coming from.
> This test would be more convincing between two hosts, since your bizarre
> client is using raw sockets as root and could be doing anything.

Server 192.168.7.8 (2.6.23)
Client 192.168.7.4 (2.6.20)

17:33:45.326246 IP 192.168.7.4.50000 > 192.168.7.8.2500: S 1385353579:1385353579(0) win 1500
17:33:45.326418 IP 192.168.7.8.2500 > 192.168.7.4.50000: S 1388203102:1388203102(0) ack 1385353580 win 14360 <mss 7180>
17:33:45.348833 IP 192.168.7.4.50000 > 192.168.7.8.2500: . ack 1 win 1500
17:33:45.349977 IP 192.168.7.4.50000 > 192.168.7.8.2500: P 1:17(16) ack 1 win 1500
17:33:45.350117 IP 192.168.7.8.2500 > 192.168.7.4.50000: . ack 17 win 14360
17:33:45.351273 IP 192.168.7.4.50000 > 192.168.7.8.2500: R 1385353596:1385353596(0) win 1500
17:33:45.360878 IP 192.168.7.8.48186 > 192.168.7.4.50000: R 1388203103:1388203103(0) ack 1385353596 win 14360

Seems to be losing the source port information when it decides to send 
that final RST|ACK. It's going through the "TCPAbortOnClose" path:

tcp_close:
	-> tcp_set_state(sk, TCP_CLOSE)
		-> inet_put_port(&tcp_hashinfo, sk)
		Perhaps it's losing the port information here?
	-> tcp_send_active_reset(sk, GFP_KERNEL)

"TCP_CLOSE       socket is finished"
Should these two calls be the other way round?


Also, I don't think it should be sending a RST after the other side has 
sent one - the connection no longer exists so there is nothing on the 
other side to reset.

-- 
Simon Arlott
