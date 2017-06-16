From: Mason <slash.tmp@free.fr>
Subject: Re: Toggling link state breaks network connectivity
Date: Fri, 16 Jun 2017 16:18:06 +0200
Message-ID: <22c9108a-0132-8a60-c369-3e493d557e4b@free.fr>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
 <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
 <17e1e9c3-7adb-05fe-18cd-ce6db4ac792d@gmail.com>
 <51eb8306-64e5-f528-d663-be80c73098f1@free.fr>
 <6edad982-713a-1b38-d9f0-e763c70c4f95@gmail.com>
 <f99f714e-2522-3b6e-6619-7a82db2b76db@free.fr>
 <yw1xk24dr1sf.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:29520 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752913AbdFPOST (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 10:18:19 -0400
In-Reply-To: <yw1xk24dr1sf.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/2017 12:19, Måns Rullgård wrote:

> Now I did notice one thing.  When the interrupts from the loopback
> frames are handled, the rx interrupt is all but disabled for NAPI poll
> mode.  Of course, NAPI isn't active, so the rx interrupt never gets
> re-enabled.  We should probably do this in ndo_open just to be sure.

I have tried everything I could think of (whether reasonable,
or just random). Setting the link down always hoses the board's
network connectivity, 100% reproducible on Vantage 1218.

The single HW difference that I'm aware of is that the Atheros
PHY used to be clocked at 25 MHz (I think) on 1172 and 1191
boards, but it is clocked at 100 MHz on this 1218 board. 
I'll try tweaking this setting.

For the time being, my test script is:

ip addr add 172.27.64.77/18 brd 172.27.127.255 dev eth0
ip link set eth0 up
sleep 6  ## autoneg should be complete
ntpdate 172.27.64.1
sleep 1
date +%T && ping -c 3 172.27.64.1 > /tmp/ping_before
sleep 1
ip link set eth0 down
sleep 2
ip link set eth0 up
sleep 5
date +%T && ping -c 3 172.27.64.1 > /tmp/ping_after

# cat /tmp/ping_before

PING 172.27.64.1 (172.27.64.1): 56 data bytes
64 bytes from 172.27.64.1: seq=0 ttl=64 time=31.442 ms
64 bytes from 172.27.64.1: seq=1 ttl=64 time=31.359 ms
64 bytes from 172.27.64.1: seq=2 ttl=64 time=31.379 ms

--- 172.27.64.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 31.359/31.393/31.442 ms

=> These RTT numbers are crazy high for a LAN connection
through a switch. (I get 0.250 ms from my desktop.)

=> What the server saw was:
15:23:30.400066 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41987, seq 0, length 64
15:23:30.400094 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41987, seq 0, length 64
15:23:31.431479 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41987, seq 1, length 64
15:23:31.431500 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41987, seq 1, length 64
15:23:32.462844 IP 172.27.64.77 > 172.27.64.1: ICMP echo request, id 41987, seq 2, length 64
15:23:32.462867 IP 172.27.64.1 > 172.27.64.77: ICMP echo reply, id 41987, seq 2, length 64


# cat /tmp/ping_after  
PING 172.27.64.1 (172.27.64.1): 56 data bytes

--- 172.27.64.1 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss

=> What the server saw was:
15:23:41.180068 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
15:23:41.180081 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
15:23:42.194409 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
15:23:42.194419 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28
15:23:43.207700 ARP, Request who-has 172.27.64.1 tell 172.27.64.77, length 46
15:23:43.207710 ARP, Reply 172.27.64.1 is-at 00:15:17:24:e0:81, length 28



Below are the "raw" logs (of what I thought might be useful)

Regards.


[    0.898538] libphy: Fixed MDIO Bus: probed
[    0.902734] ENTER nb8800_probe
[    0.905863] ++ETH++ gw8  0xf0026424 0x00
[    0.919601] ++ETH++ gw8  0xf0026424 0x01
[    0.923550] ++ETH++ gw16 0xf0026420 0x0050
[    0.927749] libphy: nb8800-mii: probed
[    0.933736] ENTER nb8800_hw_init
[    0.936991] ++ETH++ gw8  0xf0026000 0x1c
[    0.940952] ++ETH++ gw8  0xf0026001 0x05
[    0.944897] ++ETH++ gw8  0xf0026004 0x22
[    0.948839] ++ETH++ gw8  0xf0026008 0x04
[    0.952792] ++ETH++ gw8  0xf0026014 0x0c
[    0.956740] ++ETH++ gw8  0xf0026051 0x00
[    0.960693] ++ETH++ gw8  0xf0026052 0xff
[    0.964637] ++ETH++ gw8  0xf0026054 0x40
[    0.968579] ++ETH++ gw32 0xf0026100 0x000002fe
[    0.973058] ++ETH++ gw32 0xf0026118 0x003cc4a4
[    0.977527] ++ETH++ gw32 0xf0026200 0x000002fe
[    0.981994] ++ETH++ gw32 0xf0026218 0x00004dc8
[    0.986473] ++ETH++ gw8  0xf002602e 0x00
[    0.990417] EXIT nb8800_hw_init
[    0.993576] ++ETH++ gw8  0xf0026400 0x01
[    0.997518] ++ETH++ gw32 0xf0026200 0x0000028e
[    1.001988] ++ETH++ gw8  0xf002606a 0x00
[    1.005930] ++ETH++ gw8  0xf002606b 0x16
[    1.009873] ++ETH++ gw8  0xf002606c 0xe8
[    1.013815] ++ETH++ gw8  0xf002606d 0x4d
[    1.017757] ++ETH++ gw8  0xf002606e 0x7f
[    1.021699] ++ETH++ gw8  0xf002606f 0xc4
[    1.025641] ++ETH++ gw8  0xf002603c 0x00
[    1.029584] ++ETH++ gw8  0xf002603d 0x16
[    1.033526] ++ETH++ gw8  0xf002603e 0xe8
[    1.037468] ++ETH++ gw8  0xf002603f 0x4d
[    1.041411] ++ETH++ gw8  0xf0026040 0x7f
[    1.045354] ++ETH++ gw8  0xf0026041 0xc4
[    1.049772] nb8800 26000.ethernet eth0: MAC address 00:16:e8:4d:7f:c4
[    1.056259] EXIT nb8800_probe

# ip addr add 172.27.64.77/18 brd 172.27.127.255 dev eth0
# ip link set eth0 up
[   16.172093] ENTER nb8800_open
[   16.175096] ++ETH++ gw32 0xf0026204 0x0000000f
[   16.179574] ++ETH++ gw32 0xf0026104 0x0000000f
[   16.184063] ENTER nb8800_dma_init
[   16.188000] ++ETH++ gw32 0xf002620c 0x9dc4c000
[   16.192478] EXIT  nb8800_dma_init
[   16.195851] ++ETH++ gw32 0xf0026218 0x00004dc8
[   16.200334] ++ETH++ gw8  0xf0026004 0x23
[   16.204280] ++ETH++ gw8  0xf0026000 0x1d
[   16.208234] nb8800_mdio_write: reg=0x00 val=8000
[   16.269621] nb8800_mdio_read : reg=0x00 val=0000
[   16.282954] nb8800_mdio_read : reg=0x01 val=7949
[   16.287639] nb8800_mdio_read : reg=0x0f val=a000
[   16.292324] nb8800_mdio_read : reg=0x00 val=0000
[   16.296968] nb8800_mdio_write: reg=0x00 val=0000
[   16.301714] nb8800_mdio_read : reg=0x13 val=7c40
[   16.306399] nb8800_mdio_read : reg=0x12 val=0000
[   16.311044] nb8800_mdio_write: reg=0x12 val=ec00
[   16.315726] ++ETH++ gw32 0xf0026200 0x0000028f
[   16.320246] nb8800_mdio_read : reg=0x04 val=11e1
[   16.324932] nb8800_mdio_read : reg=0x01 val=7949
[   16.329583] EXIT  nb8800_open
[   16.329586] ENTER nb8800_set_rx_mode
[   16.329590] ++ETH++ gw8  0xf002602e 0x00
[   16.329593] EXIT  nb8800_set_rx_mode
[   16.329627] ENTER nb8800_set_rx_mode
[   16.329630] ++ETH++ gw8  0xf002602e 0x00
[   16.329632] ++ETH++ gw8  0xf0026028 0x01
[   16.329634] ++ETH++ gw8  0xf0026029 0x00
[   16.329635] ++ETH++ gw8  0xf002602a 0x5e
[   16.329637] ++ETH++ gw8  0xf002602b 0x00
[   16.329638] ++ETH++ gw8  0xf002602c 0x00
[   16.329639] ++ETH++ gw8  0xf002602d 0x01
[   16.329641] ++ETH++ gw8  0xf002602e 0xff
[   16.329647] EXIT  nb8800_set_rx_mode
[   16.382924] nb8800_mdio_read : reg=0x09 val=0300
[   16.387566] nb8800_mdio_write: reg=0x09 val=0200
[   16.392289] nb8800_mdio_read : reg=0x00 val=0000
[   16.396931] nb8800_mdio_write: reg=0x00 val=1200
# sleep 6  ## autoneg should be complete
[   19.677048] nb8800_mdio_read : reg=0x12 val=ec00
[   19.681709] nb8800_mdio_write: reg=0x12 val=0000
[   19.686437] nb8800_mdio_read : reg=0x13 val=7400
[   19.691124] nb8800_mdio_read : reg=0x12 val=0000
[   19.695772] nb8800_mdio_write: reg=0x12 val=ec00
[   19.700503] nb8800_mdio_read : reg=0x01 val=796d
[   19.705189] nb8800_mdio_read : reg=0x01 val=796d
[   19.709873] nb8800_mdio_read : reg=0x0a val=3c00
[   19.714556] nb8800_mdio_read : reg=0x09 val=0200
[   19.719237] nb8800_mdio_read : reg=0x05 val=cde1
[   19.723922] nb8800_mdio_read : reg=0x04 val=11e1
[   19.728604] nb8800_mdio_read : reg=0x01 val=796d
[   19.733258] ++ETH++ gw8  0xf0026050 0x01
[   19.737204] ++ETH++ gw8  0xf002601c 0xff
[   19.741149] ++ETH++ gw8  0xf0026044 0x81
[   19.745090] IGNORE nb8800_pause_config
[   19.748869] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
# 
# ntpdate 172.27.64.1
(snip ntpdate-induced network activity)
16 Jun 13:23:29 ntpdate[928]: step time server 172.27.64.1 offset 1497619379.702206 sec

# sleep 1
# date +%T && ping -c 3 172.27.64.1 > /tmp/ping_before
13:23:30
[   30.738458] ++ETH++ gw32 0xf002610c 0x9f6f8150
[   30.742929] ++ETH++ gw32 0xf0026100 0x00540aff
[   30.747414] ++ETH++ gw32 0xf0026104 0x00000004
[   30.751879] ++ETH++ gw32 0xf0026204 0x00000004
[   30.756338] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   30.760814] ++ETH++ gw32 0xf0026104 0x00000001
[   30.765326] ++ETH++ gw32 0xf0026218 0x00004dc8
[   31.769882] ++ETH++ gw32 0xf002610c 0x9f6f8180
[   31.774345] ++ETH++ gw32 0xf0026100 0x005c0aff
[   31.778821] ++ETH++ gw32 0xf0026104 0x00000004
[   31.783285] ++ETH++ gw32 0xf0026204 0x00000004
[   31.787745] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   31.792219] ++ETH++ gw32 0xf0026104 0x00000001
[   31.796713] ++ETH++ gw32 0xf0026218 0x00004dc8
[   32.801249] ++ETH++ gw32 0xf002610c 0x9f6f81b0
[   32.805711] ++ETH++ gw32 0xf0026100 0x005c0aff
[   32.810186] ++ETH++ gw32 0xf0026104 0x00000004
[   32.814650] ++ETH++ gw32 0xf0026204 0x00000004
[   32.819110] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   32.823581] ++ETH++ gw32 0xf0026104 0x00000001
[   32.828075] ++ETH++ gw32 0xf0026218 0x00004dc8

