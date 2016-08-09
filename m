From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Regression introduced by "net: ipconfig: Support using "delayed" DHCP replies"
Date: Tue, 9 Aug 2016 12:02:44 +0200
Message-ID: <CAMuHMdVjugL0y-C+vet=qbcER8rjuFKwFgrutRUAs=uOk0JZ1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe, David,

On current net-next, I see the following corruption during DHCP on
r8a7791/koelsch, which uses the sh_eth driver:

     Sending DHCP requests ., OK
     IP-Config: Got DHCP answer from 192.168.97.254, my address is 192.168.97.28
     IP-Config: Complete:
-         device=eth0, hwaddr=2e:09:0a:00:6d:85, ipaddr=192.168.97.28,
mask=255.255.255.0, gw=192.168.97.254
+         device=^M\xffffffc0\xffffffa0\xffffffe1,
hwaddr=0e:9e:45:ac:dd:b4:3a:88:95:e1:50:af:0c:44:92:c0:6c:46:9f:02:34:1e:58:21:cd:c3:40:0c:ed:80:b1:74:10:0c:04:31:06:9f:04:01:04:93:5c:51:83:18:46:09,
ipaddr=192.168.97.28, mask=255.255.255.0, gw=192.168.97.254

It may also crash in ip_auto_config() with e.g. "Unable to handle kernel NULL
pointer dereference at virtual address 0000017d".

I've bisected this to commit 2647cffb2bc6fbed163d377390eb7ca552c7c1cb
('net: ipconfig: Support using "delayed" DHCP replies').
Unfortunately just reverting that commit on current net-next is not a
solution, as
that may lead to DHCP failures:

    DHCP/BOOTP: Ignoring delayed packet
    timed out!
    [...]
    IP-Config: Retrying forever (NFS root)...

Reverting also commit e068853409aa1720 ("net: ipconfig: drop inter-device
timeout") fixes that, though.

On r8a7795/salvator-x, which uses the ravb driver, I once saw the following:

     Sending DHCP requests ., OK
     IP-Config: Got DHCP answer from 192.168.97.254, my address is 192.168.97.44
     IP-Config: Complete:
-         device=eth0, hwaddr=2e:09:0a:00:83:1e, ipaddr=192.168.97.44,
mask=255.255.255.0, gw=192.168.97.254
+         device=, hwaddr=(null), ipaddr=192.168.97.44,
mask=255.255.255.0, gw=192.168.97.254

This isn't reproducible at will, though.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
