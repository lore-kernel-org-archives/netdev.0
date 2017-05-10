From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: select queue depending on VLAN priority
Date: Wed, 10 May 2017 02:42:21 +0000
Message-ID: <AM4PR0401MB2260BA1BC2F65B36284CF7D2FFEC0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <20170509053708.2573-1-stefan@agner.ch>
 <20170509.093913.1803457630634565212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
        "festevam@gmail.com" <festevam@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "stefan@agner.ch" <stefan@agner.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509.093913.1803457630634565212.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net> Sent: Tuesday, May 09, 2017 9:39 P=
M
>To: stefan@agner.ch
>Cc: Andy Duan <fugang.duan@nxp.com>; andrew@lunn.ch;
>festevam@gmail.com; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: [PATCH] net: fec: select queue depending on VLAN priority
>
>From: Stefan Agner <stefan@agner.ch>
>Date: Mon,  8 May 2017 22:37:08 -0700
>
>> Since the addition of the multi queue code with commit 59d0f7465644
>> ("net: fec: init multi queue date structure") the queue selection has
>> been handelt by the default transmit queue selection implementation
>> which tries to evenly distribute the traffic across all available
>> queues. This selection presumes that the queues are using an equal
>> priority, however, the queues 1 and 2 are actually of higher priority
>> (the classification of the queues is enabled in fec_enet_enable_ring).
>>
>> This can lead to net scheduler warnings and continuous TX ring dumps
>> when exercising the system with iperf.
>>
>> Use only queue 0 for all common traffic (no VLAN and P802.1p priority
>> 0 and 1) and route level 2-7 through queue 1 and 2.
>>
>> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
>> Fixes: 59d0f7465644 ("net: fec: init multi queue date structure")
>
>If the queues are used for prioritization, and it does not have multiple n=
ormal
>priority level queues, multiqueue is not what the driver should have
>implemented.
Firstly, HW multiple queues support:
	- Traffic-shaping bandwidth distribution supports credit-based and round-r=
obin-based policies. Either policy can be combined with time-based shaping.
	- AVB (Audio Video Bridging, IEEE 802.1Qav) features:
		* Credit-based bandwidth distribution policy can be combined with time-ba=
sed shaping
		* AVB endpoint talker and listener support
		* Support for arbitration between different priority traffic (for example=
, AVB class A, AVB class B, and non-AVB)
Round-robin-based policies:
	It has the same priority for three queues: In the round-robin QoS scheme, =
each queue is given an equal opportunity to transmit one frame. For example=
, if queue n has a frame to transmit, the queue transmits its frame. After =
queue n has transmitted its frame, or if queue n does not have a frame to t=
ransmit, queue n+1 is then allowed to transmit its frame, and so on.

Credit-based policies:
	The AVB credit based shaper acts independently, per class, to control the =
bandwidth distribution between normal traffic and time-sensitive traffic wi=
th respect to the total link bandwidth available.
	Credit based shaper conbined with time-based shaping: =20
		- priority: ClassA queue > ClassB queue > best effort
		- ensure the queue bandwidth as user set based on time-based shaping algo=
rithms (transmitter transmit frame from three queue in turn based on time-b=
ased shaping algorithms)
	And in real AVB case,  each streaming can be independent, and are fixed on=
 related queue. Then driver level should implement .ndo_select_queue() to p=
ut the streaming into related queue. That is what the patch did.

The current driver config the three queue to credit-based policies (AVB), t=
he patch seems no problem for the implementation. Do you have any suggestio=
n ?

Andy
