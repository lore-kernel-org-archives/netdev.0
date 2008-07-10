From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 10 Jul 2008 15:17:53 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807101457380.13027@blackhole.kfki.hu>
References: <47EA0DAB.7080205@securenet.de> <Pine.LNX.4.64.0807042251500.4142@blackhole.kfki.hu>
 <200807071118.32988.thomas.jarosch@intra2net.com>
 <200807071518.10912.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200807071518.10912.thomas.jarosch@intra2net.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 7 Jul 2008, Thomas Jarosch wrote:

> On Monday, 7. July 2008 11:18:32 you wrote:
> > I'll upgrade to 2.6.25.10 and see if it helps,
> > there is a TCP connection timeout fix in there:
> > http://kerneltrap.org/mailarchive/linux-kernel/2008/6/14/2122714
> 
> After upgrading to 2.6.25.10, the TCP connection still stalls.
> 
> I temporarily disabled PMTU discovery, TCP window scaling, TCP SACK
> and manually forced the MTU to 1400 with no noticable effect.
> 
> I also added a "iptables -I INPUT -s IP.OF.MAIL.RELAY -j ACCEPT"
> to make sure it's not related to conntrack on the double.
> 
> So here are the current results:
> - 2.6.23.16: Working
> - 2.6.24: Stalling connection
> - 2.6.24.7: Stalling connection
> - 2.6.25.10: Stalling connection
> 
> Attached is a tcpdump of a stalling connection with the
> sensitive information replaced by "xxxxx", so please ignore the broken
> checkums at the beginning. The dump was created using 2.6.24.7.
> 
> Jozsef Kadlecsik suggested this is not related to netfilter,
> so I'm now asking for help on netdev.
> 
> Here's the text output from tcpdump:
> -----------------------------------------------------------
> 13:40:14.140625 IP linux.53132 > mailserver.smtp: S 943411848:943411848(0) win 5808 <mss 1452,sackOK,timestamp 5386646 0,nop,wscale 2>
> 13:40:14.206523 IP mailserver.smtp > linux.53132: S 4213328541:4213328541(0) ack 943411849 win 65535 <mss 1400>
[...]
> 13:42:04.198938 IP linux.53132 > mailserver.smtp: . 214152:215552(1400) ack 553 win 7504
> 13:42:04.198970 IP linux.53132 > mailserver.smtp: . 215552:216952(1400) ack 553 win 7504
> 13:43:50.437541 IP linux.53132 > mailserver.smtp: . 155928:157328(1400) ack 553 win 7504
> 13:43:50.696615 IP mailserver.smtp > linux.53132: . ack 157328 win 65535
> 13:43:50.696641 IP linux.53132 > mailserver.smtp: . 216952:218352(1400) ack 553 win 7504
> 13:43:50.696671 IP linux.53132 > mailserver.smtp: . 218352:219752(1400) ack 553 win 7504

It looks as the smtp server receives the packets slowly and it's just 
behind the client. There's no more packet to/from port 53132 in the 
tcpdump.

> 13:44:51.681540 IP mailserver.smtp > linux.41085: P 3630759848:3630759915(67) ack 1371960018 win 65535
> 13:44:51.681568 IP linux.41085 > mailserver.smtp: R 1371960018:1371960018(0) win 0
> 13:44:51.681583 IP mailserver.smtp > linux.41085: F 67:67(0) ack 1 win 65535
> 13:44:51.681594 IP linux.41085 > mailserver.smtp: R 1371960018:1371960018(0) win 0

But the first packet above from the server looks just wrong in the 
context: the port of the client "changed". This is why the client sends 
the RST packet back as there's no such TCP connection there.

Makes no sense at all...

[Wild guessing: broken virtualized SMTP server migration?]

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
