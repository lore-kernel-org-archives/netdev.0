From: Mirza Krak <mirza.krak@hostmobility.com>
Subject: Re: [PATCH 1/1] can: sja1000: clear interrupts on start
Date: Wed, 11 Nov 2015 13:29:59 +0100
Message-ID: <CAJ=nTstPCev0TGjZCYkzf4qX+6NUUv8+-6PeVEKL9bcOwBKc0A@mail.gmail.com>
References: <1447163974-24514-1-git-send-email-mirza.krak@hostmobility.com>
	<5642F6A5.5070301@pengutronix.de>
	<CAJ=nTssqwtYAos67GRr8fOzsm63v_Bx+GKEWriOjbTALuzv-0g@mail.gmail.com>
	<5643132A.7080504@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wg@grandegger.com, andri.yngvason@marel.com,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christian Magnusson <Christian.Magnusson@semcon.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5643132A.7080504@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-11-11 11:06 GMT+01:00 Marc Kleine-Budde <mkl@pengutronix.de>:
> On 11/11/2015 10:54 AM, Mirza Krak wrote:
>> 2015-11-11 9:04 GMT+01:00 Marc Kleine-Budde <mkl@pengutronix.de>:
>>> This problem occurs only an hardware, where the SJA1000 is powered
>>> during system suspend?
>>
>> Correct, and the controller is in UP state.
>>
>>> Doesn't the SJA1000 trigger an interrupt that is detected after
>>> resuming? You add the fix to the open() function, which is triggere=
d
>>> during $(ifconfig up), how is related to suspend/resume? Does the
>>> network layer call $(ifconfig down) during shutdown?
>>
>> It does not trigger another interrupt.
>
> Can you put a scope on the interrupt pin and see if it's a problem of
> the SoC and/or Linux or the SJA1000 not pulling the IRQ line.

A little demonstration on what it looks like when the system is
resumed (added a printk in sja1000_start without my patch, though my
printk also clears IR register):

root@mx4-vcc:/opt/hm# ip -det link show can0
33: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state
UNKNOWN mode DEFAULT qlen 10
    link/can
    can state ERROR-ACTIVE (berr-counter tx 0 rx 128) restart-ms 0
    bitrate 500000 sample-point 0.875
    tq 250 prop-seg 3 phase-seg1 3 phase-seg2 1 sjw 1
    sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 12000000
root@mx4-vcc:/opt/hm# ifconfig can0 down
root@mx4-vcc:/opt/hm# ifconfig can0 up
[ 1612.621187] sja1000: MOD: 0x1
[ 1612.640992] sja1000: SR: 0x7c
[ 1612.660039] sja1000: IR: 0x24

Also did a measurement with the scope, it is the SJA1000 chip not
pulling the IRQ line.

I can actually send one frame when the controller is in this state but
never get a TI interrupt.

root@mx4-vcc-14381059:~/test/can_test# ip -det link show can0
17: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state
UNKNOWN mode DEFAULT qlen 10
    link/can
    can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
    bitrate 125000 sample-point 0.875
    tq 500 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
    sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 12000000
root@mx4-vcc-14381059:~/test/can_test# cansend can0 -i 123 0 1 2
interface =3D can0, family =3D 29, type =3D 3, proto =3D 1
root@mx4-vcc-14381059:~/test/can_test# cansend can0 -i 123 0 1 2
interface =3D can0, family =3D 29, type =3D 3, proto =3D 1
root@mx4-vcc-14381059:~/test/can_test# cansend can0 -i 123 0 1 2
interface =3D can0, family =3D 29, type =3D 3, proto =3D 1
root@mx4-vcc-14381059:~/test/can_test# cat /proc/interrupts | grep can0
205:          0          0      GPIO  can0
root@mx4-vcc-14381059:~/test/can_test#


## Second unit
root@mx4-t20-1000000:~/test/can_test# candump can0
interface =3D can0, family =3D 29, type =3D 3, proto =3D 1
<0x07b> [3] 00 01 02


>>> There isn't any suspend/resume code in the sja1000 driver, for me i=
t
>>> seems that we should add resume code that handles this problem.
>>
>> Yes, resume code should be implemented to handle this and other
>> problems (receive data). But still a DOWN/UP procedure should clear
>> any previous state that could exist in the controller registers.
>
> I'll add your patch to can/master and add stable on Cc. Looking forwa=
rd
> for some suspend/resume code :)

Looking forward to writing suspend/resume code :).

Some cred should go to Christian (added him to CC) for finding this
problem and reporting it to me.

--=20
Med V=C3=A4nliga H=C3=A4lsningar / Best Regards

*******************************************************************
Mirza Krak
Host Mobility AB
mirza.krak@hostmobility.com
Anders Personsgatan 12, 416 64 G=C3=B6teborg
Sweden
http://www.hostmobility.com
Direct: +46 31 31 32 704
Phone: +46 31 31 32 700
=46ax: +46 31 80 67 51
Mobile: +46 730 28 06 22
*******************************************************************