# sleep 1
# ip link set eth0 down
[   33.858675] ENTER nb8800_set_rx_mode
[   33.862286] ++ETH++ gw8  0xf002602e 0x00
[   33.866237] ++ETH++ gw8  0xf0026028 0x01
[   33.870185] ++ETH++ gw8  0xf0026029 0x00
[   33.874128] ++ETH++ gw8  0xf002602a 0x5e
[   33.878070] ++ETH++ gw8  0xf002602b 0x00
[   33.882013] ++ETH++ gw8  0xf002602c 0x00
[   33.885953] ++ETH++ gw8  0xf002602d 0x01
[   33.889894] ++ETH++ gw8  0xf002602e 0xff
[   33.893835] EXIT  nb8800_set_rx_mode
[   33.897506] ENTER nb8800_stop
[   33.900535] nb8800_mdio_read : reg=0x12 val=ec00
[   33.905193] nb8800_mdio_write: reg=0x12 val=0000
[   33.909926] nb8800_mdio_read : reg=0x13 val=0000
[   33.914580] ENTER nb8800_dma_stop
[   33.917931] ++ETH++ gw8  0xf0026004 0x03
[   33.921875] ++ETH++ gw8  0xf0026044 0x85
[   33.925829] ++ETH++ gw32 0xf002610c 0x9f6f8000
[   33.930301] ++ETH++ gw32 0xf0026100 0x005c0aff
[   33.934787] ++ETH++ gw32 0xf0026104 0x00000004
[   33.939251] ++ETH++ gw32 0xf0026204 0x00000004
[   33.943711] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   33.948182] ++ETH++ gw32 0xf0026104 0x00000001
[   34.034815] ++ETH++ gw32 0xf002610c 0x9f6f8000
[   34.039284] ++ETH++ gw32 0xf0026100 0x005c0aff
[   34.043756] ++ETH++ gw32 0xf0026104 0x00000004
[   34.048220] ++ETH++ gw32 0xf0026204 0x00000004
[   34.052681] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   34.057151] ++ETH++ gw32 0xf0026104 0x00000001
[   34.143788] ++ETH++ gw32 0xf002610c 0x9f6f8000
[   34.148256] ++ETH++ gw32 0xf0026100 0x005c0aff
[   34.152727] ++ETH++ gw32 0xf0026104 0x00000004
[   34.153726] ++ETH++ gw8  0xf0026004 0x23
[   34.153728] ++ETH++ gw8  0xf0026044 0x81
[   34.153743] ++ETH++ gw32 0xf002620c 0x9dc4c000
[   34.153744] EXIT  nb8800_dma_stop
[   34.153746] ++ETH++ gw8  0xf0026004 0x22
[   34.153748] ++ETH++ gw8  0xf0026000 0x1c
[   34.153790] nb8800_mdio_read : reg=0x12 val=0000
[   34.153792] nb8800_mdio_write: reg=0x12 val=0000
[   34.153871] nb8800_mdio_read : reg=0x13 val=0000
[   34.153928] nb8800_mdio_read : reg=0x12 val=0000
[   34.153969] nb8800_mdio_read : reg=0x12 val=0000
[   34.154009] nb8800_mdio_read : reg=0x00 val=1000
[   34.154011] nb8800_mdio_write: reg=0x00 val=1800
[   34.213124] ++ETH++ gw32 0xf0026204 0x00000004
[   34.217584] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   34.222088] EXIT  nb8800_stop

