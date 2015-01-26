From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v6 0/7] can: kvaser_usb: Leaf bugfixes and USBCan-II support
Date: Mon, 26 Jan 2015 07:17:55 +0200
Message-ID: <20150126051755.GA3014@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141223154654.GB6460@vivalin-002>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This is an updated patch series for the Kvaser CAN/USB devices:

1- Extra patches are now added to the series. Most importantly
patch #1 which fixes a critical `sleep in atomic context' bug
in the current upstream driver. Patch #2 fixes a corruption in
the kernel logs, also affecting current upstream driver. Patch
#4 was originally USBCan-II only, but since it's a generic fix,
it's now retrofitted to the Leaf-only upstream driver first.

2- The series has been re-organized so that patches #1 -> #4
inclusive can go to linux-can/origin, while the rest can move
to -next.

3- There are some important updates regarding the USBCan-II
error counters, and how really erratic their heaviour is. All
the new details are covered at the bottom of this URL:

	http://article.gmane.org/gmane.linux.can/7481

4- Attached below is the new candump traces. Now
`back-to-error-active' states appear _if_ the hardware was
kind enough and decreased the error counters appropriately.
The earlier code did not recognize the error counters going
down, thus the `back-to-error-active' transitions did not
appear.

###########################################################

* Bus-off scenario (with transitions active -> passive -> back-to-active):

 (000.000000)  can0  20000080   [8]  00 00 00 00 00 00 30 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{48}{0}}
 (000.000011)  can0  20000084   [8]  00 20 00 00 00 00 88 00   ERRORFRAME
	controller-problem{tx-error-passive}
	bus-error
	error-counter-tx-rx{{136}{0}}
 (000.000001)  can0  20000080   [8]  00 00 00 00 00 00 88 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{136}{0}}
 (000.000987)  can0  20000080   [8]  00 00 00 00 00 00 98 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{152}{0}}
 (000.002011)  can0  20000084   [8]  00 40 00 00 00 00 30 00   ERRORFRAME
	controller-problem{back-to-error-active}
	bus-error
	error-counter-tx-rx{{48}{0}}
 (000.000004)  can0  20000084   [8]  00 20 00 00 00 00 78 00   ERRORFRAME
	controller-problem{tx-error-passive}
	bus-error
	error-counter-tx-rx{{120}{0}}
 (000.000002)  can0  20000080   [8]  00 00 00 00 00 00 88 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{136}{0}}
 (000.000005)  can0  20000080   [8]  00 00 00 00 00 00 90 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{144}{0}}
 (000.000002)  can0  20000080   [8]  00 00 00 00 00 00 98 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{152}{0}}
 (000.000001)  can0  20000080   [8]  00 00 00 00 00 00 A0 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{160}{0}}
 (000.000966)  can0  20000080   [8]  00 00 00 00 00 00 A8 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{168}{0}}
 (000.002998)  can0  20000084   [8]  00 40 00 00 00 00 30 00   ERRORFRAME
	controller-problem{back-to-error-active}
	bus-error
	error-counter-tx-rx{{48}{0}}
 (000.000004)  can0  20000084   [8]  00 20 00 00 00 00 80 00   ERRORFRAME
	controller-problem{tx-error-passive}
	bus-error
	error-counter-tx-rx{{128}{0}}
 (000.000002)  can0  20000080   [8]  00 00 00 00 00 00 88 00   ERRORFRAME
	bus-error
	error-counter-tx-rx{{136}{0}}
 (001.031035)  can0  200000C0   [8]  00 00 00 00 00 00 00 29   ERRORFRAME
	bus-off
	bus-error
	error-counter-tx-rx{{0}{41}}

###########################################################

Regular sending, unpluggng CAN connector, then plugging again:

(with transitions active -> warning -> passive)

[ As stated earlier, the counters don't get decreased upon CAN
replug, even if they were constantly polled. ]

 (000.011001)  can0  2A1   [1]  E5
 (000.010001)  can0  50E   [8]  E6 05 00 00 00 00 00 00
 (000.009999)  can0  009   [1]  E7
 (000.011000)  can0  6E2   [8]  E8 05 00 00 00 00 00 00
 (000.009999)  can0  314   [2]  E9 05
 (000.010001)  can0  708   [6]  EA 05 00 00 00 00
 (000.010991)  can0  20000080   [8]  00 00 00 00 00 00 00 09   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{9}}
 (000.000002)  can0  20000080   [8]  00 00 00 00 00 00 00 0A   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{10}}
 (000.000007)  can0  20000080   [8]  00 00 00 00 00 00 00 2E   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{46}}
 (000.000003)  can0  20000080   [8]  00 00 00 00 00 00 00 37   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{55}}
 (000.000002)  can0  20000080   [8]  00 00 00 00 00 00 00 40   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{64}}
 (000.000993)  can0  20000080   [8]  00 00 00 00 00 00 00 49   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{73}}
 (000.000002)  can0  20000080   [8]  00 00 00 00 00 00 00 52   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{82}}
 (000.000001)  can0  20000080   [8]  00 00 00 00 00 00 00 5B   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{91}}
 (000.000028)  can0  20000084   [8]  00 04 00 00 00 00 00 6C   ERRORFRAME
	controller-problem{rx-error-warning}
	bus-error
	error-counter-tx-rx{{0}{108}}
 (000.000955)  can0  20000080   [8]  00 00 00 00 00 00 00 7F   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{127}}
 (000.000008)  can0  20000084   [8]  00 10 00 00 00 00 00 87   ERRORFRAME
	controller-problem{rx-error-passive}
	bus-error
	error-counter-tx-rx{{0}{135}}
 (000.000001)  can0  20000080   [8]  00 00 00 00 00 00 00 87   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{135}}
 (000.000004)  can0  20000080   [8]  00 00 00 00 00 00 00 87   ERRORFRAME
	bus-error
	error-counter-tx-rx{{0}{135}}

((( Then a continous flood, exactly similar to the above packet, appears )))

 (000.500004)  can0  2ED   [4]  EB 05 00 00
 (000.000006)  can0  0DD   [5]  EC 05 00 00 00
 (000.000002)  can0  1D3   [1]  ED
 (000.000988)  can0  20D   [8]  EE 05 00 00 00 00 00 00
 (000.000006)  can0  04B   [8]  EF 05 00 00 00 00 00 00
 (000.000002)  can0  320   [8]  F0 05 00 00 00 00 00 00
 (000.000002)  can0  023   [8]  F1 05 00 00 00 00 00 00
 (000.000989)  can0  21D   [8]  F2 05 00 00 00 00 00 00
 (000.000005)  can0  17D   [8]  F3 05 00 00 00 00 00 00
 (000.000002)  can0  6DC   [8]  F4 05 00 00 00 00 00 00
 (000.000993)  can0  62D   [8]  F5 05 00 00 00 00 00 00
 (000.000006)  can0  18B   [6]  F6 05 00 00 00 00
 (000.000001)  can0  7EB   [8]  F7 05 00 00 00 00 00 00
 (000.000001)  can0  014   [8]  F8 05 00 00 00 00 00 00
 (000.000994)  can0  52F   [8]  F9 05 00 00 00 00 00 00

--
Regards,
Darwish
