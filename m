From: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Subject: Re: Trying to implement secondary loopback
Date: Mon, 18 Mar 2013 10:33:20 +0100
Message-ID: <5146DF60.9030303@hhi.fraunhofer.de>
References: <514326FF.6020205@hhi.fraunhofer.de> <CAFLxGvwvH_krBDJ2i-si1LX2SKbeeRmXGR+0ZbtEB2oKWt-GoA@mail.gmail.com> <51432B72.20408@hhi.fraunhofer.de> <CAFLxGvyCFHk=vhNYCY8obrVJR2rW9M7+J_ppyVpFq3AHAxjRjA@mail.gmail.com> <51432E13.5060003@hhi.fraunhofer.de> <CAFLxGvyDaaOtm1TrD-gfvhja_Uow8jtRbPyb2WcMscSLgo1umg@mail.gmail.com> <514331BC.4080802@hhi.fraunhofer.de> <CAFLxGvyzkoj_KtfH6=YK5LnpLW_N6sMdk7Hu=V=h5OK08oRE4Q@mail.gmail.com> <5143353C.3050107@hhi.fraunhofer.de> <51433934.3080405@hhi.fraunhofer.de>,<20130315153740.GR8869@kvack.org> <3D7E565A361FB844A410A5EFCDD7BA40031932@MXSRV3.fe.hhi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:36931 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab3CRJdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 05:33:11 -0400
In-Reply-To: <3D7E565A361FB844A410A5EFCDD7BA40031932@MXSRV3.fe.hhi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.03.2013 20:48, schrieb Martitz, Thomas:
>>
>> ________________________________________
>> Von: Benjamin LaHaise [bcrl@kvack.org]
>> Gesendet: Freitag, 15. M=E4rz 2013 16:37
>> An: Martitz, Thomas
>> Cc: richard -rw- weinberger; Eric W. Biederman; netdev@vger.kernel.o=
rg; davem@davemloft.net; edumazet@google.com; herbert@gondor.apana.org.=
au
>> Betreff: Re: Trying to implement secondary loopback
>>
>> On Fri, Mar 15, 2013 at 04:07:32PM +0100, Thomas Martitz wrote:
>>> Same result. I assumed the kernel treats lo in a special way for
>>> localhost-connections and that it would be impossible to achieve th=
e
>>> same with a custom interface.
>>>
>>> I did the following:
>>>
>>> ifconfig lo down
>>> insmod ./mykmod.ko
>>> ifconfig eth2 up
>>> ifconfig eth2 127.0.0.1
>>>
>>> At this point ifconfig prints the same information for eth2 that it=
 had
>>> printed for lo before (except for the LOOPBACK flag, but I can enab=
le
>>> that one as well by adding IFF_LOOPBACK to the interface flags in t=
he
>>> module). Yet my test application only works with lo, not eth2.
>>
>> Don't use loopback ip addresses; it makes no sense to do so.  I've w=
orked
>> on a couple opf nic implementations on FPGAs for a while now (a gige
>> implementation that works, and now a 10G nic), and it's easy enough =
to
>> develop it as a regular ethernet driver.  You can write test program=
s that
>> use raw sockets to send/receive packets over the ethernet device, or=
 use
>> pktgen to send packets.  You don't even need to configure an ip addr=
ess for
>> testing with raw packets.  Testing with IP is a lot harder during ea=
rly
>> bring-up of your hardware as it requires everything to work (that is=
, you
>> need ARP to work successfully before IP can work).  Just stick to si=
mple
>> packet injection initially, and don't confuse yourself by thinking a=
bout
>> the loopback device.
>
> Thank you for your very helpful mail. I haven't considered raw socket=
s, but it makes total sense now you mention it. This should give a lot =
less hassle.
>
> However, please let us try to clear up my (mis-)understanding. Even w=
hen I use non-looback addresses (e.g. 192.168.1.x) it does not work. Fo=
r the ARP requirement I tried to workaround by using specifying the IFF=
_NOARP flag, and using the arp command line tool to populate the arp ca=
che with the the MAC. With this, and all other interfaces down'ed, I ca=
nnot get transfers to work. The the sendto() (sending UDP datadagrams) =
call hangs while the ndk_start_xmit() method isn't even called. As work=
s fine with the loopback interface I started to believe that I need to =
implement a real loopback interface. It is this supposed to work this w=
ay isn't it?
>
> Best regards.



I have found the root problem, that Linux does not allow local (same=20
machine) connections via any non-lo interface. See [1] and [2]. Whether=
=20
two NICs connected via crossover cable, or one NIC implementing a=20
loopback, the kernel routes transmission via "lo" (and if it's down'ed=20
there is no traffic at all).

This made me led me to the conclusion that I need a real (secondary)=20
loopback, because an ethX interface simply doesn't work.

According to [2], I have now baked a script which enables local=20
connections via non-lo interfaces, and I think I'm happy with it.

Do you guys now why linux makes it so hard (before 2.6.33 even=20
impossible) to set up local connections like this (for testing=20
purposes)? I understand that routing to lo is a strong optimization for=
=20
real traffic but it should be easy to opt out if routing through NICs i=
s=20
really necessary as in my case.

Thank you for your patience and help.
Best regards.

[1]: http://www.zyztematik.com/?p=3D10
[2]:=20
http://umweltsuende.wordpress.com/2011/11/13/monolog-fur-linux-server-s=
end-to-self-patch-alternative/

-----
visit us at

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 118=
07

NABSHOW 2013 / April 8-11 / Las Vegas Convention Center, Nevada, USA / =
booth C7843

www.hhi.fraunhofer.de/events
