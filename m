From: Tony Chung <Tony.Chung@resilience.com>
Subject: How does LED blinking work in e1000 driver?
Date: Fri, 21 Apr 2006 10:18:35 -0700
Message-ID: <444913EB.9090009@resilience.com>
References: <E1FWwVM-000Jwr-00.s_goodenko-mail-ru@f64.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from 207.47.19.6.rev.nextweb.net ([207.47.19.6]:29722 "EHLO
	ex1.resilience.com") by vger.kernel.org with ESMTP id S1751339AbWDURSg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 13:18:36 -0400
To: netdev@vger.kernel.org
In-Reply-To: <E1FWwVM-000Jwr-00.s_goodenko-mail-ru@f64.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Can someone explain how does LED blinking work in the e1000 driver?

=46or the copper version work, please verify my understanding:
1. The blinking of the four LEDs is control by the LEDCTL register=20
through a 32 bit value. That is 8 bit per LED. This is already describe=
d=20
in the Intel software 8454x developer manual.

2. When running =E2=80=9Cethtool -p=E2=80=9D , the current LEDCTL value=
 will be saved.=20
Then two different LEDCTL values (mode1 and mode2 ) will be calculated=20
based on the EEPROM value (word offset at 0x4).

    * The e1000_led_on() will call LEDCTL register with mode2 value.
    * The e1000_led_off() will call LEDCTL register with mode1 value.
    * the e1000_led_on()/off() functions will be called alternatively
      based on a timer.
    * when stopped, the e100_led_cleanup() will restore the saved value
      back to the LEDCTL register.


The EEPROM data at word offset 0x4 (verify using =E2=80=9Cethtool -e=E2=
=80=9D ) is a16=20
bit value controls the behavior of the 4 LEDs (4 bits each). They are=20
defined in the file e1000_hw.h:
#define ID_LED_DEF1_DEF2 0x1
#define ID_LED_DEF1_ON2 0x2
#define ID_LED_DEF1_OFF2 0x3
#define ID_LED_ON1_DEF2 0x4
#define ID_LED_ON1_ON2 0x5
#define ID_LED_ON1_OFF2 0x6
#define ID_LED_OFF1_DEF2 0x7
#define ID_LED_OFF1_ON2 0x8
#define ID_LED_OFF1_OFF2 0x9

The defines correspond to which LED will be on/off or default during=20
mode1 or mode2. e.g. ID_LED_ON1_OFF2 mean turn LED ON during mode 1=20
while turn LED off during mode2.
ID_LED_DEF1_ON2 mean use default/original value during mode1 while turn=
=20
LED on during mode2.

If the EEPROM value at word offset 0x4 is 0xFFFF or 0x0000, then the=20
driver will use the default value 0x8911 which corresponds to:
LED0 is 0x1 (DEF1_DEF2)
LED1 is 0x1 (DEF1_DEF2)
LED2 is 0x9 (OFF1_OFF2)
LED3 is 0x8. (OFF1_ON2) so other LED3 will blink while LED0/LED1 behave=
=20
whatever the original value was.


=46or the fiber version, the e1000 driver just clear/set the software=20
defined PIN 0. Is there any document about this?
Actually, when I modified the driver to use the LEDCTL register as in=20
the copper version, it can still blink the LEDs. Why bother with define=
d=20
PIN0 at all? That is, can the driver simply use LEDCTL register alone?

Thanks.
- Tony
