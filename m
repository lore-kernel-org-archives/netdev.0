From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Option HSO tty returning NUL bytes read continuously in USB3 port
Date: Wed, 11 Feb 2015 20:43:43 +0100
Message-ID: <CAAP7ucLNHzmm2cAR18Z_Fm9mKEgQFqjxkL3W=8NFdX2JdoFtfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dcbw@redhat.com>
To: linux-usb@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:57362 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769AbbBKTnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 14:43:43 -0500
Received: by mail-oi0-f45.google.com with SMTP id i138so17443324oig.4
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 11:43:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

I'm trying to understand why this Option Globetrotter modem
(net/usb/hso driver, 0af0:6971) ends up returning NUL bytes read
continuously in the TTY when plugged in a USB3 port but not in a USB2
one.

I'm testing this with a 3.18.6 kernel plus a self-compiled hso driver
from net-next; but I had realized about this issue quite some time
ago, so it's likely not a new thing.

ATI output:
  Manufacturer: Option N.V.
  Model: GlobeTrotter HSDPA Modem
  Revision: 2.5.13Hd (Date: Feb 18 2008, Time: 18:32:40)

The device ends up handled like this in the usb tree:
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/2p, 5000M
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/2p, 480M
    |__ Port 1: Dev 4, If 0, Class=Vendor Specific Class, Driver=hso, 12M
    |__ Port 1: Dev 4, If 1, Class=Vendor Specific Class, Driver=hso, 12M
    |__ Port 1: Dev 4, If 2, Class=Vendor Specific Class, Driver=hso, 12M

I just need to plug in the modem, and send something to the TTY (e.g.
using minicom) and the modem ends up in a cycle of sending NUL bytes,
see driver/usbmon logs below.

[  +7,092221] hso: /home/aleksander/Development/foss/hso/hso.c: Option Wireless
[  +0,000058] [2419:hso_net_init]: sizeof hso_net is 200
[  +0,000642] usbcore: registered new interface driver hso

 $ sudo minicom -D /dev/ttyHS0

[feb11 20:24] [1278:hso_serial_open]: Opening 0
[  +0,000006] [1119:_hso_serial_set_termios]: port 0
[  +0,000025] [1416:hso_serial_set_termios]: Termios called with:
cflags new[7346] - old[5298]
[  +0,000003] [1119:_hso_serial_set_termios]: port 0
[  +0,000007] [1416:hso_serial_set_termios]: Termios called with:
cflags new[-2147476302] - old[7346]
[  +0,000002] [1119:_hso_serial_set_termios]: port 0
[  +0,000007] [1416:hso_serial_set_termios]: Termios called with:
cflags new[-2147476302] - old[-2147476302]
[  +0,000003] [1119:_hso_serial_set_termios]: port 0
[  +0,000004] [1416:hso_serial_set_termios]: Termios called with:
cflags new[-2147476302] - old[-2147476302]
[  +0,000003] [1119:_hso_serial_set_termios]: port 0
[  +0,023639] [1876:intr_callback]:
--- Got intr callback 0x00 ---
[  +0,000006] [1880:intr_callback]:  port_req = 0x02
[  +0,000004] [1888:intr_callback]: Pending read interrupt on port 1
[  +0,000003] [1901:intr_callback]: Already a read pending on port 1
or port not open
[  +0,031998] [1876:intr_callback]:
--- Got intr callback 0x00 ---
[  +0,000006] [1880:intr_callback]:  port_req = 0x02
[  +0,000005] [1888:intr_callback]: Pending read interrupt on port 1
[  +0,000003] [1901:intr_callback]: Already a read pending on port 1
or port not open

minicom$ AT<enter>

--- Got muxed ctrl callback 0x00 ---
[  +0,000008] [1997:ctrl_callback]: Actual length of urb = 1
[  +0,335992] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000006] [1997:ctrl_callback]: Actual length of urb = 1
[  +1,048984] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000007] [1997:ctrl_callback]: Actual length of urb = 1
[  +0,019000] [1876:intr_callback]:
--- Got intr callback 0x00 ---
[  +0,000006] [1880:intr_callback]:  port_req = 0x01
[  +0,000004] [1888:intr_callback]: Pending read interrupt on port 0
[  +0,002989] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000007] [1997:ctrl_callback]: Actual length of urb = 6
[  +0,000004] [2035:put_rxbuf_data]: data to push to tty
[  +0,002982] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000006] [1997:ctrl_callback]: Actual length of urb = 1024
[  +0,000004] [2035:put_rxbuf_data]: data to push to tty
[  +0,002934] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000006] [1997:ctrl_callback]: Actual length of urb = 1024
[  +0,000003] [2035:put_rxbuf_data]: data to push to tty
[  +0,003052] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000006] [1997:ctrl_callback]: Actual length of urb = 1024
[  +0,000004] [2035:put_rxbuf_data]: data to push to tty
[  +0,002933] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000004] [1997:ctrl_callback]: Actual length of urb = 1024
[  +0,000003] [2035:put_rxbuf_data]: data to push to tty
[  +0,003045] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000006] [1997:ctrl_callback]: Actual length of urb = 1024
[  +0,000004] [2035:put_rxbuf_data]: data to push to tty
[  +0,002994] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000006] [1997:ctrl_callback]: Actual length of urb = 1024
[  +0,000004] [2035:put_rxbuf_data]: data to push to tty
[  +0,002956] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000005] [1997:ctrl_callback]: Actual length of urb = 1024
[  +0,000003] [2035:put_rxbuf_data]: data to push to tty
[  +0,002990] [1996:ctrl_callback]:
--- Got muxed ctrl callback 0x00 ---
[  +0,000005] [1997:ctrl_callback]: Actual length of urb = 1024


usbmon output looks like:
ffff8800b898b240 3929042350 S Ii:1:004:5 -115:128 1 <
ffff8800b898b240 3929059968 C Ii:1:004:5 0:128 1 = 02
ffff8800b898b240 3929059996 S Ii:1:004:5 -115:128 1 <
ffff8800b898b240 3929091901 C Ii:1:004:5 0:128 1 = 02
ffff8800b898b240 3929091919 S Ii:1:004:5 -115:128 1 <
ffff8800b898b9c0 3933759033 S Co:1:004:0 s 21 00 0000 0000 0001 1 = 41
ffff8800b898b9c0 3933761249 C Co:1:004:0 0 1 >
ffff8800b898b9c0 3934027079 S Co:1:004:0 s 21 00 0000 0000 0001 1 = 54
ffff8800b898b9c0 3934029197 C Co:1:004:0 0 1 >
ffff8800b898b9c0 3934330977 S Co:1:004:0 s 21 00 0000 0000 0001 1 = 0d
ffff8800b898b9c0 3934333147 C Co:1:004:0 0 1 >
ffff8800b898b240 3934339157 C Ii:1:004:5 0:128 1 = 01
ffff8800b898b3c0 3934339182 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b240 3934339187 S Ii:1:004:5 -115:128 1 <
ffff8800b898b3c0 3934342145 C Ci:1:004:0 0 6 = 0d0a4f4b 0d0a
ffff8800b898b3c0 3934342171 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934345157 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934345184 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934348156 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934348182 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934351148 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934351174 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934354154 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934354181 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934357148 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934357175 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934360089 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934360111 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934363117 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934363142 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934366154 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934366180 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934369085 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934369109 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934372085 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000
ffff8800b898b3c0 3934372109 S Ci:1:004:0 s a1 01 0000 0000 0400 1024 <
ffff8800b898b3c0 3934375142 C Ci:1:004:0 0 1024 = 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000

Any hint?

-- 
Aleksander
https://aleksander.es
