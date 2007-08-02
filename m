From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: strange tcp behavior
Date: Thu, 2 Aug 2007 13:15:32 +0100
Message-ID: <48738.simon.1186056932@5ec7c279.invalid>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv>
    <20070802095550.GA27226@2ka.mipt.ru>
    <20070802101655.GA14749@2ka.mipt.ru>
    <36758.simon.1186054739@5ec7c279.invalid>
    <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: john@screen.lv
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:33265 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031AbXHBMPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 08:15:34 -0400
In-Reply-To: <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Don't remove CC:s, don't top post)
>> On Thu, August 2, 2007 11:16, Evgeniy Polyakov wrote:
>>> On Thu, Aug 02, 2007 at 01:55:50PM +0400, Evgeniy Polyakov
>>> (johnpol@2ka.mipt.ru) wrote:
>>>> On Thu, Aug 02, 2007 at 09:19:06AM +0300, john@screen.lv
>>>> (john@screen.lv) wrote:
>>>> > 1186035057.207629    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [SYN]
>>>> > Seq=0 Len=0
>>>> > 1186035057.207632    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [SYN,
>>>> ACK]
>>>> > Seq=0 Ack=1 Win=32792 Len=0 MSS=16396
>>>> > 1186035057.207666    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [ACK]
>>>> > Seq=1 Ack=1 Win=1500 Len=0
>>>> > 1186035057.207699    127.0.0.1 -> 127.0.0.1    SMTP Command: EHLO
>>>> localhost
>>>> > 1186035057.207718    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [ACK]
>>>> > Seq=1 Ack=17 Win=32792 Len=0
>>>> > 1186035057.207736    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [RST]
>>>> > Seq=17 Len=0
>>>> > 1186035057.223934    127.0.0.1 -> 127.0.0.1    TCP 33787 > 50000
>>>> [RST,
>>>> > ACK] Seq=0 Ack=0 Win=32792 Len=0
>>>> >
>>>> > Can someone please comment as to why, tcp  stack sends rst packet
>>>> from the
>>>> > wrong source port in this situation.
>>>>
>>>> Besides the fact, that test applications do not run if started not as
>>>> root, I got this:
>>>
>>> And it actually does not initializes a session, since tird line below
>>> shows RST, but not ack. The same with sendmail smtp server (i.e. 25 port
>>> like in your server) and unmodified client.
>>> Please provide application which can trigger the issue and I will help
>>> to debug this issue. If it will help you to debug client, I can run
>>> tcpdump on public server (say 194.85.82.65, please tell me your source
>>> address) to collect dumps. Current code does not trigger the issue on my
>>> machines (and works not like was intended by you). Ugh, and code really
>>> looks horrible...
>>>
>>
>> I just got multiple RSTs instead of a connection too. The second RST looks
>> like it's from another connection - and a RST for a RST is wrong...

On Thu, August 2, 2007 12:45, john@screen.lv wrote:
> you need to add iptables rule for this to
> work, or else the tcp resets connection too early because it does not know
> that something is listening on 50000 port.
>
> iptables -I INPUT -p tcp --dport 50000 -j DROP should do the job.

You didn't mention this before.

Without the server running:

13:02:23.314352 IP 127.0.0.1.50000 > 127.0.0.1.2500: S 53123695:53123695(0) win 1500
13:02:23.314442 IP 127.0.0.1.2500 > 127.0.0.1.50000: R 0:0(0) ack 53123696 win 0
13:02:25.906975 IP 127.0.0.1.3315 > 127.0.0.1.49197: P 1285306902:1285307318(416) ack 1267361915 win 1024
<nop,nop,timestamp 3575709021 3575672670>
13:02:25.907060 IP 127.0.0.1.49197 > 127.0.0.1.3315: . ack 416 win 1541 <nop,nop,timestamp 3575709021
3575709021>

With the server running:

13:05:55.234696 IP 127.0.0.1.50000 > 127.0.0.1.2500: S 1960601450:1960601450(0) win 1500
13:05:55.234799 IP 127.0.0.1.2500 > 127.0.0.1.50000: S 2171862150:2171862150(0) ack 1960601451 win 32792
<mss 16396>
13:05:55.238271 IP 127.0.0.1.50000 > 127.0.0.1.2500: . ack 1 win 1500
13:05:55.240034 IP 127.0.0.1.50000 > 127.0.0.1.2500: P 1:17(16) ack 1 win 1500
13:05:55.240132 IP 127.0.0.1.2500 > 127.0.0.1.50000: . ack 17 win 32792
13:05:55.242251 IP 127.0.0.1.50000 > 127.0.0.1.2500: R 1960601467:1960601467(0) win 1500
13:05:55.253884 IP 127.0.0.1.56434 > 127.0.0.1.50000: R 2171862151:2171862151(0) ack 1960601467 win 32792

Weird. I resent your final RST a few times with a delay:

13:13:05.199275 IP 127.0.0.1.50000 > 127.0.0.1.2500: S 83018811:83018811(0) win 1500
13:13:05.199378 IP 127.0.0.1.2500 > 127.0.0.1.50000: S 2627922927:2627922927(0) ack 83018812 win 32792 <mss
16396>
13:13:05.203368 IP 127.0.0.1.50000 > 127.0.0.1.2500: . ack 1 win 1500
13:13:05.205049 IP 127.0.0.1.50000 > 127.0.0.1.2500: P 1:17(16) ack 1 win 1500
13:13:05.205173 IP 127.0.0.1.2500 > 127.0.0.1.50000: . ack 17 win 32792
13:13:05.206463 IP 127.0.0.1.50000 > 127.0.0.1.2500: R 83018828:83018828(0) win 1500
13:13:05.207656 IP 127.0.0.1.50000 > 127.0.0.1.2500: R 83018828:83018828(0) win 1500
13:13:05.217664 IP 127.0.0.1.55271 > 127.0.0.1.50000: R 2627922928:2627922928(0) ack 83018828 win 32792
13:13:05.510239 IP 127.0.0.1.50000 > 127.0.0.1.2500: R 83018828:83018828(0) win 1500
13:13:05.511644 IP 127.0.0.1.50000 > 127.0.0.1.2500: R 83018828:83018828(0) win 1500
13:13:05.512764 IP 127.0.0.1.50000 > 127.0.0.1.2500: R 83018828:83018828(0) win 1500

I don't know where that extra RST is coming from.
This test would be more convincing between two hosts, since your bizarre
client is using raw sockets as root and could be doing anything.

-- 
Simon Arlott
