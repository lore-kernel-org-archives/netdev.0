From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delay
 scheduler
Date: Fri, 18 Jun 2004 10:08:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D2B114.5020201@dgreaves.com>
References: <40CDD68C.8070509@dgreaves.com> <20040615155111.26d6b809@dell_ss3.pdx.osdl.net> <40D0280B.2030308@dgreaves.com> <Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jens Laas <jens.laas@data.slu.se>
In-Reply-To: <Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen, I applied your delay scheduler patch and some results appear bel=
ow.

Jens Laas wrote:

> (04.06.16 kl.11:59) David Greaves skrev f=F6ljande till Stephen Hemming=
er:
>
> We have seen the same symptoms. (2.6.x + e1000)
>
> Our system is an SMP system. That might be whats triggering the problem.
> Is your system UP or SMP ?

UP

> (Next reboot we will test running on only one CPU).
>
> We have tried with and without NAPI, both exhibit the same problem.

Me too

> We have tried different versions of e1000 without luck.

Me too, 3 cards.
(did I mention I have 2 machines with very similar specs (AMD/VIAKT600)=20
and the other one works - actually, to be accurate, hasn't yet failed=20
but hasn't yet run at full speed - and it has a higher CPU speed)

> We have tried with 100Mb and gigabit switches.

I'm now running two e1000's back to back over a piece of cat5...

>
> Make sure that flowcontrol is disabled on your switch (if it has it=20
> implemented).

...so it's not that smart anymore ;)

>>
>> module parameters.
>
>
> I believe following is recommended by driver developers:
> TxDescriptors=3D256 RxDescriptors=3D256 FlowControl=3D0 XsumRX=3D0

Yes, I'm running with module defaults unless otherwise stated but I've=20
tried that combo (to no effect)

I'm speaking with Ganesh Venkatesan at intel about it. Ganesh you went=20
off list - do you want to include Jens or maybe go back on-list?

A simple failure case for me is : 'ping -s 1500 '
This doesn't cause the timout but doesn't succeed either.

ping -f with standard packet size succeeds (slow rate though) and=20
doesn't timeout.

Using 8139 100Mbs card:
272384 packets transmitted, 272383 packets received, 0% packet loss
round-trip min/avg/max =3D 0.1/0.1/4.0 ms
real    0m32.179s

Using Pro/1000:
60992 packets transmitted, 60991 packets received, 0% packet loss
round-trip min/avg/max =3D 0.0/0.5/8.4 ms
real    0m38.257s

any ping with -s >1500 results in 100% packet loss.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
 From hereon down it's 2.6.7 with Stephen's recent delay scheduler patch

This changed the behaviour.

Now ping -s 1500 works
but after that it gets lossy
root@ash:~ # ping -s3000 10.0.1.1
PING 10.0.1.1 (10.0.1.1): 3000 data bytes
3008 bytes from 10.0.1.1: icmp_seq=3D1 ttl=3D64 time=3D0.5 ms
3008 bytes from 10.0.1.1: icmp_seq=3D11 ttl=3D64 time=3D0.5 ms
3008 bytes from 10.0.1.1: icmp_seq=3D12 ttl=3D64 time=3D0.4 ms
3008 bytes from 10.0.1.1: icmp_seq=3D13 ttl=3D64 time=3D0.9 ms
3008 bytes from 10.0.1.1: icmp_seq=3D15 ttl=3D64 time=3D0.4 ms
3008 bytes from 10.0.1.1: icmp_seq=3D16 ttl=3D64 time=3D0.3 ms

and now I'm seeing ping generate:
Jun 18 09:41:57 ash kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 18 09:41:59 ash kernel: e1000: eth0: e1000_watchdog: NIC Link is Up=20
1000 Mbps Full Duplex

ping -f now works for packet sizes up to -s 2952 (2 packets at mtu 1500)

ping -f -s 2953 results in:
PING 10.0.1.1 (10.0.1.1): 2953 data bytes
..............................ping: sendto: No buffer space available
ping: wrote 10.0.1.1 2961 chars, ret=3D-1
.ping: sendto: No buffer space available

nb. with the patch, between the same machines via an alternate pair of ni=
cs:
root@ash:~ # ping -f -s29550 haze
PING haze.dgreaves.com (10.0.0.88): 29550 data bytes
=2E
--- haze.dgreaves.com ping statistics ---
10592 packets transmitted, 10591 packets received, 0% packet loss
round-trip min/avg/max =3D 5.4/5.5/83.5 ms

Increasing Transmit Descriptors to 4096 avoids the No buffer space=20
available with packet sizes up to -s65468 (still 100% failure though)

I'm not sure that adds much now so I'll leave it until I get some more=20
suggestions.

HTH

David
