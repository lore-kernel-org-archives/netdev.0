From: Traiano Welcome <traiano@gmail.com>
Subject: Re: Kernel Performance Tuning for High Volume SCTP traffic
Date: Sat, 14 Oct 2017 22:29:53 +0800
Message-ID: <CAFKCRVKScoF+AkBtsgGiFogN3KQP704v8Us9-OABy2BS-w4EVA@mail.gmail.com>
References: <CAFKCRVL-e03Cn35-Vvtb8+NSAz3Tk2Hje_Hg5K9HfqgokEBPgg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0094F48@AcuExch.aculab.com>
 <CAFKCRVLTA8Vrz-36rxfUtOf8Zc9mSPZteAgdyeETsqSa-XsOcQ@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD00950DD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:44989 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753026AbdJNO3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 10:29:54 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00950DD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've upped the value of the following sctp and udp related parameters,
in the hope that this would help:

sysctl -w net.core.rmem_max=900000000
sysctl -w net.core.wmem_max=900000000

sysctl -w net.sctp.sctp_mem="2100000000 2100000000 2100000000"
sysctl -w net.sctp.sctp_rmem="2100000000 2100000000 2100000000"
sysctl -w net.sctp.sctp_wmem="2100000000 2100000000 2100000000"

sysctl -w net.ipv4.udp_mem="5000000000 5000000000 5000000000"
sysctl -w net.ipv4.udp_mem="10000000000 10000000000 10000000000"

However, I'm still seeing rapidly incrementing rx discards reported on the NIC:

:~# ethtool -S ens4f1 | egrep -i rx_discards
     [0]: rx_discards: 6390805462
     [1]: rx_discards: 6659315919
     [2]: rx_discards: 6542570026
     [3]: rx_discards: 6431513008
     [4]: rx_discards: 6436779078
     [5]: rx_discards: 6665897051
     [6]: rx_discards: 6167985560
     [7]: rx_discards: 11340068788
     rx_discards: 56634934892

Despite the fact that I've set the NIC ring buffer on the Netextreme
interface to he maximum:

:~# ethtool -g ens4f0
Ring parameters for ens4f0:
Pre-set maximums:
RX:             4078
RX Mini:        0
RX Jumbo:       0
TX:             4078
Current hardware settings:
RX:             4078
RX Mini:        0
RX Jumbo:       0
TX:             4078

I see no ip errors at the physical interface:

ethtool -S ens4f0 | egrep phy_ip_err_discard| tail -1
     rx_phy_ip_err_discards: 0


Could anyone suggest alternative approaches I might take to optimising
the system's handling of SCTP traffic?



On Sat, Oct 14, 2017 at 12:35 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Traiano Welcome
>> Sent: 13 October 2017 17:04
>> On Fri, Oct 13, 2017 at 11:56 PM, David Laight <David.Laight@aculab.com> wrote:
>> > From: Traiano Welcome
>> >
>> > (copied to netdev)
>> >> Sent: 13 October 2017 07:16
>> >> To: linux-sctp@vger.kernel.org
>> >> Subject: Kernel Performance Tuning for High Volume SCTP traffic
>> >>
>> >> Hi List
>> >>
>> >> I'm running a linux server processing high volumes of SCTP traffic and
>> >> am seeing large numbers of packet overruns (ifconfig output).
>> >
>> > I'd guess that overruns indicate that the ethernet MAC is failing to
>> > copy the receive frames into kernel memory.
>> > It is probably running out of receive buffers, but might be
>> > suffering from a lack of bus bandwidth.
>> > MAC drivers usually discard receive frames if they can't get
>> > a replacement buffer - so you shouldn't run out of rx buffers.
>> >
>> > This means the errors are probably below SCTP - so changing SCTP parameters
>> > is unlikely to help.
>>
>> Does this mean that tuning UDP performance could help ? Or do you mean
>> hardware (NIC) performance could be the issue?
>
> I'd certainly check UDP performance.
>
>         David
>