# sleep 2
# ip link set eth0 up
[   36.258689] ENTER nb8800_open
[   36.261695] ++ETH++ gw32 0xf0026204 0x0000000f
[   36.266168] ++ETH++ gw32 0xf0026104 0x0000000f
[   36.270640] ENTER nb8800_dma_init
[   36.274560] ++ETH++ gw32 0xf002620c 0x9dc4e000
[   36.279032] EXIT  nb8800_dma_init
[   36.282390] ++ETH++ gw32 0xf0026218 0x00004dc8
[   36.286860] ++ETH++ gw8  0xf0026004 0x23
[   36.290806] ++ETH++ gw8  0xf0026000 0x1d
[   36.294778] nb8800_mdio_write: reg=0x00 val=8000
[   36.352948] nb8800_mdio_read : reg=0x00 val=0000
[   36.366281] nb8800_mdio_read : reg=0x01 val=7949
[   36.370966] nb8800_mdio_read : reg=0x0f val=a000
[   36.375659] nb8800_mdio_read : reg=0x00 val=0000
[   36.380304] nb8800_mdio_write: reg=0x00 val=0000
[   36.385040] nb8800_mdio_read : reg=0x13 val=0c00
[   36.389726] nb8800_mdio_read : reg=0x12 val=0000
[   36.394384] nb8800_mdio_write: reg=0x12 val=ec00
[   36.399071] ++ETH++ gw32 0xf0026200 0x06100a8f
[   36.403593] nb8800_mdio_read : reg=0x04 val=11e1
[   36.408279] nb8800_mdio_read : reg=0x01 val=7949
[   36.412927] EXIT  nb8800_open
[   36.412932] ENTER nb8800_set_rx_mode
[   36.412936] ++ETH++ gw8  0xf002602e 0x00
[   36.412939] EXIT  nb8800_set_rx_mode
[   36.412969] ENTER nb8800_set_rx_mode
[   36.412971] ++ETH++ gw8  0xf002602e 0x00
[   36.412973] ++ETH++ gw8  0xf0026028 0x01
[   36.412975] ++ETH++ gw8  0xf0026029 0x00
[   36.412976] ++ETH++ gw8  0xf002602a 0x5e
[   36.412978] ++ETH++ gw8  0xf002602b 0x00
[   36.412979] ++ETH++ gw8  0xf002602c 0x00
[   36.412981] ++ETH++ gw8  0xf002602d 0x01
[   36.412982] ++ETH++ gw8  0xf002602e 0xff
[   36.412988] EXIT  nb8800_set_rx_mode
[   36.466286] nb8800_mdio_read : reg=0x09 val=0200
[   36.471510] nb8800_mdio_write: reg=0x09 val=0200
[   36.476396] nb8800_mdio_read : reg=0x00 val=0000
[   36.481079] nb8800_mdio_read : reg=0x00 val=0000
[   36.485738] nb8800_mdio_write: reg=0x00 val=1200
[   39.341468] nb8800_mdio_read : reg=0x12 val=ec00
[   39.346125] nb8800_mdio_write: reg=0x12 val=0000
[   39.350849] nb8800_mdio_read : reg=0x13 val=1400
[   39.355534] nb8800_mdio_read : reg=0x12 val=0000
[   39.360182] nb8800_mdio_write: reg=0x12 val=ec00
[   39.364911] nb8800_mdio_read : reg=0x01 val=796d
[   39.369597] nb8800_mdio_read : reg=0x01 val=796d
[   39.374281] nb8800_mdio_read : reg=0x0a val=3c00
[   39.378964] nb8800_mdio_read : reg=0x09 val=0200
[   39.383645] nb8800_mdio_read : reg=0x05 val=cde1
[   39.388329] nb8800_mdio_read : reg=0x04 val=11e1
[   39.393013] nb8800_mdio_read : reg=0x01 val=796d
[   39.397662] IGNORE nb8800_pause_config
# 
# date +%T && ping -c 3 172.27.64.1 > /tmp/ping_after
13:23:41
[   41.518560] ++ETH++ gw32 0xf002610c 0x9de58000
[   41.523029] ++ETH++ gw32 0xf0026100 0x00080aff
[   41.527499] ++ETH++ gw32 0xf0026104 0x00000004
[   41.531964] ++ETH++ gw32 0xf0026204 0x00000004
[   41.536425] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   41.540898] ++ETH++ gw32 0xf0026104 0x00000001
[   41.545375] ++ETH++ gw32 0xf0026218 0x00004dc8
[   42.532916] ++ETH++ gw32 0xf002610c 0x9de58030
[   42.537380] ++ETH++ gw32 0xf0026100 0x00240aff
[   42.541849] ++ETH++ gw32 0xf0026104 0x00000004
[   42.551844] ++ETH++ gw32 0xf0026104 0x00000001
[   42.556312] ++ETH++ gw32 0xf0026218 0x00004dc8
[   43.546246] ++ETH++ gw32 0xf002610c 0x9de58060
[   43.550708] ++ETH++ gw32 0xf0026100 0x00240aff
[   43.555175] ++ETH++ gw32 0xf0026104 0x00000004
[   43.565173] ++ETH++ gw32 0xf0026104 0x00000001
[   43.569641] ++ETH++ gw32 0xf0026218 0x00004dc8
