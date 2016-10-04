From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [ISSUE: mv88e6xxx]: Down/Up link and not forwarding
Date: Tue, 04 Oct 2016 11:58:28 -0700
Message-ID: <19A0FE92-E4DB-49EB-AF4C-30A73DFED7E9@gmail.com>
References: <8e5e36d7-7618-2a4e-6aba-e65e41662d47@aoifes.com> <40e73820-6e67-5cde-b492-bfbcba64caeb@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
To: Jose Antonio Delgado Alfonso <jose.delgado@aoifes.com>,
        netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35820 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbcJDS6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 14:58:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id f193so16464813wmg.2
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 11:58:48 -0700 (PDT)
In-Reply-To: <40e73820-6e67-5cde-b492-bfbcba64caeb@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 4, 2016 8:37:13 AM PDT, Jose Antonio Delgado Alfonso <jose.delgado@aoifes.com> wrote:
>We are working in an ARMv7 embedded system running kernel 4.1 but
>including patches to upgrade dsa/mv88e6xxx to kernel version 4.3
>(5acf4d0, Wed, 27 May 2015 15:32:15 -0700) "[PATCH] blk: rq_data_dir()
>should not return a boolean."
>
>This is the schema of the system.
>
> +-------------------+ eth0
> |                   +--+
> |                   |  |
> | Embedded system   +--+
> |                   |
> |      ARMv7        |
> |                   | Marvell 88E8057(sky2)     +-------------+
>|                   +--+                     +--+             +--+ eth1
>|                   |  +---------------------+  |             | 
>+------+
> |                   +--+      CPU port       +--+  mv88e6176  +--+
> +------+--+---------+                           |             |
>emulated|  |                                     |             |
>GPIO    +--+                                  +--+             +--+
>eth2
>MDIO      +-----------------------------------+  |             | 
>+------+
>                              MDIO            +--+             +--+
>                                                 +-------------+
>
>There is a bridge (br-lan) which includes eth0/eth1/eth2

Can you detail what eth0 and eth1 actually correspond to? The bridge layer denies adding DSA master network interfaces as bridge members as soon as they have tags enabled.

>
>>From time to time, We are seeing a link down and up of about 1s.
>Following the message that kernel sends.
>
>[  312.769399] dsa dsa@0 eth2: Link is Down
>[  312.773372] br-lan: port 3(eth2) entered disabled state
>[  312.947274] dsa dsa@0 eth2: link up, 100 Mb/s, full duplex, flow
>control disabled
>[  312.963807] br-lan: port 3(eth2) entered forwarding state
>[  312.969276] br-lan: port 3(eth2) entered forwarding state
>[  313.777815] dsa dsa@0 eth2: Link is Up - 100Mbps/Full - flow control
>rx/tx
>[  314.966277] br-lan: port 3(eth2) entered forwarding state
>
>Moreover, under a reboot loop test which consists in booting the
>system,
>ping the unit and, if it responds, reboot again, we found that the
>bridge does not forward packages after many reboots.
>Looking into 88e6176 registers we saw the following
>
>    GLOBAL GLOBAL2   0    1    2    3    4    5    6 
> 0:  c820       0  de0f 5d0f 500f 500f 500f 4e07 4007
> 1:     3       0    3e    3    3    3    3    3    3
> 2:     0    ffff     0    0    0    0    0    0    0
> 3:     0    ffff  1761 1761 1761 1761 1761 1761 1761
> 4:  6000     258  373f  433  430  433  433  433  433
> 5:  1000    c12f     0    0    0    0    0    0    0
> 6:  c000    1f0f  101e 3005 3003 4001 5001 6001 7001
> 7:     0    707f     0    0    0    0    0    0    0
> 8:     0    7800  2480 2480 2480 2480 2480 2480 2480
> 9:     0    1600     1    1    1    1    1    1    1
> a:   148       0     0    0    0    0    0    0    0
> b:  6000    1000     1    2    4    8   10   20   40
> c:     0      22     0    0    0    0    0    0    0
> d:  ffff     507     0    0    0    0    0    0    0
> e:  ffff      36     0    0    0    0    0    0    0
> f:  ffff     f00  dada dada dada dada dada dada dada
>10:     0       0     0    0    0    0    0    0    0
>11:     0       0     0    0    0    0    0    0    0
>12:  5555       0     0    0    0    0    0    0    0
>13:  5555       0   34d 8b18  54d    0    0    0    0
>14:  aaaa     400     0    0    0    0    0    0    0
>15:  aaaa       0     0    0    0    0    0    0    0
>16:  ffff       0    33   33   33   33   33   33    0
>17:  ffff       0     0    0    0    0    0    0    0
>18:  fa41    1884  3210 3210 3210 3210 3210 3210 3210
>19:     0     5e1  7654 7654 7654 7654 7654 7654 7654
>1a:     0       0     0    0    0    0    0    0    0
>1b:   1fc    f869  8000 8000 8000 8000 8000 8000 8000
>1c:     0    4c00     0    0    0    0    0    0    0
>1d:  5ce0       0     0    0    0    0    0    0    0
>1e:     0       0     0    0    0    0    0    0    0
>1f:     0       0     0    0    0    0    0    0    0
>
>The main difference is GLOBAL2 5th register. When the unit is just
>initialized, the driver sets this register to 00ff, however, when the
>issue happens, its value is c12f.
>We got a patch which allows us to set registers values. If we change
>c12f to 00ff the ping works, otherwise, ping does not work. We do not
>know who is changing the register value. Apparently, driver does not.
>
>Weirderif possible, sometimes even global2 5th register is set to 00ff
>and bridge does not forward packages either. We have not sorted out
>which other register is affecting.
>
>Finally, The weirdest behaviour we are seeing is that the unit does not
>detect a link change, register 0 of ports 1 and 2 do not update their
>status.
>
>Have you experienced a similar issue in your side?
>
>Is it possible that those micro-outage could be the reason of bad
>settings in Global2 5th register?
>
>Have you fixed this issues in a newer Linux kernel version?

Can you try reproducing this with the latest net-next tree?

-- 
Florian
